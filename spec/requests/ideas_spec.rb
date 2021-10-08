require 'rails_helper'

RSpec.describe '/ideas', type: :request do
  let(:valid_attributes) do
    { category_name: 'アプリ' }
  end

  let(:invalid_attributes) do
    { category_name: '存在しないカテゴリー' }
  end

  let(:missing_body) do
    { category_name: 'アプリ' }
  end

  let(:missing_category_name) do
    { body: 'リマインダーツール' }
  end

  let(:exist_category_name) do
    { category_name: 'アプリ', body: 'リマインダーツール' }
  end

  let(:new_category_name) do
    { category_name: '家事', body: '新しい掃除機' }
  end

  let!(:c1) { Category.create({ id: 1, name: 'アプリ' }) }
  let!(:c2) { Category.create({ id: 2, name: '会議' }) }
  let!(:i1) { Idea.create({ body: 'タスク管理ツール', category_id: 1 }) }
  let!(:i2) { Idea.create({ body: 'オンラインでブレスト', category_id: 2 }) }

  describe 'GET /ideas アイデア取得API' do
    context 'category_nameが指定されている場合' do
      it '該当するcategoryのideasの一覧を返却' do
        get '/api/v1/idea', params: valid_attributes
        json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json['data'].length).to eq(1)
        expect(json['data'][0]['category']).to eq(c1.name)
        expect(json['data'][0]['body']).to eq(i1.body)
        Time.at(json['data'][0]['created_at'])
      end
    end

    context 'category_nameが指定されていない場合' do
      it '全てのideasを返却' do
        get '/api/v1/idea'
        json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(json['data'].length).to eq(2)
        expect(json['data'][0]['category']).to eq(c1.name)
        expect(json['data'][0]['body']).to eq(i1.body)
        Time.at(json['data'][0]['created_at'])
        expect(json['data'][1]['category']).to eq(c2.name)
        expect(json['data'][1]['body']).to eq(i2.body)
        Time.at(json['data'][1]['created_at'])
      end
    end

    context '登録されていないカテゴリーのリクエストの場合' do
      it 'ステータスコード404を返却' do
        get '/api/v1/idea', params: invalid_attributes
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'POST /idea アイデア登録API' do
    context 'パラメーターにcategory_nameとbodyのどちらかが存在しない場合' do
      it '失敗扱いにして422を返却' do
        post '/api/v1/idea', params: missing_body
        expect(response.status).to eq(422)
        post '/api/v1/idea', params: missing_category_name
        expect(response.status).to eq(422)
      end
    end

    context 'リクエストのcategory_nameがcategoriesテーブルのnameに存在する場合' do
      it 'そのcategoryを親としたideaを登録' do
        post '/api/v1/idea', params: exist_category_name
        expect(response.status).to eq(201)

        nc = Category.find_by(name: exist_category_name[:category_name])
        ni = Idea.find_by(body: exist_category_name[:body])
        expect(nc.name).to eq(exist_category_name[:category_name])
        expect(ni.body).to eq(exist_category_name[:body])
        expect(nc.id).to eq(ni.category_id)
      end
    end

    context 'リクエストのcategory_nameがcategoriesテーブルのnameに存在しない場合' do
      it '新しいcategoryを親としたideaを登録' do
        post '/api/v1/idea', params: new_category_name
        expect(response.status).to eq(201)

        nc = Category.find_by(name: new_category_name[:category_name])
        ni = Idea.find_by(body: new_category_name[:body])
        expect(nc.name).to eq(new_category_name[:category_name])
        expect(ni.body).to eq(new_category_name[:body])
        expect(nc.id).to eq(ni.category_id)
      end
    end
  end
end
