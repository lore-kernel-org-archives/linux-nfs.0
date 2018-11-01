Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E34C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:57:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3362D2064C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:57:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="rvWmNey7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3362D2064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727872AbeKBDBs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 23:01:48 -0400
Received: from mail-eopbgr700136.outbound.protection.outlook.com ([40.107.70.136]:58719
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725908AbeKBDBs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 23:01:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=A2Shu1VWgmkYF4Wi+oivRpkwfE62ff9Wm+y8EgawmZg=;
 b=rvWmNey7haM8ELGYHNLvSKU1DwUqCjKCMk150zUcKSE1xx3RU9nf9BM7e93OThqYetyLLljjTynta3eZBxssyBxtPxH0gxhDZrY6whhsJkYVlUOluWyrNOzYmT2ZDUBH1QjPty1lWzCmE3Ltitf4AS0sIP3cg9wrMEn73XbvnHs=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2255.namprd13.prod.outlook.com (52.135.93.156) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.8; Thu, 1 Nov 2018 17:57:43 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.021; Thu, 1 Nov 2018
 17:57:43 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "paul.burton@mips.com" <paul.burton@mips.com>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pburton@wavecomp.com" <pburton@wavecomp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Use atomic(64)_t for seq_send(64)
Thread-Topic: [PATCH] SUNRPC: Use atomic(64)_t for seq_send(64)
Thread-Index: AQHUcguNmR07OSEUt0GCXDr8h1+WPqU7NKyA
Date:   Thu, 1 Nov 2018 17:57:43 +0000
Message-ID: <65bc05f9685faf5a29f47805e4675f229f32531c.camel@hammerspace.com>
References: <20181101145926.GE3178@hirez.programming.kicks-ass.net>
         <20181101175109.8621-1-paul.burton@mips.com>
In-Reply-To: <20181101175109.8621-1-paul.burton@mips.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2255;6:orDkr1peMgsaPlSTO1knFgqRQLEA/CewjVDLvFZClI1bUts/qiNAPAcgb52r5uptA+8BsX5z0n/021wHb9spP1BbhgtbT+VTMAotWiLHrM1jPChnnR7mRwV1WU7EfECW3TNJY5jdLz99j6iizpZMoJQJkPZyf+utuWeHmu4vi6aeNqUNtBW+fOziEZpZ3Mhts8TeUCgjfkDtPel8F8Afj6frs5Ml4PXRl3niYqODOoqzOVY7MvCCpQc5cQTtl3xzhXgdP4TRCX+o0knH92Q8BaAVNIE3llxViKG14hFdLj1NgaHaK8uQ8OzJQR4KSWdNSr54jMVH/5nR576cxvGxaRluk3J0Ne6OE8glOty4G3QQbIX8lIGdUpOfNfmP+GvhEDwsTiDZ2aviedHoh5xZHUbW4QFaGPS+bOfOqmCrmd0U2FEhDIQaO4AxENmsyqyYoIpedEb6CTSTdb/ZtqhUCQ==;5:lqMvPxWJu32CPzQnbPIjOMJ72Uq92Xh8W2x5iPm3Kxz4Wmj/EsEikAllwn14TqTQ2ZOb1SdBZP9pADosEbA3Td1VuK6m2wyqSZJhwEgJuqj2SBXYfZsJ5bIoGlaY44PVrn15yRoWWroveZXfN0gJQu5IWrU3Ph6ynZ5lN9bsS14=;7:i4OB9UJ0WYa747Y4ThyxKYrBD22fGO0vQPoAlV8M78bX1SiFbHkD65jsTxmAtaa69+UYOZ6dBcGvVDqXIoegobqSL98Yi0puiqX+WT9BAQy4L30Y2gnZgvmJNTXrsYvOiuNqJuPTwOxttpN5TGSNgQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 42f2dd52-d3ca-4005-ca3b-08d640238608
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2255;
x-ms-traffictypediagnostic: SN6PR13MB2255:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB22556636DA931BECA23C0E6EB8CE0@SN6PR13MB2255.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(788757137089)(9452136761055);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3231382)(944501410)(52105095)(10201501046)(3002001)(148016)(149066)(150057)(6041310)(20161123562045)(20161123564045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2255;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2255;
x-forefront-prvs: 0843C17679
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(376002)(396003)(346002)(366004)(136003)(189003)(199004)(71190400001)(81166006)(2900100001)(5660300001)(99286004)(14444005)(76176011)(105586002)(118296001)(8676002)(2201001)(6246003)(71200400001)(256004)(186003)(8936002)(102836004)(81156014)(6116002)(66066001)(4326008)(486006)(26005)(6506007)(106356001)(7736002)(86362001)(476003)(6486002)(446003)(2906002)(68736007)(6436002)(5250100002)(229853002)(316002)(11346002)(110136005)(2501003)(3846002)(36756003)(25786009)(305945005)(6512007)(54906003)(97736004)(53936002)(14454004)(478600001)(2616005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2255;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 1+fzBq2m5SKKXLdXhRJkXA/gEVG7fOGNbBejwx7yzWmqy1wqcI+qYd2yQNID1POOeC3t0pNQNsSICn57DcUqpJ61yLUGhhynjS9hmWXU006azm650PAKQR2b1LWtNrXfEnmSevWDMLJ3BWZAV1S7lVxj4L6mZIZM6qJxhL+GcN44zWflUcuPc+bVq2UaOP8R1pC2nZ7OzMIPNc9kfrUlCJeeQFiajEA6Lq8AsCHCaXnld2Z+DfLIbTgYueHLPdYNY+flB0TYg2TuhWlHoZmUMRKFiZ9JdcFf0S53yFFRnUWs4cW6BKk0l/o1ZOKmXI8zwZ4ed/xROV8Nbznq7xCmk87+fTCMOKwFXhn6Ax9XIMw=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <C4C2EFCF2AE9AA4F903F89D781443335@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 42f2dd52-d3ca-4005-ca3b-08d640238608
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Nov 2018 17:57:43.5079
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2255
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTExLTAxIGF0IDE3OjUxICswMDAwLCBQYXVsIEJ1cnRvbiB3cm90ZToNCj4g
VGhlIHNlcV9zZW5kICYgc2VxX3NlbmQ2NCBmaWVsZHMgaW4gc3RydWN0IGtyYjVfY3R4IGFyZSB1
c2VkIGFzDQo+IGF0b21pY2FsbHkgaW5jcmVtZW50aW5nIGNvdW50ZXJzLiBUaGlzIGlzIGltcGxl
bWVudGVkIHVzaW5nIGNtcHhjaGcoKQ0KPiAmDQo+IGNtcHhjaGc2NCgpIHRvIGltcGxlbWVudCB3
aGF0IGFtb3VudCB0byBjdXN0b20gdmVyc2lvbnMgb2YNCj4gYXRvbWljX2ZldGNoX2luYygpICYg
YXRvbWljNjRfZmV0Y2hfaW5jKCkuDQo+IA0KPiBCZXNpZGVzIHRoZSBkdXBsaWNhdGlvbiwgdXNp
bmcgY21weGNoZzY0KCkgaGFzIGFub3RoZXIgbWFqb3IgZHJhd2JhY2sNCj4gaW4NCj4gdGhhdCBz
b21lIDMyIGJpdCBhcmNoaXRlY3R1cmVzIGRvbid0IHByb3ZpZGUgaXQuIEFzIHN1Y2ggY29tbWl0
DQo+IDU3MWVkMWZkMjM5MCAoIlNVTlJQQzogUmVwbGFjZSBrcmI1X3NlcV9sb2NrIHdpdGggYSBs
b2NrbGVzcyBzY2hlbWUiKQ0KPiByZXN1bHRlZCBpbiBidWlsZCBmYWlsdXJlcyBmb3Igc29tZSBh
cmNoaXRlY3R1cmVzLg0KPiANCj4gQ2hhbmdlIHNlcV9zZW5kIHRvIGJlIGFuIGF0b21pY190IGFu
ZCBzZXFfc2VuZDY0IHRvIGJlIGFuIGF0b21pYzY0X3QsDQo+IHRoZW4gdXNlIGF0b21pYyg2NClf
KiBmdW5jdGlvbnMgdG8gbWFuaXB1bGF0ZSB0aGUgdmFsdWVzLiBUaGUNCj4gYXRvbWljNjRfdA0K
PiB0eXBlICYgYXNzb2NpYXRlZCBmdW5jdGlvbnMgYXJlIHByb3ZpZGVkIGV2ZW4gb24gYXJjaGl0
ZWN0dXJlcyB3aGljaA0KPiBsYWNrIHJlYWwgNjQgYml0IGF0b21pYyBtZW1vcnkgYWNjZXNzIHZp
YSBDT05GSUdfR0VORVJJQ19BVE9NSUM2NA0KPiB3aGljaA0KPiB1c2VzIHNwaW5sb2NrcyB0byBz
ZXJpYWxpemUgYWNjZXNzLiBUaGlzIGZpeGVzIHRoZSBidWlsZCBmYWlsdXJlcyBmb3INCj4gYXJj
aGl0ZWN0dXJlcyBsYWNraW5nIGNtcHhjaGc2NCgpLg0KPiANCj4gQSBwb3RlbnRpYWwgYWx0ZXJu
YXRpdmUgdGhhdCB3YXMgcmFpc2VkIHdvdWxkIGJlIHRvIHByb3ZpZGUNCj4gY21weGNoZzY0KCkN
Cj4gb24gdGhlIDMyIGJpdCBhcmNoaXRlY3R1cmVzIHRoYXQgY3VycmVudGx5IGxhY2sgaXQsIHVz
aW5nIHNwaW5sb2Nrcy4NCj4gSG93ZXZlciB0aGlzIHdvdWxkIHByb3ZpZGUgYSB2ZXJzaW9uIG9m
IGNtcHhjaGc2NCgpIHdpdGggc2VtYW50aWNzIGENCj4gbGl0dGxlIGRpZmZlcmVudCB0byB0aGUg
aW1wbGVtZW50YXRpb25zIG9uIGFyY2hpdGVjdHVyZXMgd2l0aCByZWFsIDY0DQo+IGJpdCBhdG9t
aWNzIC0gdGhlIHNwaW5sb2NrLWJhc2VkIGltcGxlbWVudGF0aW9uIHdvdWxkIG9ubHkgd29yayBp
Zg0KPiBhbGwNCj4gYWNjZXNzIHRvIHRoZSBtZW1vcnkgdXNlZCB3aXRoIGNtcHhjaGc2NCgpIGlz
ICphbHdheXMqIHBlcmZvcm1lZA0KPiB1c2luZw0KPiBjbXB4Y2hnNjQoKS4gVGhhdCBpcyBub3Qg
Y3VycmVudGx5IGEgcmVxdWlyZW1lbnQgZm9yIHVzZXJzIG9mDQo+IGNtcHhjaGc2NCgpLCBhbmQg
bWFraW5nIGl0IG9uZSBzZWVtcyBxdWVzdGlvbmFibGUuIEFzIHN1Y2ggYXZvaWRpbmcNCj4gY21w
eGNoZzY0KCkgb3V0c2lkZSBvZiBhcmNoaXRlY3R1cmUtc3BlY2lmaWMgY29kZSBzZWVtcyBiZXN0
LA0KPiBwYXJ0aWN1bGFybHkgaW4gY2FzZXMgd2hlcmUgYXRvbWljNjRfdCBzZWVtcyBsaWtlIGEg
YmV0dGVyIGZpdA0KPiBhbnl3YXkuDQo+IA0KPiBUaGUgQ09ORklHX0dFTkVSSUNfQVRPTUlDNjQg
aW1wbGVtZW50YXRpb24gb2YgYXRvbWljNjRfKiBmdW5jdGlvbnMNCj4gd2lsbA0KPiB1c2Ugc3Bp
bmxvY2tzICYgc28gZmFjZXMgdGhlIHNhbWUgaXNzdWUsIGJ1dCB3aXRoIHRoZSBrZXkgZGlmZmVy
ZW5jZQ0KPiB0aGF0IHRoZSBtZW1vcnkgYmFja2luZyBhbiBhdG9taWM2NF90IG91Z2h0IHRvIGFs
d2F5cyBiZSBhY2Nlc3NlZCB2aWENCj4gdGhlIGF0b21pYzY0XyogZnVuY3Rpb25zIGFueXdheSBt
YWtpbmcgdGhlIGlzc3VlIG1vb3QuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBQYXVsIEJ1cnRvbiA8
cGF1bC5idXJ0b25AbWlwcy5jb20+DQo+IEZpeGVzOiA1NzFlZDFmZDIzOTAgKCJTVU5SUEM6IFJl
cGxhY2Uga3JiNV9zZXFfbG9jayB3aXRoIGEgbG9ja2xlc3MNCj4gc2NoZW1lIikNCj4gQ2M6IFRy
b25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gQ2M6IEFu
bmEgU2NodW1ha2VyIDxhbm5hLnNjaHVtYWtlckBuZXRhcHAuY29tPg0KPiBDYzogSi4gQnJ1Y2Ug
RmllbGRzIDxiZmllbGRzQGZpZWxkc2VzLm9yZz4NCj4gQ2M6IEplZmYgTGF5dG9uIDxqbGF5dG9u
QGtlcm5lbC5vcmc+DQo+IENjOiBEYXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+
DQo+IENjOiBsaW51eC1uZnNAdmdlci5rZXJuZWwub3JnDQo+IENjOiBuZXRkZXZAdmdlci5rZXJu
ZWwub3JnDQo+IC0tLQ0KPiAgaW5jbHVkZS9saW51eC9zdW5ycGMvZ3NzX2tyYjUuaCAgICAgfCAg
NyArKy0tLS0tDQo+ICBuZXQvc3VucnBjL2F1dGhfZ3NzL2dzc19rcmI1X21lY2guYyB8IDE2ICsr
KysrKysrKystLS0tLS0NCj4gIG5ldC9zdW5ycGMvYXV0aF9nc3MvZ3NzX2tyYjVfc2VhbC5jIHwg
MjggKystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+IC0NCj4gIG5ldC9zdW5ycGMvYXV0aF9n
c3MvZ3NzX2tyYjVfd3JhcC5jIHwgIDQgKystLQ0KPiAgNCBmaWxlcyBjaGFuZ2VkLCAxNiBpbnNl
cnRpb25zKCspLCAzOSBkZWxldGlvbnMoLSkNCj4gDQoNClRoYW5rcyBQYXVsISAuLi5hbmQgdGhh
bmtzIGZvciB5b3VyIHBhdGllbmNlIGluIHdvcmtpbmcgb3V0IHRoZQ0KYXRvbWljaXR5IHdyYXBh
cm91bmQgaXNzdWVzLiBBcHBsaWVkLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJz
cGFjZS5jb20NCg0KDQo=
