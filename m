Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CAD1C282C3
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 19:58:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 51A6B21726
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 19:58:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ua13cPGf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729654AbfAXT6p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 14:58:45 -0500
Received: from mail-eopbgr800125.outbound.protection.outlook.com ([40.107.80.125]:33821
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729407AbfAXT6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Jan 2019 14:58:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yQ0BAdk3STz3/5BwH5Xukka/KBoUAhTmUG5mtBcZ+OA=;
 b=ua13cPGfrIJbVvFB8Jq4jkvLpBPpSTf6GIj3RtRmx//ZdBGjM528Hv71inCX1VFXVVHmOPczvwSGp7JtLGSqoWmIZLiNH6NtSWC75uOPm9iVfcdqszP7uJU5BMo6vr3MGiL0YF9aiWDmhVo7zEJgFv/wd4PbaoXyYocggxkP9+0=
Received: from BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) by
 BYAPR13MB2406.namprd13.prod.outlook.com (52.135.229.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.10; Thu, 24 Jan 2019 19:58:41 +0000
Received: from BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::f003:cf45:194d:8dc1]) by BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::f003:cf45:194d:8dc1%4]) with mapi id 15.20.1558.016; Thu, 24 Jan 2019
 19:58:41 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Thread-Topic: Need help debugging NFS issues new to 4.20 kernel
