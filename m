Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1905C41518
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 19:14:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B2ABD218D0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 19:14:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="gyH679uZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725976AbfAYTOK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 14:14:10 -0500
Received: from mail-eopbgr790071.outbound.protection.outlook.com ([40.107.79.71]:43089
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725778AbfAYTOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jan 2019 14:14:09 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UU3tyQObeR3HvNgDmsXsELNVVhU3ydnXal1LHqB5dOw=;
 b=gyH679uZYJ6D/xuJXHDkGLG45/vIbyZ9Qt5P5/i73hbSZIoCWVEM2OknlgbFAMXe5mtsxFhEOjZ/EkYHFUq3avOrZ+0vba9xSyXHkqbuQD5mvD/q9IPVaxmlGILQiDBCAbDmkq1u66cGWJmfYC000bWdEH5gogZJZ5MR620F4XI=
Received: from BN8PR06MB6228.namprd06.prod.outlook.com (20.178.217.156) by
 BN8PR06MB5889.namprd06.prod.outlook.com (20.179.139.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.21; Fri, 25 Jan 2019 19:13:27 +0000
Received: from BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::f88b:ea19:e85a:ab8]) by BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::f88b:ea19:e85a:ab8%3]) with mapi id 15.20.1558.021; Fri, 25 Jan 2019
 19:13:27 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "trondmy@hammerspace.com" <trondmy@hammerspace.com>,
        "Chuck.Lever@oracle.com" <Chuck.Lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Thread-Topic: Need help debugging NFS issues new to 4.20 kernel
Thread-Index: AQHUtBBQLoOJiO8U1kuiVnwIPcpCS6W+1kMAgAGFtAA=
Date:   Fri, 25 Jan 2019 19:13:27 +0000
Message-ID: <56cb3117bdea296892bab4f798d9c84666157afc.camel@netapp.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
         <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
