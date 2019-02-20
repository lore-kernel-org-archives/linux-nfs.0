Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54F48C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 14:23:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1B76A20880
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 14:23:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="wlhG0t/e"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726470AbfBTOXR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 09:23:17 -0500
Received: from mail-eopbgr820133.outbound.protection.outlook.com ([40.107.82.133]:54702
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726030AbfBTOXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 09:23:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Qx7DBEgkDrwhtIbmDfm7jbF5HVX/ZC/S8DTPqY4M+s8=;
 b=wlhG0t/e04sX70QRnpDmjTuk/gAaheNP+3YLj4nTGb1dlhSjUf//ipR8kNrBbCyigMV5QxSDVE1766vOYYW6Pc+COCV838x8uqdeqjPtb9cd/HiN7T+AeY0CeiqvRWAZ3k8IbeBTQtCsR4hvRY1k3Mvutzv/V/1Q/HubQChub+U=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2239.namprd13.prod.outlook.com (52.135.93.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Wed, 20 Feb 2019 14:23:07 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Wed, 20 Feb 2019
 14:23:07 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "dhowells@redhat.com" <dhowells@redhat.com>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "linux-security-module@vger.kernel.org" 
        <linux-security-module@vger.kernel.org>,
        "containers@lists.linux-foundation.org" 
        <containers@lists.linux-foundation.org>,
        "rgb@redhat.com" <rgb@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "sfrench@samba.org" <sfrench@samba.org>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
Thread-Topic: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
Thread-Index: AQHUxUiT7tBSOC7mDUKxIxjQa5zKdKXkWswAgANpT4CAAQDqgA==
Date:   Wed, 20 Feb 2019 14:23:07 +0000
Message-ID: <28cdcdbad0bfa048a323c7767e0aa78e281eded2.camel@hammerspace.com>
References: <8c95213ae0981bd7af928902fcb34d6a9dedaa6f.camel@hammerspace.com>
         <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
         <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
         <19411.1550617413@warthog.procyon.org.uk>
In-Reply-To: <19411.1550617413@warthog.procyon.org.uk>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3411e95c-dab5-4944-7e64-08d6973eef3f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2239;
x-ms-traffictypediagnostic: SN6PR13MB2239:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMjM5OzIzOlVPNEV2YlduaGJ0RnJnNUIzOVZNcW0rTHZu?=
 =?utf-8?B?aUpPSTR4NjFtbHpBMzJhK1pFR2gza0ZYMDhNRzcrNVpyWWcxV09jckk0bzR4?=
 =?utf-8?B?bjJJWGFVQWFoZm1PVHVqZEFtNkJjOUVtSE5sUC9wM25RUGRqc0tTcnVKYm9N?=
 =?utf-8?B?Y2tCMHVUYW9KYjdmcUJqVXh6dGJZcmJPY0EyQVE2Vks1emQzMU1CTFdlczhT?=
 =?utf-8?B?TFJJbWRYM0NudERtUE1CdjdOblkxNTNRSnIvNjBNSEdyalZiV3hIVkFKcFJP?=
 =?utf-8?B?MkRmOU1hdEZuK0ExRHV0bjJRQk11MHZsdVBuem10U3dMYWtFUXVEczgxcVBo?=
 =?utf-8?B?VTY3d0lCeGhKVHBGdTJBTlg3YUdicDJSSjVFaEVyU3hyQTZmUjV5SGRZZzlJ?=
 =?utf-8?B?WjAvNlZvVWFBeGJHWFo0WVBjZHdvVS9VOUl4QUluNmN4a3ZMTU8ybjVjamdN?=
 =?utf-8?B?WEtsK21mVmg0Mkd1Z3V1djU4dnBiUFN2alp6cUFKcW93eUU2T0FlL05Edml4?=
 =?utf-8?B?Z0lCV25PWmFqcjVrWFp0L09nSCtXQ01uVytYM0FnVHo3NHhnM1B2bmczNXlC?=
 =?utf-8?B?UldCSmJQM1JFOUZmYy95QnR2emNsTjRvcjhLNFgwaUJkTDc4L1M1M3JYU1R1?=
 =?utf-8?B?UTg1ZnpTakFaemMxRHhlc3F1MjVGaVJ5U2IzNWF5Rkd1MUxHM3JTcHRndE5o?=
 =?utf-8?B?T2hSTEVDcnVYbHFtcWh3MWlPUy91Y0J4YU90OGFtV0h4UGl4K3NMMjdPcHVp?=
 =?utf-8?B?eG9lZ2x4aHBNTTRPYWtyWFpacnlZZDNqR2pIK2M4NGZ5YVFqdEtZN2J4c3lZ?=
 =?utf-8?B?OExkNnpMYnBWMHgxdlRrZTlLenQrUkwyQzhYVmxQMmRQdm1sSjlFYldPcUVP?=
 =?utf-8?B?VWlCcmRYMGNPUzJmVk4yd1NLRUYvZ2xTWkd6Mll5R2NMZHl3YllJYWY5OUJ5?=
 =?utf-8?B?MzNvSHN0MnBib040eURuSitxbm13anJOY2gzY0h3bWJXSTlnVnZraDUrd2g5?=
 =?utf-8?B?UmJabTRONkhQVng5Tm5oRDhlRHV0cDhLczZycnlaUW5rbkd6NGVqc0lGQlhN?=
 =?utf-8?B?QjJOenRMVnRtNFJia0poQy9obHRKR243V1lCTlZ0QkNBalJqZXBqSU9Qb2Yv?=
 =?utf-8?B?Y3p5T3NxK2cwbkgrUHVYR0pxY05KTG5xOVh0Z1FhNHNZL1NKcEZnTjBabEFp?=
 =?utf-8?B?aDBOZldtYWJrN09zMWk5aTg3VTVReC9TZXl0b20xeVcyYVFmTUxnVWsyWS9k?=
 =?utf-8?B?MDZUWjZneFdBRDFsTmhkMUZTUHBtd2lFNFZRcG1hMFAyeGNiSmlha3FVclFQ?=
 =?utf-8?B?ejlYSFJZalBneVpNbk5UYWdoci9KdHRTRkFSZ1ZXYUFaZndvSlFzM2hXK083?=
 =?utf-8?B?amNoK09FSWVKemdDYmY2Tmwzc1V0ZWxTNS9zRGFWbkExdXB4U1RPZzZxdGZi?=
 =?utf-8?B?RjdvOFBDK2RMSkxFb05BWjRxU2M5aS93RUs3Y1F1dWdRbU9CMzFkWi84ZFpz?=
 =?utf-8?B?ZUZ1cldDRXEyc05kR3ZUdTFPd0pTb3h5MzRlSVQ1T0FFZWN0U3FnQ0R2b2pE?=
 =?utf-8?B?R24rVGdkNmhRZ0lCaFZaZ25mM0hMZU5Fbm9lMnhxN0xYdFR2WUtqRFNGR2do?=
 =?utf-8?B?M3RPdFp4SXFKTC9GMWdmNEpDZ3ZoajFQV01GZ1ljNEhxODNUN0RpN1kzWFlM?=
 =?utf-8?B?eENPakhSMko2dWErcjlmSjhUeUw0M2Z0ZGdsRGZnVFNJMkZzWDlvWlpJRXhh?=
 =?utf-8?B?MjBrblhpK0gwZUZ5ZUhxVURiZTQxQTBKd1Z1MDRYVTNIQ2tvTFVnSTZEWFd3?=
 =?utf-8?B?WUI1azVtYVY1OFBaVmkxTkhEYVYzVmRGR2picS8rR25sa1VGVjFiQkRHUnNK?=
 =?utf-8?Q?hk1zUtHjvLHU1yDxyrICQuOivPpS2XFe?=
x-microsoft-antispam-prvs: <SN6PR13MB223989EBFA5BF5FD3D8F1D7AB87D0@SN6PR13MB2239.namprd13.prod.outlook.com>
x-forefront-prvs: 0954EE4910
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(39830400003)(366004)(136003)(396003)(52314003)(189003)(199004)(25786009)(2501003)(6512007)(4326008)(6486002)(6116002)(53936002)(3846002)(36756003)(229853002)(6436002)(305945005)(15974865002)(8936002)(1730700003)(5640700003)(8676002)(86362001)(106356001)(105586002)(76176011)(7736002)(486006)(68736007)(81166006)(81156014)(478600001)(102836004)(2351001)(26005)(316002)(6506007)(186003)(5660300002)(54906003)(2616005)(446003)(476003)(6916009)(14454004)(11346002)(71190400001)(71200400001)(93886005)(7416002)(97736004)(6246003)(99286004)(118296001)(14444005)(256004)(66066001)(217873002)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2239;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: shmrVKpW8uGbFyi+/rYY6V802zWL6P5igqzvOjc8PkbP0hfdYchGaVyIntIG6MXe8Ycn/uu9aCGXijxVYYamNzPrLJME2wHZWOPIt4U/oB+Usp+AKzMQDF1yVGH2IVaNbra2jTrp9w7vUZ4MmrfgoMts6R5JxJKae5iAMsVH3x3kZC+dvzxQntxAk2ELYl/Hg7GjIvG9P/l6IWG4hkniN845iD+jnr+EEz89pWYJHhtMVyRONfBaR2yjvJ2tJZWZSG71bExuOPwlIE7O9Au/omRI1TcIRdgo898jp9XUOzCXN/Avog/4iOZ9VHDGi0H46OzjrMUcrTU+LlfwjEHxmp5uYFy4bE2d7OwsGlnJqfT4v+zxD5zu/mAPRmm0Bm4ivHFZ1i4H2WQWmsQV9Ep1cc/JkDrEVdAn7gD/zNFWnCY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <90DA0BB5F26B324D9C62938D30A65ABA@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3411e95c-dab5-4944-7e64-08d6973eef3f
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2019 14:23:07.6075
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2239
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAyLTE5IGF0IDIzOjAzICswMDAwLCBEYXZpZCBIb3dlbGxzIHdyb3RlOg0K
PiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gDQo+
ID4gRG8gd2UgcmVhbGx5IG5lZWQgYSBuZXcgc3lzdGVtIGNhbGwgdG8gc2V0IHVwIGNvbnRhaW5l
cnM/IFRoYXQNCj4gPiB3b3VsZA0KPiA+IGZvcmNlIGNoYW5nZXMgdG8gYWxsIGV4aXN0aW5nIG9y
Y2hlc3RyYXRpb24gc29mdHdhcmUuDQo+IA0KPiBObywgaXQgd291bGRuJ3QuICBOb3RoaW5nIGlu
IG15IHBhdGNoZXMgZm9yY2VzIGV4aXN0aW5nIG9yY2hlc3RyYXRpb24NCj4gc29mdHdhcmUNCj4g
dG8gY2hhbmdlLCB1bmxlc3MgaXQgd2FudHMgdG8gdXNlIHRoZSBuZXcgZmFjaWxpdGllcyAtIHRo
ZW4gaXQgd291bGQNCj4gaGF2ZSB0bw0KPiBiZSBjaGFuZ2VkIGFueXdheSwgcmlnaHQ/ICBJIHdp
bGwgZ3JhbnQsIHRob3VnaCwgdGhhdCB0aGUgZXh0ZW50IG9mDQo+IHRoZSBjaGFuZ2UNCj4gbWln
aHQgdmFyeS4NCg0KUmlnaHQuIEl0IGRlcGVuZHMgb24gd2hhdCB5b3Ugd2FudCB0byB0aGUgb3Jj
aGVzdHJhdG9yIHRvIGRvLiBJZiB5b3UNCndhbnQgaXQgdG8gbWFuYWdlIGF1dGhlbnRpY2F0ZWQg
c3RvcmFnZSBmb3IgeW91LCB0aGVuIEkgZ3JhbnQgdGhhdCB5b3UNCm1heSBuZWVkIHRvIGNoYW5n
ZSB0aGUgZXhpc3Rpbmcgb3JjaGVzdHJhdG9yLiBIb3dldmVyIGlmIHlvdSBqdXN0IHdhbnQNCnRo
ZSBjb250YWluZXJpc2VkIHNvZnR3YXJlIHRvIGJlIGFibGUgdG8gbWFuYWdlIEFGUy9DSUZTLy4u
LiBrZXlzIGZvcg0KaXRzIG93biBwcm9jZXNzZXMsIHRoZW4gaXQncyBub3Qgb2J2aW91cyB0byBt
ZSB3aHkgeW91IHdvdWxkIG5lZWQgYSBuZXcNCm9yY2hlc3RyYXRvci4NCg0KPiA+IEdpdmVuIHRo
YXQgdGhlIG1haW4gdGhpbmcgd2Ugd2FudCB0byBhY2hpZXZlIGlzIHRvIGRpcmVjdCBtZXNzYWdl
cw0KPiA+IGZyb20NCj4gPiB0aGUga2VybmVsIHRvIGFuIGFwcHJvcHJpYXRlIGhhbmRsZXIsIHdo
eSBub3QgZm9jdXMgb24gYWRkaW5nDQo+ID4gZnVuY3Rpb25hbGl0eSB0byBkbyBqdXN0IHRoYXQ/
DQo+IA0KPiBCZWNhdXNlIGl0J3MgKm5vdCoganVzdCB0aGF0IHRoYXQgaXMgYWRkZWQgaGVyZS4g
IFRoZXJlIGFyZSBhIG51bWJlcg0KPiBvZiB0aGluZ3MNCj4gdGhpcyBwYXRjaHNldCAoYW5kIG9u
ZSBpdCBkZXBlbmRzIG9uKSBwcm92aWRlczoNCj4gDQo+ICAoMSkgVGhlIGFiaWxpdHkgdG8gaW50
ZXJjZXB0IHJlcXVlc3Rfa2V5KCkgdXBjYWxscyB0aGF0IGhhcHBlbg0KPiBpbnNpZGUgYQ0KPiAg
ICAgIGNvbnRhaW5lciwgZmlsdGVyZWQgYnkgb3BlcmF0aXZlIG5hbWVzcGFjZS4NCg0KVGhlIHJl
cXVpcmVtZW50IHRoYXQgeW91IG5lZWQgdG8gZmlsdGVyIGRlcml2ZXMgZnJvbSB0aGUgZmFjdCB0
aGF0IHRoZQ0Ka2VybmVsIGlzIGJlaW5nIGZvcmNlZCB0byBydW4gYW4gdW50cnVzdGVkIGV4ZWN1
dGFibGUgaW4gdXNlciBzcGFjZS4NClRoYXQgbWF5IGJlIGFjY2VwdGFibGUgd2hlbiBydW5uaW5n
IGluIGFuIHVuY29udGFpbmVyaXNlZCBlbnZpcm9ubWVudCwNCndoZXJlIHRoZSBleGVjdXRhYmxl
IGNhbiBiZSB2ZXR0ZWQgYnkgdGhlIHN5c2FkbWluLCBidXQgaXQgY2xlYXJseQ0KaXNuJ3QgaW4g
YW4gZW52aXJvbm1lbnQgd2hlcmUgY29udGFpbmVycyBjYW4gYmUgc2V0IHVwIGJ5IHVudHJ1c3Rl
ZA0KdXNlcnMuDQoNCklmIHdlIHJlcGxhY2UgdGhlIGV4ZWN1dGFibGUgd2l0aCBhIGRhZW1vbiB0
aGF0IGlzIHN0YXJ0ZWQgZnJvbSBpbnNpZGUNCnRoZSBjb250YWluZXIgKHByZXN1bWFibHkgYnkg
dGhlIGluaXQgcHJvY2VzcyBydW5uaW5nIHRoZXJlKSwgdGhlbg0KdGhlcmUgc2hvdWxkIGJlIG5v
IHJlcXVpcmVtZW50IGZvciB0aGUgb3JjaGVzdHJhdG9yIHRvIGZpbHRlci4NCg0KPiAgKDIpIFRo
ZSBhYmlsaXR5IHRvIHByb3ZpZGUgYSBwZXItY29udGFpbmVyIGtleXJpbmcgdGhhdCBjYW4gaG9s
ZA0KPiBrZXlzIHRoYXQNCj4gICAgICBjYW4gYmUgdXNlZCBpbnNpZGUgdGhlIGNvbnRhaW5lciB3
aXRob3V0IGFueSBhY3Rpb24gb24gYmVoYWxmIG9mDQo+IHRoZQ0KPiAgICAgIGRlbml6ZW5zIG9m
IHRoZSBjb250YWluZXIuDQoNCktleXJpbmdzIGFscmVhZHkgZGVmaW5lIHNvbWUgaW5oZXJpdGFu
Y2Ugc2VtYW50aWNzIGZvciBjaGlsZCBwcm9jZXNzZXMuDQpXaHkgY2FuJ3Qgd2UgdHdlYWsgdGhv
c2Ugc2VtYW50aWNzIHRvIGRvIHdoYXQgaXMgbmVlZGVkPw0KDQpJT1c6IGluc3RlYWQgb2YgYWRk
aW5nIGEgY29udGFpbmVyIHN5c2NhbGwgYW5kIGEgbmV3IGtleXJpbmcgdHlwZSwgd2h5DQpjYW4n
dCB3ZSBqdXN0IGRlZmluZSB0aGUgcmVxdWlyZWQga2V5cmluZyB0eXBlIGFuZCBsZXQgaXQgYmUg
aW5oZXJpdGVkDQp0aHJvdWdoIHRoZSBleGlzdGluZyBjbG9uZSgpIG1lY2hhbmlzbT8NCg0KPiAg
KDMpIFRoZSBhYmlsaXR5IHRvIGdyYW50IHBlcm1pc3Npb25zIHRvIGEgKmNvbnRhaW5lciogYXMg
YSBzdWJqZWN0LA0KPiBhbGxvd2luZw0KPiAgICAgIGl0IGFuZCBpdHMgZGVuaXplbnMgdG8gdXNl
LCBidXQgbm90IG5lY2Vzc2FyaWx5IHJlYWQsIG1vZGlmeSwNCj4gbGluayBvcg0KPiAgICAgIGlu
dmFsaWRhdGUgYSBrZXkuDQoNCkFnYWluLCB0aGlzIHNvdW5kcyBsaWtlIGEgY2hpbGQgcHJvY2Vz
cyBrZXlyaW5nIGluaGVyaXRhbmNlIGlzc3VlLg0KUmlnaHQgbm93LCB0aGUgc2Vzc2lvbiBrZXly
aW5nIGRvZXMgbm90IGFwcGVhciB0byBtYXRjaCB0aGUgc2VtYW50aWNzDQp0aGF0IHlvdSBkZXNj
cmliZSwgYnV0IHdoeSBjb3VsZG4ndCB3ZSBzZXQgdXAgYSBuZXcga2V5cmluZyB0eXBlIHRoYXQN
CmNhbiBwcm92aWRlIHRoZW0/DQoNCj4gICg0KSBUaGUgYWJpbGl0eSB0byBjcmVhdGUgc3VwZXJi
bG9ja3MgaW5zaWRlIGEgY29udGFpbmVyIHdpdGggYQ0KPiBzZXBhcmF0ZQ0KPiAgICAgIG1vdW50
IG5hbWVzcGFjZSBmcm9tIG91dHNpZGUsIHN1Y2ggdGhhdCB0aGV5IGNhbiB1c2UgdGhlDQo+IGNv
bnRhaW5lciBrZXlzLA0KPiAgICAgIHRoZXJlYnkgYWxsb3dpbmcgdGhlIHJvb3Qgb2YgYSBjb250
YWluZXIgdG8gYmUgb24gYW4NCj4gYXV0aGVudGljYXRlZA0KPiAgICAgIGZpbGVzeXN0ZW0uDQo+
IA0KDQpJJ20gbm90IHN1cmUgdGhhdCBJIHVuZGVyc3RhbmQgdGhlIHByZW1pc2UuIElmIHRoZSBv
cmNoZXN0cmF0b3IgaXMNCnNldHRpbmcgdXAgYW5kIG1hbmFnaW5nIHRoYXQgYXV0aGVudGljYXRl
ZCByb290IGZpbGVzeXN0ZW0sIHRoZW4gd2h5IGRvDQp0aGUgY29udGFpbmVyaXNlZCBwcm9jZXNz
ZXMgbmVlZCB0byBiZSBpbnZvbHZlZCBhdCBhbGw/DQoNCklmLCBPVE9ILCB0aGUgaW50ZW50aW9u
IGlzIHRvIGFsbG93IHRoZSBjb250YWluZXJpc2VkIHByb2Nlc3NlcyB0bw0KbWFuYWdlIHRoZSBm
aWxlc3lzdGVtcyB3aXRob3V0IGtub3dsZWRnZSBvZiB0aGUga2V5cmluZyBjb250ZW50cywgdGhl
bg0KYWdhaW4gaXNuJ3QgdGhhdCByZWFsbHkgdGhlIHNhbWUgaXNzdWUgYXMgKDMpPw0KDQo+ID4g
SXMgdGhlcmUgYW55IHJlYXNvbiB3aHkgYSBzeXNjYWxsIHRvIGFsbG93IGFuIGFwcHJvcHJpYXRl
bHkNCj4gPiBwcml2aWxlZ2VkDQo+ID4gcHJvY2VzcyB0byBhZGQgYSBrZXlyaW5nLXNwZWNpZmlj
IG1lc3NhZ2UgcXVldWUgdG8gaXRzIG93bg0KPiA+IHVzZXJfbmFtZXNwYWNlIGFuZCBvYnRhaW4g
YSBmaWxlIGRlc2NyaXB0b3IgdG8gdGhhdCBtZXNzYWdlIHF1ZXVlDQo+ID4gbWlnaHQNCj4gPiBu
b3Qgd29yaz8NCj4gDQo+IFllcy4gIFRoYXQgZm9yY2VzIHRoZSB1c2Ugb2YgYSBuZXcgdXNlcl9u
YW1lc3BhY2UgZm9yIGV2ZXJ5IGNvbnRhaW5lcg0KPiBpbiB3aGljaA0KPiB5b3Ugd2FudCB0byB1
c2UgYW55IG9mIHRoZSBhYm92ZSBmZWF0dXJlcy4gIFRoZSB1c2VyX25hbWVzcGFjZSBpcw0KPiBh
bHJlYWR5IHdheQ0KPiB0b28gYmlnIGFuZCBpbnRydXNpdmUgYSBoYW1tZXIgYXMgaXQgaXMuDQoN
Ck5vLiBJIHdvdWxkIG5lZWQgYSB1c2VyX25hbWVzcGFjZSBpZiBJIHdhbnQgdG8gYWxsb3cgY2hp
bGQgcHJvY2Vzc2VzIHRvDQpoYW5kbGUgcmVxdWVzdCB1cGNhbGxzLiBJcyB0aGF0IHVucmVhc29u
YWJsZT8NCg0KPiA+IFdpdGggc3VjaCBhbiBpbXBsZW1lbnRhdGlvbiwgdGhlIGZhbGxiYWNrIG1l
Y2hhbmlzbSBjb3VsZCBiZSB0bw0KPiA+IHdhbGsNCj4gPiBiYWNrIHVwIHRoZSBoaWVyYXJjaHkg
b2YgdXNlcl9uYW1lc3BhY2VzIHVudGlsIGEgbWVzc2FnZSBxdWV1ZSBpcw0KPiA+IGZvdW5kLCBh
bmQgdG8gaW52b2tlIHRoZSBleGlzdGluZyByZXF1ZXN0X2tleSBtZWNoYW5pc20gaWYgbm90Lg0K
PiANCj4gVGhhdCdzIGRlZmluaXRlbHkgd3JvbmcuICAvc2Jpbi9yZXF1ZXN0LWtleSBzaG91bGQg
Km5vdCogYmUgc3Bhd25lZA0KPiBpZiB0aGUga2V5DQo+IHRvIGJlIGluc3RhbnRpYXRlZCBpcyBu
b3QgaW4gYWxsIHRoZSBpbml0IG5hbWVzcGFjZXMuDQo+IA0KPiBJIHdlbnQgd2l0aCBhIGNvbnRh
aW5lciBvYmplY3Qgd2l0aCBuYW1lc3BhY2VzIGZvciBhIHJlYXNvbjoNCj4gaW5pdGlhbGx5LCBp
dCB3YXMNCj4gc28gdGhhdCB0aGUgdXBjYWxsIGNvdWxkIHRha2UgcGxhY2UgaW5zaWRlIG9mIHRo
ZSBjb250YWluZXIncw0KPiBuYW1lc3BhY2VzLCBidXQNCj4gbm93IGl0J3MgZG8gdGhhdCBhbnkg
cmVxdWVzdCB0aGF0IGRvZXNuJ3QgbWF0Y2ggdGhlIG5hbWVzcGFjZXMgb24gdGhlDQo+IGNvbnRh
aW5lciBnZXRzIHJlamVjdGVkIGF0IHRoZSBib3VuZGFyeSAtIHNvIHRoYXQgc29tZSBkYWVtb24g
dXAgdGhlDQo+IGNoYWluDQo+IGRvZXNuJ3QgdHJ5IHNlcnZpY2luZyBhIHJlcXVlc3QgZm9yIHdo
aWNoIGl0IGNhbid0IGFjY2VzcyB0aGUgY29uZmlnDQo+IGRhdGEgb3INCj4gd291bGQgZW5kIHVw
IHRhbGtpbmcgb3V0IG9mIHRoZSB3cm9uZyBOSUMuDQo+IA0KPiBJIGNhbiBkcm9wIHRoZSBjb250
YWluZXIgb2JqZWN0IHBhcnQgb2YgaXQgZm9yIHRoZSBtb21lbnQuDQo+IA0KPiBJIGNvdWxkIGlu
c3RlYWQgY3JlYXRlIDEtMyBuZXcgbmFtZXNwYWNlczoNCj4gDQo+ICAoMSkgQSBuYW1lc3BhY2Ug
d2l0aCBhbiB1cGNhbGwtaW50ZXJjZXB0aW9uIHBvaW50Lg0KPiANCj4gICgyKSBBIG5hbWVzcGFj
ZSB3aXRoIGEgY29udGFpbmVyIGtleXJpbmcuDQo+IA0KPiAgKDMpIEEgbmFtZXNwYWNlIHdpdGgg
YSBzdWJqZWN0IElEIGZvciB1c2UgaW4ga2V5IEFDTHMuDQo+IA0KPiBJIHRoaW5rIEkgc2hvdWxk
IGFsc28gY29uc2lkZXIgYWRkaW5nOg0KPiANCj4gICg0KSBBIG5hbWVzcGFjZSB3aXRoIGtleXJp
bmcgbmFtZXMgaW4gaXQuICBJJ20gbGVhbmluZyB0b3dhcmRzIHRoaXMNCj4gbm90IGJlaW5nDQo+
ICAgICAgcGFydCBvZiB1c2VyX25hbWVzcGFjZSBiZWNhdXNlIHRoZXNlIHByb2JhYmx5IHNob3Vs
ZCBub3QgYmUNCj4gdmlzaWJsZQ0KPiAgICAgIGJldHdlZW4gY29udGFpbmVycy4NCj4gDQo+IERh
dmlkDQotLSANClRyb25kIE15a2xlYnVzdA0KQ1RPLCBIYW1tZXJzcGFjZSBJbmMNCjQzMDAgRWwg
Q2FtaW5vIFJlYWwsIFN1aXRlIDEwNQ0KTG9zIEFsdG9zLCBDQSA5NDAyMg0Kd3d3LmhhbW1lci5z
cGFjZQ0KDQoNCg==