Thread-Index: AQHUtBBQLoOJiO8U1kuiVnwIPcpCS6W+1kMA
Date:   Thu, 24 Jan 2019 19:58:40 +0000
Message-ID: <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
In-Reply-To: <ufaimyearlx.fsf@epithumia.math.uh.edu>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR13MB2406;6:jlY+6lwg/tP7F00z6GVl4eqNYCG/4YYhrozGaQ9jsDAtSAltDZe/mwC5qVzJvNwUOfH/mNjDyjgq3dllLuRj590bjvR1/2CqjGx0HhFyqPfyGhotgS0UVuyz8mhNQTNfK9+zpDRkO3sWiVazIGNkFB5O5dL9nGsTc/zPopZh1GpSEuRm0n8y6v8Q6U/pQhj/CGqw+wUePGSlkrzhSBODmYRBCLYWCkfD6LE+a6JUNBbcW0Zz8UVbv6dAVz1VjTsYpsMBAGtrNR1DuVRxF1OokQw/hiTtrrE/6e01EYcZygNNjb1GEIOlD0uIyIO/MiSTAN3Iw517qst4mpTSxNVjAvYyYEPakS96+gLhsPcogkae+xYhY1IdPCl32/hmXB4lNaa8ZYZKcSfgSUSxPqVlSJ82ZS7gj8ks4sOXfsO1Omgu4AyjbU00kUe0u/OC3ucuMf1iHxR11FgHHgut6TZr0A==;5:oknDGpkh97qIvOUGnozAU4K1ND22yGe91GB0xVsZDOjYNZmVSL7ghnC80cGiewncJkhe3arUccnqZFS0JxnaZPqQnQDel20BGcT5GUFrWc1ZfjUVnxSNP2nyKPKRLrAtNEA576V2fLHlgHsTiEUO3/5VYF05LM6W/gCaiW3BN5/rqa9IqfBrHFWkMAfeweMa4kN3o8eto3Uo/fO+x/Ek9Q==;7:pe8gVEZdWg/P5avqGP+ZYsHxUV3DSsx3CgtqnFubHlod8eF7tsWuMBDFsH318gDAeLetcLEpQRjF/5m22B2GJi+c28C7OkpZeNRWSUFQkWF9mHkzg21vyGZaurprcw3SRzrwNDgIij9g/O3A/eLJdg==
x-ms-office365-filtering-correlation-id: 5b21678f-5aa8-4964-d4d8-08d682365677
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR13MB2406;
x-ms-traffictypediagnostic: BYAPR13MB2406:
x-microsoft-antispam-prvs: <BYAPR13MB2406CD766DBBE1F288CC797EB89A0@BYAPR13MB2406.namprd13.prod.outlook.com>
x-forefront-prvs: 0927AA37C7
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(346002)(39830400003)(366004)(396003)(51874003)(199004)(189003)(66066001)(6486002)(99286004)(102836004)(478600001)(118296001)(6436002)(81156014)(81166006)(25786009)(76176011)(105586002)(3846002)(8936002)(486006)(8676002)(6116002)(316002)(6512007)(106356001)(305945005)(110136005)(36756003)(7736002)(256004)(186003)(97736004)(53936002)(2906002)(11346002)(2171002)(26005)(14454004)(86362001)(6246003)(2501003)(2616005)(2201001)(446003)(71200400001)(71190400001)(476003)(229853002)(68736007)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR13MB2406;H:BYAPR13MB2486.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: s657sOLrsD7bC+iaCGpn63IEAFuj0CX6/93qGCd3dBZAVXbWsdrRn3pTs4GFKlOoGhNQkkcG8r/CWyafyY0Yg9NAVgpSrAyEm/eAWTwU6Y/djoMUH4TKT/S7zV3MsVFpzXq9Da2a6AhNVnQVd0mv4GEXzcp2f4hB1vWiz2pCj0jwnwq/29JZ8tDAFbXw7gXDWQXZ5Tj/qrlI491pyYslDiirAWFemqvpwLiE/FrkrrXRAsD2eb9tAB07j9/Yl5GZj/hOcnltwoyzLXWIz9yFETAXQNvKODgWEbn7A/Epp6wxUK1gbBsVDVLxUNPqYgsTE3x4O1lmRQp7f45WqO0VK1pI1Ryq4Or+gfk975N2qwSu8/RoUEgW8N/R7f74T4fpmLAEf9TCZWpHNNNC3/zoLrZ8PXzAUiTHCLXAW3Snx1c=
Content-Type: text/plain; charset="utf-8"
Content-ID: <912CE860FBD2FA468CA4ACBDCCA13463@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5b21678f-5aa8-4964-d4d8-08d682365677
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jan 2019 19:58:40.9232
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR13MB2406
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTI0IGF0IDExOjMyIC0wNjAwLCBKYXNvbiBMIFRpYmJpdHRzIElJSSB3
cm90ZToNCj4gSSBjb3VsZCB1c2Ugc29tZSBoZWxwIGZpZ3VyaW5nIG91dCB0aGUgY2F1c2Ugb2Yg
c29tZSBzZXJpb3VzIE5GUw0KPiBjbGllbnQNCj4gaXNzdWVzIEknbSBoYXZpbmcgd2l0aCB0aGUg
NC4yMC4zIGtlcm5lbCB3aGljaCBJIGRpZCBub3Qgc2VlIHVuZGVyDQo+IDQuMTkuMTUuDQo+IA0K
PiBJIGhhdmUgYSBuZXR3b3JrIG9mIGFib3V0IDEzMCBkZXNrdG9wcyAocGx1cyBhIGJ1bmNoIG9m
IG90aGVyDQo+IG1hY2hpbmVzLA0KPiBWTXMgYW5kIHRoZSBsaWtlKSBydW5uaW5nIEZlZG9yYSAy
OSBjb25uZWN0aW5nIHRvIHNpeCBORlMgc2VydmVycw0KPiBydW5uaW5nIENlbnRPUyA3LjYgKHdp
dGggdGhlIGhlYXZpbHkgcGF0Y2hlZCB2ZW5kb3Iga2VybmVsDQo+IDMuMTAuMC05NTcuMS4zKS4g
IEFsbCBtYWNoaW5lcyBpbnZvbHZlZCBhcmUgeDg2XzY0LiAgV2UgdXNlDQo+IGtlcmJlcml6ZWQN
Cj4gTkZTNCB3aXRoIGdlbmVyYWxseSBzZWM9a3JiNWkuICBUaGUgZXhwb3J0cyBhcmUgZ2VuZXJh
bGx5IG1hZGUgd2l0aA0KPiAiKHJ3LGFzeW5jLHNlYz1rcmI1aTprcmI1cCkiLg0KPiANCj4gU2lu
Y2UgSSBib290ZWQgdGhvc2UgY2xpZW50cyBpbnRvIDQuMjAuMyBJJ3ZlIHN0YXJ0ZWQgc2VlaW5n
DQo+IHByb2Nlc3Nlcw0KPiBnZXR0aW5nIHN0dWNrIGluIHRoZSBEIHN0YXRlLiAgVGhlIHN5c3Rl
bSBpdHNlbGYgd2lsbCBzZWVtIE9LIChleGNlcHQNCj4gZm9yIHRoZSBoaWdoIGxvYWQgYXZlcmFn
ZSkgYXMgbG9uZyBhcyBJIGRvbid0IHRvdWNoIHRoZSBodW5nIE5GUw0KPiBtb3VudC4NCj4gTm90
aGluZyB3YXMgbG9nZ2VkIHRvIGRtZXNnIG9yIHRvIHRoZSBqb3VybmFsLiAgU28gZmFyIGJvb3Rp
bmcgYmFjaw0KPiBpbnRvDQo+IHRoZSA0LjE5LjE1IGtlcm5lbCBoYXMgY2xlYXJlZCB1cCB0aGUg
cHJvYmxlbS4gIEkgY2Fubm90IHlldA0KPiByZXByb2R1Y2UNCj4gdGhpcyBvbiBkZW1hbmQ7IEkn
dmUgdHJpZWQgYnV0IGl0IGlzIHByb2JhYmx5IHJlbGF0ZWQgdG8gc29tZQ0KPiBzcGVjaWZpYw0K
PiB1c2FnZSBwYXR0ZXJuLg0KPiANCj4gSGFzIGFueW9uZSBlbHNlIHNlZW4gaXNzdWVzIGxpa2Ug
dGhpcz8gIENhbiBhbnlvbmUgaGVscCBtZSB0byBnZXQNCj4gbW9yZQ0KPiB1c2VmdWwgaW5mb3Jt
YXRpb24gdGhhdCBtaWdodCBwb2ludCB0byB0aGUgcHJvYmxlbT8gIEkgc3RpbGwgaGF2ZW4ndA0K
PiBsZWFybmVkIGhvdyB0byBkZWJ1ZyBORlMgaXNzdWVzIHByb3Blcmx5LiAgQW5kIGlmIHRoZXJl
J3MgYSBzdHJlc3MNCj4gdGVzdA0KPiB0b29sIEkgY291bGQgZWFzaWx5IHJ1biB0aGF0IG1pZ2h0
IGhlbHAgdG8gcmVwcm9kdWNlIHRoZSBpc3N1ZSwgSSdkDQo+IGJlDQo+IGhhcHB5IHRvIHJ1biBp
dC4NCj4gDQo+IEkgbm90ZSB0aGF0IDQuMjAuNCBpcyBvdXQ7IEkgc2VlIG9uZSBzdW5ycGMgZml4
IHdoaWNoIEkgZ3Vlc3MgY291bGQNCj4gYmUNCj4gcmVsYXRlZCAoc3VucnBjOiBoYW5kbGUgRU5P
TUVNIGluIHJwY2JfZ2V0cG9ydF9hc3luYykgYnV0IHRoZSBzeXN0ZW1zDQo+IGludm9sdmVkIGhh
dmUgcGxlbnR5IG9mIGZyZWUgbWVtb3J5IHNvIEkgZG91YnQgdGhhdCdzIGl0LiAgSSdsbA0KPiBj
ZXJ0YWlubHkgdHJ5IGl0IGFueXdheS4NCj4gDQo+IFZhcmlvdXMgcGFja2FnZSB2ZXJzaW9uczoN
Cj4ga2VybmVsLTQuMjAuMy0yMDAuZmMyOS54ODZfNjQgKHRoZSBwcm9ibGVtYXRpYyBrZXJuZWwp
DQo+IGtlcm5lbC00LjE5LjE1LTMwMC5mYzI5Lng4Nl82NCAodGhlIGZ1bmN0aW9uYWwga2VybmVs
KQ0KPiBuZnMtdXRpbHMtMi4zLjMtMS5yYzIuZmMyOS54ODZfNjQNCj4gZ3NzcHJveHktMC44LjAt
Ni5mYzI5Lng4Nl82NA0KPiBrcmI1LWxpYnMtMS4xNi4xLTI1LmZjMjkuaTY4Ng0KPiANCj4gVGhh
bmtzIGluIGFkdmFuY2UgZm9yIGFueSBoZWxwIG9yIGFkdmljZSwNCj4gDQo+ICAtIEo8DQoNCkNv
bW1pdCBkZWFhNWM5NmMyZjcgKCJTVU5SUEM6IEFkZHJlc3MgS2VyYmVyb3MgcGVyZm9ybWFuY2Uv
YmVoYXZpb3INCnJlZ3Jlc3Npb24iKSB3YXMgc3VwcG9zZWQgdG8gYmUgbWFya2VkIGZvciBzdGFi
bGUgYXMgYSBmaXguIENodWNrICYNCkFubmE/DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