In-Reply-To: <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.4 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [2602:306:3097:450:83a8:291f:68f7:337c]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BN8PR06MB5889;6:Cn7gqMRWjlUzunwiFkO9rsMgrl7t2HQemaDb66PN6LsLDTsWJYihsVx4sGmfMaPCpOjoBKzXTo7pjez0NKcnas2PZFDcdLMTV78u1qVAVIc0v11qplgBqvu9xPXmIoVJtsFJj8fHHtulMuxuxuKbDtQSXbTSSDQpziT1vHoBBQ890tOh111WFuZNJ3YDkcp4t93x2rXkheB6XO8AZUspx63BC54Hu/qfBtbXuEVPiver4FbKp+K1guoMn6sGUTXlkTiVQO3HxBJCBRPabS383GQwiOcD/ybGR5BIT/DjUBdurmqkXciZAwSDIqeCZ+BXs22SCTex2dhCqna2dcmVyVznlbOpbR78iJ+cD0vusIu1yWp4HE7BL82XyKX797WuTD0OC37FxfGrgy0/0nahfIa0lrVlxKXwuskGZNI4v0eF5vXRMInl2JdvPC/NOPabOhxrMqln8FE33oxATvJWOg==;5:y1/HcaKIGCZbuykQgvvn5847F4T+VYAUs4/l1hqOpqn+O4RLfII6bhP06oDChtliDYkpQU6RQUrmukTVkznUMR9d/heztKO2gNPGQlzP/fmsuB91+Jv2FkYZ+EXDOs877I+o+MlFhh7Y3qaLoBf9dFd1FvruzvoJ0g1Td8F/Kq8Pd3jQYCeNYvmeuDCHJylWQNuBJFzuWNdQXlZn2mk35g==;7:cN79v3c/x6fC5cJiW4Btbb39Qwr+24bUB4uzX1VmZ9JJAsRh+xj3uoNzhkEFjh6V19xZx3RU34nvsN1cFLwtoLShghYztMKYMvRQ+ykZR+6ivpC3u/6rx9/24rwKayt04zdXUte1sBvpKD32ToY7Pw==
x-ms-office365-filtering-correlation-id: 3df9bedc-cc2d-44b9-b0c2-08d682f92f93
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7193020);SRVR:BN8PR06MB5889;
x-ms-traffictypediagnostic: BN8PR06MB5889:
x-microsoft-antispam-prvs: <BN8PR06MB588946484D91B4EF7203B841F89B0@BN8PR06MB5889.namprd06.prod.outlook.com>
x-forefront-prvs: 0928072091
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(376002)(39860400002)(366004)(136003)(396003)(346002)(51874003)(189003)(199004)(118296001)(476003)(486006)(446003)(316002)(86362001)(11346002)(6116002)(2501003)(2616005)(76176011)(71190400001)(2201001)(46003)(71200400001)(2906002)(6512007)(68736007)(6436002)(14454004)(105586002)(81156014)(81166006)(8676002)(72206003)(229853002)(186003)(478600001)(6506007)(8936002)(102836004)(106356001)(6246003)(58126008)(7736002)(2171002)(25786009)(97736004)(36756003)(53936002)(6486002)(256004)(99286004)(110136005)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:BN8PR06MB5889;H:BN8PR06MB6228.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: vIaLv5tjZ0wd+dgkLKrK76MuuQAynOoY7DK6sKMXTLatDa3ctjz7sd3h2dCOnxu7kc8UqEHT7waBlM+EV4sZGG7HrsHnYMB24vGMq/qiUO/ajJSnq0MNZMEO14opsNQKKjdNAchH2KyccfG2eBC1kFjsGIUvZRrd56mup4HuZR4Uak8tSLQMnmpjlzheaMOK4TYdrHrmvgq1f276s4/NW+FjTqcu1n812vBHNQn3T8u82oBykGknx6F9eQWKG4B4ZbKTUelBIWTEdHl/5+FTrXLqeFwtnIsDqyLkOWAP6inNycBqvTZDcUn6usxQfzQUjWwmOYjjumXIdzv18VJyXrsBhXt/kWsuiJyJRaF8LupZDPBHwuuQ472T/Pp+dmUR9YjZhZuFOn9q57DnCIyCIhGu3xVq/c6a8P3OpizE+XE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <DEE82ABACA560B47A1BE1F262CD78BD5@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3df9bedc-cc2d-44b9-b0c2-08d682f92f93
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jan 2019 19:13:27.4178
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR06MB5889
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTI0IGF0IDE5OjU4ICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFRodSwgMjAxOS0wMS0yNCBhdCAxMTozMiAtMDYwMCwgSmFzb24gTCBUaWJiaXR0cyBJ
SUkgd3JvdGU6DQo+ID4gSSBjb3VsZCB1c2Ugc29tZSBoZWxwIGZpZ3VyaW5nIG91dCB0aGUgY2F1
c2Ugb2Ygc29tZSBzZXJpb3VzIE5GUw0KPiA+IGNsaWVudA0KPiA+IGlzc3VlcyBJJ20gaGF2aW5n
IHdpdGggdGhlIDQuMjAuMyBrZXJuZWwgd2hpY2ggSSBkaWQgbm90IHNlZSB1bmRlcg0KPiA+IDQu
MTkuMTUuDQo+ID4gDQo+ID4gSSBoYXZlIGEgbmV0d29yayBvZiBhYm91dCAxMzAgZGVza3RvcHMg
KHBsdXMgYSBidW5jaCBvZiBvdGhlcg0KPiA+IG1hY2hpbmVzLA0KPiA+IFZNcyBhbmQgdGhlIGxp
a2UpIHJ1bm5pbmcgRmVkb3JhIDI5IGNvbm5lY3RpbmcgdG8gc2l4IE5GUyBzZXJ2ZXJzDQo+ID4g
cnVubmluZyBDZW50T1MgNy42ICh3aXRoIHRoZSBoZWF2aWx5IHBhdGNoZWQgdmVuZG9yIGtlcm5l
bA0KPiA+IDMuMTAuMC05NTcuMS4zKS4gIEFsbCBtYWNoaW5lcyBpbnZvbHZlZCBhcmUgeDg2XzY0
LiAgV2UgdXNlDQo+ID4ga2VyYmVyaXplZA0KPiA+IE5GUzQgd2l0aCBnZW5lcmFsbHkgc2VjPWty
YjVpLiAgVGhlIGV4cG9ydHMgYXJlIGdlbmVyYWxseSBtYWRlIHdpdGgNCj4gPiAiKHJ3LGFzeW5j
LHNlYz1rcmI1aTprcmI1cCkiLg0KPiA+IA0KPiA+IFNpbmNlIEkgYm9vdGVkIHRob3NlIGNsaWVu
dHMgaW50byA0LjIwLjMgSSd2ZSBzdGFydGVkIHNlZWluZw0KPiA+IHByb2Nlc3Nlcw0KPiA+IGdl
dHRpbmcgc3R1Y2sgaW4gdGhlIEQgc3RhdGUuICBUaGUgc3lzdGVtIGl0c2VsZiB3aWxsIHNlZW0g
T0sgKGV4Y2VwdA0KPiA+IGZvciB0aGUgaGlnaCBsb2FkIGF2ZXJhZ2UpIGFzIGxvbmcgYXMgSSBk
b24ndCB0b3VjaCB0aGUgaHVuZyBORlMNCj4gPiBtb3VudC4NCj4gPiBOb3RoaW5nIHdhcyBsb2dn
ZWQgdG8gZG1lc2cgb3IgdG8gdGhlIGpvdXJuYWwuICBTbyBmYXIgYm9vdGluZyBiYWNrDQo+ID4g
aW50bw0KPiA+IHRoZSA0LjE5LjE1IGtlcm5lbCBoYXMgY2xlYXJlZCB1cCB0aGUgcHJvYmxlbS4g
IEkgY2Fubm90IHlldA0KPiA+IHJlcHJvZHVjZQ0KPiA+IHRoaXMgb24gZGVtYW5kOyBJJ3ZlIHRy
aWVkIGJ1dCBpdCBpcyBwcm9iYWJseSByZWxhdGVkIHRvIHNvbWUNCj4gPiBzcGVjaWZpYw0KPiA+
IHVzYWdlIHBhdHRlcm4uDQo+ID4gDQo+ID4gSGFzIGFueW9uZSBlbHNlIHNlZW4gaXNzdWVzIGxp
a2UgdGhpcz8gIENhbiBhbnlvbmUgaGVscCBtZSB0byBnZXQNCj4gPiBtb3JlDQo+ID4gdXNlZnVs
IGluZm9ybWF0aW9uIHRoYXQgbWlnaHQgcG9pbnQgdG8gdGhlIHByb2JsZW0/ICBJIHN0aWxsIGhh
dmVuJ3QNCj4gPiBsZWFybmVkIGhvdyB0byBkZWJ1ZyBORlMgaXNzdWVzIHByb3Blcmx5LiAgQW5k
IGlmIHRoZXJlJ3MgYSBzdHJlc3MNCj4gPiB0ZXN0DQo+ID4gdG9vbCBJIGNvdWxkIGVhc2lseSBy
dW4gdGhhdCBtaWdodCBoZWxwIHRvIHJlcHJvZHVjZSB0aGUgaXNzdWUsIEknZA0KPiA+IGJlDQo+
ID4gaGFwcHkgdG8gcnVuIGl0Lg0KPiA+IA0KPiA+IEkgbm90ZSB0aGF0IDQuMjAuNCBpcyBvdXQ7
IEkgc2VlIG9uZSBzdW5ycGMgZml4IHdoaWNoIEkgZ3Vlc3MgY291bGQNCj4gPiBiZQ0KPiA+IHJl
bGF0ZWQgKHN1bnJwYzogaGFuZGxlIEVOT01FTSBpbiBycGNiX2dldHBvcnRfYXN5bmMpIGJ1dCB0
aGUgc3lzdGVtcw0KPiA+IGludm9sdmVkIGhhdmUgcGxlbnR5IG9mIGZyZWUgbWVtb3J5IHNvIEkg
ZG91YnQgdGhhdCdzIGl0LiAgSSdsbA0KPiA+IGNlcnRhaW5seSB0cnkgaXQgYW55d2F5Lg0KPiA+
IA0KPiA+IFZhcmlvdXMgcGFja2FnZSB2ZXJzaW9uczoNCj4gPiBrZXJuZWwtNC4yMC4zLTIwMC5m
YzI5Lng4Nl82NCAodGhlIHByb2JsZW1hdGljIGtlcm5lbCkNCj4gPiBrZXJuZWwtNC4xOS4xNS0z
MDAuZmMyOS54ODZfNjQgKHRoZSBmdW5jdGlvbmFsIGtlcm5lbCkNCj4gPiBuZnMtdXRpbHMtMi4z
LjMtMS5yYzIuZmMyOS54ODZfNjQNCj4gPiBnc3Nwcm94eS0wLjguMC02LmZjMjkueDg2XzY0DQo+
ID4ga3JiNS1saWJzLTEuMTYuMS0yNS5mYzI5Lmk2ODYNCj4gPiANCj4gPiBUaGFua3MgaW4gYWR2
YW5jZSBmb3IgYW55IGhlbHAgb3IgYWR2aWNlLA0KPiA+IA0KPiA+ICAtIEo8DQo+IA0KPiBDb21t
aXQgZGVhYTVjOTZjMmY3ICgiU1VOUlBDOiBBZGRyZXNzIEtlcmJlcm9zIHBlcmZvcm1hbmNlL2Jl
aGF2aW9yDQo+IHJlZ3Jlc3Npb24iKSB3YXMgc3VwcG9zZWQgdG8gYmUgbWFya2VkIGZvciBzdGFi
bGUgYXMgYSBmaXguIENodWNrICYNCj4gQW5uYT8NCg0KTG9va3MgbGlrZSBJIG1pc3NlZCB0aGF0
LCBzb3JyeSENCg0KU3RhYmxlIGZvbGtzLCBjYW4geW91IHBsZWFzZSBiYWNrcG9ydCBkZWFhNWM5
NmMyZjcgKCJTVU5SUEM6IEFkZHJlc3MgS2VyYmVyb3MNCnBlcmZvcm1hbmNlL2JlaGF2aW9yIHJl
Z3Jlc3Npb24iKSB0byB2NC4yMD8NCg0KVGhhbmtzLA0KQW5uYQ0KPiAtLQ0KPiBUcm9uZCBNeWts
ZWJ1c3QNCj4gTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KPiB0cm9u
ZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQo+IA0KPiANCg==
