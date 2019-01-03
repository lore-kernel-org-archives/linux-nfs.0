Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B9C7C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:27:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 29CEA20815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="qOHlrrV2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730848AbfACQ10 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 11:27:26 -0500
Received: from mail-eopbgr810127.outbound.protection.outlook.com ([40.107.81.127]:6549
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730795AbfACQ10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 11:27:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WPmanqhntbULIqxIYHdEr6OHQ9yFihw9Gk4aCQfM8j4=;
 b=qOHlrrV2nBOu7V6WuEW8lF4shl/weRnDyBjlhzgxNRXyqEH/kyXl2NQuOwZcKJk2hiqrLyFKiXyiFEf19gMtHNYQ6O8yzONSL/jXfCNL8jje4ILYABZCwe8j5GcH8ayKd1eD1BA02enpr/B16rrXN2ajkQ50+RNXwE3vcn6ScJE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2576.namprd13.prod.outlook.com (52.135.96.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.6; Thu, 3 Jan 2019 16:27:19 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 16:27:19 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tom@talpey.com" <tom@talpey.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
Thread-Topic: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
Thread-Index: AQHUou4ciNJmIo9Omk+8lSTAAKbkzqWdrGSAgAAKCoCAAAN5gIAAApyA
Date:   Thu, 3 Jan 2019 16:27:19 +0000
Message-ID: <17c7208aee3dff40cc4d446c1c1f1000d8a1b041.camel@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
         <20190102225313.2097-2-trond.myklebust@hammerspace.com>
         <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
         <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
         <32eef80d-9129-3284-2f9d-15b9ca3930ec@talpey.com>
In-Reply-To: <32eef80d-9129-3284-2f9d-15b9ca3930ec@talpey.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2576;6:IlhO+OXwYdVmgvc3stRUpGepeiQDcPyFd3hcNAyBDPkd5XFF0oXhTxcm2FUN3+14IEpTQQ/btyOLcxN+0PsPKtl4NAUdd1y060JMH1YAi0iumcA3uKMm3DlSRWBiyE7CCBmCXaL+WNIMr3BvPCUmNnxwCmegyUCbqkit+PrGCAsGhH4J44oLjDbHio7ziHehm8FLquTYJ7iFOzxaWABAZxln/GSNHibZfaD1QmIEkUf81ahDoK/cF9ZoV2VuUi+RjzIFvFAR/N0voHxuCg/Y8ufjpiYXunSFihbvmXswiyF7Q3oRpW/7RLKbKQow0lltTwN7DXIntFJAEVNyU/bwnFPOzKlWMlTjnCR9jYFI+NXWtk5/59HpGor0ZOq4TnQo+jms4RXGMYDiOPrVgndva/0hRCA8Uu58BPDi8Abt2jM0OI7PW9GoCsSU98w6pQ0UwlR7hPnydDWeGUIcU4WcMw==;5:z34VMC5gXIinvE5l2Tuh48yL630gkPCG2elIvGq3GHZgbRV+DJi6awJC7vEt9TsWvbuhPlaQ5qYKHrk0WcNRflwTIyWiSyp3xEq9f8n8XVHx27KeCOQe73ksC2Ma7b+7OHAd2B0Kes4ATfabiX/kHrGFGsQi6M/OQULp9pzYRllkmYd1RW+RHGbL8lZzK/piLhEnsWkeuw+J/xOVc7pmfA==;7:bo9q/++jrKJL58zPMJJ2npZ5P8zfM08eq7RHUWfcDsT6e/4UIiaU6C+QWCYgxuwm8fbXFB/fogn5J+FD5oz7eIV0/MJc2ZPSBZjWGt3RWdxOzJzGhrolftoMAbH+dzDNgfCGcpaKnMCRKRlU1sgV/g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 661404a8-28dc-4979-7bcf-08d6719854e1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2576;
x-ms-traffictypediagnostic: SN6PR13MB2576:
x-microsoft-antispam-prvs: <SN6PR13MB2576F409C90061642B00B4B8B88D0@SN6PR13MB2576.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(3002001)(3231475)(944501520)(52105112)(93006095)(93001095)(10201501046)(6041310)(20161123560045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2576;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2576;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(366004)(346002)(136003)(376002)(396003)(199004)(189003)(110136005)(118296001)(14454004)(97736004)(66066001)(2906002)(4326008)(316002)(7736002)(446003)(81156014)(25786009)(6116002)(3846002)(81166006)(11346002)(229853002)(105586002)(5660300001)(86362001)(15974865002)(106356001)(478600001)(14444005)(71200400001)(2501003)(256004)(53936002)(93886005)(8676002)(486006)(305945005)(6246003)(68736007)(76176011)(8936002)(26005)(2616005)(6506007)(476003)(102836004)(6436002)(186003)(36756003)(71190400001)(53546011)(6486002)(6512007)(99286004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2576;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ncH+WG2s/UKWBSp8Zp6osSUpAbzVn6vAicrUMeOrRkNM0yznFxdFWtb2Qv84EApOiqAw3mayjFOWQv4CV+N4vx9+Jk1lM2+xXMfLdaBie2Q1IvH8abzM9+Em9ioCVArl0Har0iFkIJexHvsDeir0gQ288BNDnNwkIjmPmTp2C5XuPXWGwYjXY7Ba17H5V2ZhgrOcKt7sExsPJrU7voSv5u3jGhnZqXemhlKukY+L6qE62yezxMwV1mZA5r2aKlbXYJvTZl6wmcYunZ1bQ2zl+c0M/+KuPcKxZXM7+h6+6Rz3IXUWOTGEuim+OmUnU6MH
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <E4DB1FBF18D50247BA59B9C5E48D5463@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 661404a8-28dc-4979-7bcf-08d6719854e1
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 16:27:19.1284
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2576
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDExOjE3IC0wNTAwLCBUb20gVGFscGV5IHdyb3RlOg0KPiBP
biAxLzMvMjAxOSAxMTowNSBBTSwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIFRodSwg
MjAxOS0wMS0wMyBhdCAxMDoyOSAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiBIaSBU
cm9uZC0NCj4gPiA+IA0KPiA+ID4gSSB3YXMgY3VyaW91cyBhYm91dCB0aGlzIG9uZSBiZWNhdXNl
IHllc3RlcmRheSBJIHNhdyBldmlkZW5jZQ0KPiA+ID4gKGZvcg0KPiA+ID4gb3RoZXIgcmVhc29u
cykgdGhhdCBycV9ieXRlc19zZW50IHdhc24ndCBhbHdheXMgemVyb2VkIHdoZW4gaXQNCj4gPiA+
IHNob3VsZA0KPiA+ID4gYmUuDQo+ID4gPiANCj4gPiA+IA0KPiA+ID4gPiBPbiBKYW4gMiwgMjAx
OSwgYXQgNTo1MyBQTSwgVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QGdtYWlsLmNvbT4NCj4gPiA+
ID4gd3JvdGU6DQo+ID4gPiA+IA0KPiA+ID4gPiBXaGVuIHdlIHJlc2VuZCBhIHJlcXVlc3QsIGVu
c3VyZSB0aGF0IHRoZSAncnFfYnl0ZXNfc2VudCcgaXMNCj4gPiA+ID4gcmVzZXQNCj4gPiA+ID4g
dG8gemVyby4NCj4gPiA+ID4gDQo+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVz
dCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KPiA+ID4gPiA+DQo+ID4gPiA+IC0t
LQ0KPiA+ID4gPiBuZXQvc3VucnBjL2NsbnQuYyB8IDEgLQ0KPiA+ID4gPiBuZXQvc3VucnBjL3hw
cnQuYyB8IDEgKw0KPiA+ID4gPiAyIGZpbGVzIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRl
bGV0aW9uKC0pDQo+ID4gPiA+IA0KPiA+ID4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9jbG50
LmMgYi9uZXQvc3VucnBjL2NsbnQuYw0KPiA+ID4gPiBpbmRleCAyNGNiZGRjNDRjODguLjIxODlm
YmM0YzU3MCAxMDA2NDQNCj4gPiA+ID4gLS0tIGEvbmV0L3N1bnJwYy9jbG50LmMNCj4gPiA+ID4g
KysrIGIvbmV0L3N1bnJwYy9jbG50LmMNCj4gPiA+ID4gQEAgLTE3MzgsNyArMTczOCw2IEBAIHJw
Y194ZHJfZW5jb2RlKHN0cnVjdCBycGNfdGFzayAqdGFzaykNCj4gPiA+ID4gCXhkcl9idWZfaW5p
dCgmcmVxLT5ycV9yY3ZfYnVmLA0KPiA+ID4gPiAJCSAgICAgcmVxLT5ycV9yYnVmZmVyLA0KPiA+
ID4gPiAJCSAgICAgcmVxLT5ycV9yY3ZzaXplKTsNCj4gPiA+ID4gLQlyZXEtPnJxX2J5dGVzX3Nl
bnQgPSAwOw0KPiA+ID4gDQo+ID4gPiBJIGFncmVlIHRoaXMgbGluZSBpcyBub3Qgc3VmZmljaWVu
dCwgYW5kIGl0IHNob3VsZCBiZSBtb3ZlZC4NCj4gPiA+IE5vdCBldmVyeSByZXRyYW5zbWlzc2lv
biByZXF1aXJlcyBhIHJlLWVuY29kZS4gSG93ZXZlciwgdGhlDQo+ID4gPiBwYXRjaCBkZXNjcmlw
dGlvbiBzaG91bGQgZXhwbGFpbiB0aGF0LCBhbmQgaXQgcHJvYmFibHkgbmVlZHMNCj4gPiA+IGEg
Rml4ZXM6IHRhZy4NCj4gPiA+IA0KPiA+ID4gQ2FuIHlvdSBub3cgYWxzbyByZW1vdmUgdGhlIHNh
bWUgbGluZSBmcm9tIHhwcnRfcmVxdWVzdF9pbml0DQo+ID4gPiBhbmQgeHBydF9pbml0X2JjX3Jl
cXVlc3QgPw0KPiA+ID4gDQo+ID4gPiBBbHNvLCBJIG5vdGljZSB0aGF0IFVEUCBkb2VzIG5vdCB0
b3VjaCBycV9ieXRlc19zZW50LiBTaW5jZQ0KPiA+ID4gUkRNQSBhbHNvIGRvZXMgbm90IHVzZSBy
cV9ieXRlc19zZW50LCBtYXliZSB0aGUgc2FtZSBsaW5lDQo+ID4gPiBjYW4gYmUgcmVtb3ZlZCBm
cm9tIHhwcnRyZG1hL3RyYW5zcG9ydC5jIGFuZA0KPiA+ID4geHBydHJkbWEvYmFja2NoYW5uZWwu
YyA/DQo+ID4gDQo+ID4gU3VyZS4NCj4gPiANCj4gPiBTbyBwbGVhc2Ugbm90ZSB0aGF0IHJxX2J5
dGVzX3NlbnQgPT0gMCBubyBsb25nZXIgbWVhbnMgInRoaXMNCj4gPiByZXF1ZXN0DQo+ID4gbmVl
ZHMgdG8gYmUgcmV0cmFuc21pdHRlZCIgYW5kIHdlIG5vIGxvbmdlciB0ZXN0IGZvciBpdCBpbg0K
PiA+IG5ldC9zdW5ycGMvY2xudC5jLiBXZSBkbyBzdGlsbCBoYXZlIGEgY291cGxlIG9mIHRlc3Rz
IG9mDQo+ID4gcnFfYnl0ZXNfc2VudA0KPiA+IGluIG5ldC9zdW5ycGMveHBydC5jIGFuZCBuZXQv
c3VucnBjL3hwcnRzb2NrLmMsIGJ1dCB0aG9zZSBhcmUgbW9yZQ0KPiA+IGFib3V0IGNoZWNraW5n
IGlmIGEgdHJhbnNtaXNzaW9uIG9mIHRoYXQgcmVxdWVzdCBpcyBjdXJyZW50bHkgaW4NCj4gPiBw
cm9ncmVzcywgaW4gd2hpY2ggY2FzZSB3ZSBkb24ndCB3YW50IHRvIHF1ZXVlIGFueXRoaW5nIGlu
IGZyb250IG9mDQo+ID4gaXQNCj4gPiBvbiB0aGUgdHJhbnNtaXNzaW9uIHF1ZXVlLCBhbmQgd2Ug
ZG9uJ3Qgd2FudCB0byBhYm9ydCB0aGUNCj4gPiB0cmFuc21pc3Npb24NCj4gPiB1bmxlc3Mgd2Ug
YWxzbyBjbG9zZSB0aGUgc29ja2V0Lg0KPiANCj4gSSB0aGluayBycV9ieXRlc19zZW50IGlzIGFs
bCBhYm91dCBtYW5hZ2luZyBzZW5kcyBhdG9taWNhbGx5LiBPbg0KPiBzdHJlYW0NCj4gdHJhbnNw
b3J0cyAod2hpY2ggYWxsb3cgYnVmZmVyaW5nIHBhcnRpYWwgc2VnbWVudHMpLCBpdCB3b3VsZCBi
ZQ0KPiBmYXRhbCANCj4gdG8gYWxsb3cgaW50ZXJtaW5nbGluZy4gT24gZGF0YWdyYW0gdHJhbnNw
b3J0cywgaXQncyBhIG5vbi1pc3N1ZQ0KPiBzaW5jZQ0KPiBubyBzZW5kcyBhcmUgZXZlciBwYXJ0
aWFsLg0KPiANCj4gSU9XLCBjb3VsZG4ndCBycV9ieXRlc19zZW50IHNpbXBseSBiZSBhIGJvb2xl
YW4/DQoNClNlbmRzIGNhbiBiZSBwYXJ0aWFsIGZvciBUQ1AgYW5kIEFGX0xPQ0FMIGJlY2F1c2Ug
dGhlIHN0cmVhbSBzb2NrZXQNCm9wZXJhdGlvbnMgYXJlIG5vbi1ibG9ja2luZy4NCg0KU3RyaWN0
bHkgc3BlYWtpbmcsIHRob3VnaCwgd2UgcHJvYmFibHkgY291bGQgcmVwbGFjZSBycV9ieXRlc19z
ZW50IHdpdGgNCmEgYm9vbGVhbiB0aGF0IHJlcHJlc2VudHMgInRyYW5zbWlzc2lvbiBpbiBwcm9n
cmVzcyIgc2luY2UgdGhlIFRDUA0KbGF5ZXIgaXRzZWxmIG5vdyB0cmFja3MgaG93IG1hbnkgYnl0
ZXMgaGF2ZSBiZWVuIHRyYW5zbWl0dGVkIGZvciB0aGUNCnJlcXVlc3QgYmVpbmcgdHJhbnNtaXR0
ZWQuIGkuZS4gdGhlIGJvb2xlYW4gd291bGQgYmUgc2V0IGJ5DQp4c19sb2NhbF9zZW5kX3JlcXVl
c3QoKSBhbmQgeHNfdGNwX3NlbmRfcmVxdWVzdCgpLCBhbmQgY2xlYXJlZCBieSB0aG9zZQ0Kc2Ft
ZSBmdW5jdGlvbnMgb25jZSB0aGUgdHJhbnNtaXNzaW9uIGlzIGNvbXBsZXRlLiBNZWguLi4NCg0K
DQo+IFRvbS4NCj4gDQo+ID4gVGhlIGludGVudGlvbiBub3cgaXMgdGhhdCBpZiB3ZSBrbm93IHRo
ZSByZXF1ZXN0IG5lZWRzDQo+ID4gcmV0cmFuc21pc3Npb24NCj4gPiAoZHVlIHRvIGEgdHJhbnNw
b3J0IGNvbm5lY3Rpb24gbG9zcyBvciBhIHRpbWVvdXQpLCB0aGVuIHdlIGp1c3QgYWRkDQo+ID4g
aXQNCj4gPiB0byB0aGUgdHJhbnNtaXNzaW9uIHF1ZXVlLg0KPiA+IA0KPiA+IA0KPiA+ID4gPiAJ
cCA9IHJwY19lbmNvZGVfaGVhZGVyKHRhc2spOw0KPiA+ID4gPiAJaWYgKHAgPT0gTlVMTCkgew0K
PiA+ID4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy94cHJ0LmMgYi9uZXQvc3VucnBjL3hwcnQu
Yw0KPiA+ID4gPiBpbmRleCA3MzU0N2QxN2QzYzYuLjkwNzVhZTE1MGFlNSAxMDA2NDQNCj4gPiA+
ID4gLS0tIGEvbmV0L3N1bnJwYy94cHJ0LmMNCj4gPiA+ID4gKysrIGIvbmV0L3N1bnJwYy94cHJ0
LmMNCj4gPiA+ID4gQEAgLTExNTEsNiArMTE1MSw3IEBAIHhwcnRfcmVxdWVzdF9lbnF1ZXVlX3Ry
YW5zbWl0KHN0cnVjdA0KPiA+ID4gPiBycGNfdGFzaw0KPiA+ID4gPiAqdGFzaykNCj4gPiA+ID4g
CXN0cnVjdCBycGNfeHBydCAqeHBydCA9IHJlcS0+cnFfeHBydDsNCj4gPiA+ID4gDQo+ID4gPiA+
IAlpZiAoeHBydF9yZXF1ZXN0X25lZWRfZW5xdWV1ZV90cmFuc21pdCh0YXNrLCByZXEpKSB7DQo+
ID4gPiA+ICsJCXJlcS0+cnFfYnl0ZXNfc2VudCA9IDA7DQo+ID4gPiA+IAkJc3Bpbl9sb2NrKCZ4
cHJ0LT5xdWV1ZV9sb2NrKTsNCj4gPiA+ID4gCQkvKg0KPiA+ID4gPiAJCSAqIFJlcXVlc3RzIHRo
YXQgY2FycnkgY29uZ2VzdGlvbiBjb250cm9sDQo+ID4gPiA+IGNyZWRpdHMgYXJlDQo+ID4gPiA+
IGFkZGVkDQo+ID4gPiANCj4gPiA+IFNvIEknbSBub3QgY29udmluY2VkIHRoaXMgY292ZXJzIGV2
ZXJ5IGNhc2UuIEkgbmVlZCBzb21lDQo+ID4gPiB0aW1lIHRvIGludmVzdGlnYXRlLg0KPiA+IA0K
PiA+IEl0IHNob3VsZCBub3JtYWxseSBjb3ZlciBhbGwgY2FzZXMuIEFzIEkgc2FpZCwgdGhlIG9u
bHkgcmVtYWluaW5nDQo+ID4gdGVzdHMNCj4gPiBhcmUgaW4geHBydC5jIGFuZCAgeHBydHNvY2su
Yw0KPiA+IA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkNUTywgSGFtbWVyc3BhY2UgSW5jDQo0MzAw
IEVsIENhbWlubyBSZWFsLCBTdWl0ZSAxMDUNCkxvcyBBbHRvcywgQ0EgOTQwMjINCnd3dy5oYW1t
ZXIuc3BhY2UNCg0K
