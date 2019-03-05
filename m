Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA85DC43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 14:45:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6939820842
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 14:45:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="rDUzlH3P"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727931AbfCEOpu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 09:45:50 -0500
Received: from mail-eopbgr790132.outbound.protection.outlook.com ([40.107.79.132]:22112
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727721AbfCEOpu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Mar 2019 09:45:50 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3Zh3QWti7A+EypxoJlz0HlIOrGIN99sujxNBthpIXDw=;
 b=rDUzlH3PvCK8oQP2B0FXhi6seJQKpeZGv0rk56wfRlNO7XA3FyWI2NR/0skcqKs3VvWKVZ6ulNin4qg3AopQNRDEx0u6psfKWyN7isbsbRhm7Gi6wzz7Bam+qDdrwY3JoHeN7ya0QmOu7YgNJQy9JMpXc5vxw26gTkBdreiF3/E=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2240.namprd13.prod.outlook.com (52.135.93.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.12; Tue, 5 Mar 2019 14:45:46 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1686.016; Tue, 5 Mar 2019
 14:45:46 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jiufei.xue@linux.alibaba.com" <jiufei.xue@linux.alibaba.com>,
        "aglo@umich.edu" <aglo@umich.edu>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
Thread-Topic: [bug report] task hang while testing xfstests generic/323
Thread-Index: AQHUz03JX9HUIwfLV060fPzVrzJvGKX1yrYAgABwXICAAD3OgIAASFUAgATbqoCAAAhnAIAA30IAgAChFQA=
Date:   Tue, 5 Mar 2019 14:45:46 +0000
Message-ID: <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
         <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
         <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
         <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
         <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
         <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
         <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
         <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
In-Reply-To: <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5cc45551-9ca3-4e41-0d1d-08d6a179409e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2240;
x-ms-traffictypediagnostic: SN6PR13MB2240:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMjQwOzIzOkUzOHRMaXpTQkxCZmt3Ly9xamsyVC8rakNl?=
 =?utf-8?B?RmwrK3AxRW5mQmNucUJqUDNOWDgydEF2TmZ6dGdKcWs0T0xxMXNkNHBNR2c5?=
 =?utf-8?B?Qzk3WGsxRkpMVGRCK1djS1VSWmlWbVYrMCtqM2krSnBpdWw3WjR0dVEwaWFO?=
 =?utf-8?B?NGcxbDFxR1JrYlNudTFtRlY0aklZTU9JVncycmtrUWhkRUs2UEt6TVQ0NzRr?=
 =?utf-8?B?YkdiS2d4Vm9Gb0xSQlhOQXRPYnR1clI1VkRlY2w3LzlXczluTnVWblVEYmJQ?=
 =?utf-8?B?L3RmU0dhbTFzT29jK3IzcHFyT3RRVkdBbWx3dCtTZE13eHdxVDc4bzU3YnQ2?=
 =?utf-8?B?WmZaQk0vRk55N01ETGlseTNNNjg3YmJ1ajhRTVpPY200Njd6VVoxMStWUHdE?=
 =?utf-8?B?ek94eE5Hb210NVRXOFpkNXRneFVlenZvNUJEWURHUUtkZHJ2blNPN0pvMUFX?=
 =?utf-8?B?WFVndzUxODhFUHZCU2hUeEJtZzh5Ym1HQnFZdlJIM1RIeUVVYzZkZ3JlWlhr?=
 =?utf-8?B?Nll0S2JZcnkvalVaL2gyL25sZndUZjVDamdwNW9vZ0dpNVpLVDZWN2M2MmFY?=
 =?utf-8?B?OHRPUnFyc0pIVW9mc0FKb1RXRkI0Zld1SGdQbFlxVFc1UU51RGFJZFIyK3F3?=
 =?utf-8?B?Z1hyME9NVk56a3dWQlptNHRrU0tVMXBmN3dpM01taWRLZUpzUU9jNDVyYUFW?=
 =?utf-8?B?UlFqNHd4aGo1R0N5d0lDeDlHSFVqa3BkUng0bThVUUlIT1JTdndjWVBEZUYv?=
 =?utf-8?B?OVpyeGZYNnZGR29FZVhPeXFvSHJuV2RUY3dndDhTS2NGRysrTjg1T2xTa1I2?=
 =?utf-8?B?Ry9ZeEQ3OGw2WFJSSXVtanVKblhONHZXeGJHNml6ekRGdlFUTVVDY1Y0UG5I?=
 =?utf-8?B?TElBN3A3ZlNETm43R2RFWkpOdExoNkNSd0JNTVBXOG5zNi9wdHp3UVg0eDYz?=
 =?utf-8?B?cUJ5Sk9zK2Y0MkdRZE5ZYXdVUjJxa1lmNkNpSktBUkhhbXNOaHdQcjdiaVl1?=
 =?utf-8?B?OHRDVWs3ZnE5M0FLUDliNVlxVnJVSzE2ejVuZkFtNkE3QzM1OE0wK0JjbjFC?=
 =?utf-8?B?cjZLcXpJR1N4ZzY3ZjN5ZFMwc0VHT2UyVEhKTG15RFl4dEt6YktvT0p5Y2xj?=
 =?utf-8?B?RWtBQUN3VzFCa2c4SmZOM3hJZjhHSTZMNG1GdXA1SzlZM2NKckRlK3UwT2pr?=
 =?utf-8?B?ckFqb2xITk9LOFJNWkY0UFNqQ3FaajNCK0pqYzJnV1RaU2QvN2p3dVZJYnNt?=
 =?utf-8?B?OXlRZFNkUGNURmdnR3ZuTUNmVWNNVFJkei9TSU81RlV2ZnE4NGVCUjd0bjIr?=
 =?utf-8?B?eSs5a25XVHJzMjRuWnFYd0dkZFFOZnBKbUwxU3MyeGxZcDFnUEp1QUQxZkQw?=
 =?utf-8?B?TjFCUVpLSE9nS0NYd29mU2dNdXQ2eWpHcWRYZ1h4eHNMSUxKNGszcnhFaDdu?=
 =?utf-8?B?cUJxZis0NnpzRmRiWE9wcm1Xc3ltRUNRVDIzU3BOdDlKY0MwTTdVclR0SG5o?=
 =?utf-8?B?TmJzdkNMQXREL3ZSdmVQcUJTR1NXRWdTNGUvSmxHZjFIY0NsZlBhV2lPZEJC?=
 =?utf-8?B?VlNQaVhxUGo5ZkZMN0hjRzZKY0R2OWc2L3VGeVhKUTlQenhPYTFGdGVad2lO?=
 =?utf-8?B?MENCYnQ5d1ZoZ0xPeUdxeHpTN1ZIU0J0LzhWTUxvS09HQ3lva0ZqTTZDOUJl?=
 =?utf-8?B?NnR6WmZLdXJkNmx4N3JvR1pzS1ZMZWlSck5mZm9jZUJVd2FodUw2aFRMei8w?=
 =?utf-8?B?WGJ6Q1pCOXdSRER1MXUrUT09?=
x-microsoft-antispam-prvs: <SN6PR13MB2240CD673A086C5EE85AF996B8720@SN6PR13MB2240.namprd13.prod.outlook.com>
x-forefront-prvs: 0967749BC1
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39840400004)(366004)(136003)(346002)(376002)(199004)(189003)(54906003)(5660300002)(110136005)(478600001)(14454004)(229853002)(6436002)(6486002)(76176011)(6506007)(99286004)(81166006)(186003)(102836004)(71190400001)(71200400001)(26005)(6246003)(2171002)(14444005)(6512007)(93886005)(316002)(53936002)(256004)(66066001)(25786009)(97736004)(305945005)(7736002)(86362001)(486006)(446003)(8676002)(476003)(2501003)(6116002)(118296001)(81156014)(2616005)(105586002)(2906002)(106356001)(68736007)(4326008)(8936002)(3846002)(36756003)(11346002)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2240;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: nVnh4xircZJLE5xxqD8S9aUReroDqu64BMh+9cDSwrfqsuaMStMaulDT2LWy876cOpXjFrlOujUbText2GrGu6nuHQYjEFuhA/dBM6XFZn59wZdS7H1s3TN6Kuf3XqtOPx4ziIJVvdwAYCjnDkTSC1KdgkzHopA6t+ctqwLDwgCaNAZSaKsGrQztEx4OR+5A3tXplmukCDFHtLbmyqaWza1ADqolmHmdFugwU+0T1pKcdMpV4k00o+dDaHHIaxIYKPJxv1/HmbSoNVktQYxRikw1TOfanRPNmjfan/bO9gXF104WSpnnOlee0igrvSwU8SeNTLrlfjV4cWk9zXqz0nfq10wVEHV99sylOjK0Z7Z/M559F1qtc4xSCsOw1A4PEaVyTyO6EV6Axph5px31uEbprfid65LxbszDmiKg97w=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0DED9AD85136FE41842269663316CA95@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5cc45551-9ca3-4e41-0d1d-08d6a179409e
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Mar 2019 14:45:46.5017
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2240
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAzLTA1IGF0IDEzOjA5ICswODAwLCBKaXVmZWkgWHVlIHdyb3RlOg0KPiBC
dXQgbm93IEkgaGF2ZSBmb3VuZCBzb21ldGhpbmcgbmV3IHRoYXQgbWF5IGhlbHBmdWwuIFdoZW4g
dGhlIHByb2JsZW0NCj4gaGFwcGVuZWQsIHJwY19zdGF0dXMgd2FzIHNldCB0byAtMTIxIHdoaWNo
IHJldHVybmVkIGZyb20NCj4gbmZzNF94ZHJfZGVjX29wZW4tPmRlY29kZV9wdXRmaC4gSSB0aGlu
ayBpdCBpcyB0aGUgY2F1c2UgdGhhdCBjbGllbnQNCj4gY2FuDQo+IG5vdCB1cGRhdGUgdGhlIHN0
YXRlaWQuDQo+IA0KPiAgICAga3dvcmtlci91NDowLTcgICAgIFswMDFdIC4uLi4gICA1NTkuOTIw
NTQyOiBuZnM0X3hkcl9kZWNfb3BlbjoNCj4gc3RhdHVzPTAgb3BlbnN0YXRlaWQ9NDAyODk6MHhk
NGJkZmViNw0KPiAgICAgIGt3b3JrZXIvMTowLTI5MjkgIFswMDFdIC4uLi4gICA1NTkuOTIwNTUw
Og0KPiBuZnM0X29wZW5fc3RhdGVpZF91cGRhdGU6IGVycm9yPTAgKE9LKSBmaWxlaWQ9MDA6MmI6
MTINCj4gZmhhbmRsZT0weDFlNDU2NmNiIHN0YXRlaWQ9NDAyODk6MHhkNGJkZmViNw0KPiAgICAg
IGt3b3JrZXIvMTowLTI5MjkgIFswMDFdIC4uLi4gICA1NTkuOTIwNTUxOiBuZnM0X29wZW5fcmVs
ZWFzZToNCj4gY2FuY2VsPTEgcnBjX3N0YXR1cz0wIHJwY19kb25lPTEgb3BlbnN0YXRlaWQ9NDAy
ODk6MHhkNGJkZmViNw0KPiANCj4gICAgICAgICAgICAgbmZzZC0yNzQxICBbMDAxXSAuLi4uICAg
NTU5LjkyMDU3MTogbmZzZF9jb21wb3VuZF9zdGF0dXM6DQo+IG9wPTEvNiBPUF9TRVFVRU5DRSBz
dGF0dXM9MA0KPiAgICAgICAgICAgICBuZnNkLTI3NDEgIFswMDFdIC4uLi4gICA1NTkuOTIwNTc1
OiBuZnNkX2NvbXBvdW5kX3N0YXR1czoNCj4gb3A9Mi82IE9QX1BVVEZIIHN0YXR1cz0wDQo+ICAg
ICAgICAgICAgIG5mc2QtMjc0MSAgWzAwMV0gLi4uLiAgIDU1OS45MjA1ODE6DQo+IG5mc2RfaW5j
X2FuZF9jb3B5X3N0YXRlaWQ6IGNsaWVudCA1YzdkZjg2Nzo5MDEzNDA0MSBzdGF0ZWlkDQo+IDAw
MDMxYjdkOjAwMDA5ZDYyIC8vIDQwMjkwDQo+ICAgICAgICAgICAgIG5mc2QtMjc0MSAgWzAwMV0g
Li4uLiAgIDU1OS45MjA1ODQ6IG5mc2RfY29tcG91bmRfc3RhdHVzOg0KPiBvcD0zLzYgT1BfT1BF
TiBzdGF0dXM9MA0KPiAgICAgICAgICAgICBuZnNkLTI3NDEgIFswMDFdIC4uLi4gICA1NTkuOTIw
NTg0OiBuZnNkX2NvbXBvdW5kX3N0YXR1czoNCj4gb3A9NC82IE9QX0dFVEZIIHN0YXR1cz0wDQo+
ICAgICAgICAgICAgIG5mc2QtMjc0MSAgWzAwMV0gLi4uLiAgIDU1OS45MjA1ODU6IG5mc2RfY29t
cG91bmRfc3RhdHVzOg0KPiBvcD01LzYgT1BfQUNDRVNTIHN0YXR1cz0wDQo+ICAgICAgICAgICAg
IG5mc2QtMjc0MSAgWzAwMV0gLi4uLiAgIDU1OS45MjA1ODg6IG5mc2RfY29tcG91bmRfc3RhdHVz
Og0KPiBvcD02LzYgT1BfR0VUQVRUUiBzdGF0dXM9MA0KPiAgICAga3dvcmtlci91NDowLTcgICAg
IFswMDFdIC4uLi4gICA1NTkuOTIwNjIyOiBuZnM0X3hkcl9kZWNfb3BlbjoNCj4gc3RhdHVzPS0x
MjEgb3BlbnN0YXRlaWQ9MDoweDdiZDVjNjZmIC8vIGFkZGVkIGZvciBkZWJ1Zw0KPiAgICAgIGt3
b3JrZXIvMTowLTI5MjkgIFswMDFdIC4uLi4gICA1NTkuOTIwNjI4OiBuZnM0X29wZW5fcmVsZWFz
ZToNCj4gY2FuY2VsPTEgcnBjX3N0YXR1cz0tMTIxIHJwY19kb25lPTEgb3BlbnN0YXRlaWQ9MDow
eDdiZDVjNjZmIC8vIGFkZGVkDQo+IGZvciBkZWJ1Zw0KPiANCj4gQW5kIHdlIGdvdCB0aGlzIGVy
cm9yIGluIGRtZXNnOg0KPiBbICA1NTkuODM0ODA4XSBuZnM6IFNlcnZlciByZXR1cm5lZCBvcGVy
YXRpb24gNTMgYnV0IHdlIGlzc3VlZCBhDQo+IHJlcXVlc3QgZm9yIDIyDQo+IFsgIDU1OS44MzU3
NDFdIG5mczogU2VydmVyIHJldHVybmVkIG9wZXJhdGlvbiA1MyBidXQgd2UgaXNzdWVkIGENCj4g
cmVxdWVzdCBmb3IgMjINCj4gDQo+IEhvd2V2ZXIsIEkgZG9uJ3Qga293biB3aHkgdGhlIGNsaWVu
dCByZWNlaXZlZCB0d28gT1BfU0VRVUVOQ0UNCj4gcmVzcG9uc2UuDQo+IEFueSBpZGVhcz8NCj4g
DQoNCk5vLCB0aGF0J3MgcXVpdGUgd2VpcmQuLi4gV2VyZSB5b3UgYWJsZSB0byBjYXRjaCB0aGlz
IGJlaGF2aW91ciBvbg0Kd2lyZXNoYXJrPyBJdCB3b3VsZCBiZSBpbnRlcmVzdGluZyB0byBzZWUg
aWYgdGhlIHNlcnZlciBpcyBhY3R1YWxseQ0Kc2VuZGluZyAyIFNFUVVFTkNFIG9wcyBvciBpZiB0
aGF0IGlzIGEgY29ycnVwdGlvbiB0aGF0IG9jY3VycyBvbiB0aGUNCmNsaWVudC4NCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UN
CnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
