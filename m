Return-Path: <SRS0=1lUO=RV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 041D1C10F00
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 17:11:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BEC6420863
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 17:11:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nxnWk90M"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726806AbfCRRLN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 13:11:13 -0400
Received: from mail-eopbgr710127.outbound.protection.outlook.com ([40.107.71.127]:34944
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726777AbfCRRLN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Mar 2019 13:11:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OqAjRpyzDY8LNY98Ify/oJ+tQz7duPHzYFDxT7uYPaw=;
 b=nxnWk90MAelLaaM/22wOL2PEPZYGlF/PnAiUDaCdMnZFWdHc8G9VtFXDuj4gLaW5N92W4Metw9qVNAeWKrZnNfASHnXq+1ibrExt54+cxZH+brXcX68zD9+gEYi/jojf7IdvrLFd1d7suRf7zvQfr1gqJL8cnwlWTiAFGXGgE5U=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2429.namprd13.prod.outlook.com (52.135.94.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.9; Mon, 18 Mar 2019 17:11:09 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1730.003; Mon, 18 Mar 2019
 17:11:09 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "neilb@suse.com" <neilb@suse.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix nfs4_lock_state refcounting in
 nfs4_alloc_{lock,unlock}data()
Thread-Topic: [PATCH] NFS: Fix nfs4_lock_state refcounting in
 nfs4_alloc_{lock,unlock}data()
Thread-Index: AQHU3awd9iQEYbfPS0GRAmU5BTgR16YRn86A
Date:   Mon, 18 Mar 2019 17:11:09 +0000
Message-ID: <9cee20976d23acb18c4925b3cc55d34c1369ae83.camel@hammerspace.com>
References: <20190318170028.61423-1-catalin.marinas@arm.com>
In-Reply-To: <20190318170028.61423-1-catalin.marinas@arm.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b6a79034-af5b-472c-9a71-08d6abc4b74b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2429;
x-ms-traffictypediagnostic: SN6PR13MB2429:
x-microsoft-antispam-prvs: <SN6PR13MB24293C3B0EC744908CB953CAB8470@SN6PR13MB2429.namprd13.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(396003)(376002)(39830400003)(346002)(189003)(199004)(53936002)(6436002)(229853002)(6512007)(8936002)(68736007)(478600001)(8676002)(81156014)(81166006)(14454004)(86362001)(3846002)(6486002)(256004)(14444005)(6116002)(36756003)(97736004)(99286004)(25786009)(5660300002)(106356001)(105586002)(76176011)(476003)(186003)(6246003)(102836004)(71190400001)(446003)(11346002)(486006)(6506007)(118296001)(2501003)(4326008)(316002)(6346003)(110136005)(305945005)(54906003)(7736002)(2906002)(66066001)(2616005)(26005)(71200400001)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2429;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: AwSk8y0nKDnaSkzu08lfgyHEJFJkR6BHo+TMh1nBz3LN9qcp2ua7f8Ke7s0VJo77UqI9HlZZfsvr3yWKClDhVlOdpSjzd9jwmrkLmVagGLiwFKwUF08kOWXFyi/IUHPDGkZACjHfw4rF0+7DluNtYsvgGL/vXixNUJzbJ0LCqtw+gvv9fNmCPowakWu5k2zocm9IKntrmAKWQeG8EGhZbTROysr5EDryfP77nqo6etPHRPPRbPRLoyG/F/UUveimufZNs1pFFb5RhzMApy/Rd4FRJpjvTFE7yRys4cc7G8DXulvZH4KF13fH+J0VTmWoo8z73U6WlWqWNw7kLEPQ9SXPMCZmjmf1SXFl39rNQYhsnF4UBlQ8zBHRmrcYh+B19bY3wyaKDa0s13RRwg4ZHAIxEBQA5gdHBbByt2JTEbc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F6DD1B6E4B8D5348A7F1C42F3B0F6210@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b6a79034-af5b-472c-9a71-08d6abc4b74b
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 17:11:09.4967
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2429
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAzLTE4IGF0IDE3OjAwICswMDAwLCBDYXRhbGluIE1hcmluYXMgd3JvdGU6
DQo+IENvbW1pdCA3YjU4N2UxYTVhNmMgKCJORlM6IHVzZSBsb2Nrc19jb3B5X2xvY2soKSB0byBj
b3B5IGxvY2tzLiIpDQo+IGNoYW5nZWQgdGhlIGxvY2sgY29weWluZyBmcm9tIG1lbWNweSgpIHRv
IHRoZSBkZWRpY2F0ZWQNCj4gbG9ja3NfY29weV9sb2NrKCkgZnVuY3Rpb24uIFRoZSBsYXR0ZXIg
Y29ycmVjdGx5IGluY3JlbWVudHMgdGhlDQo+IG5mczRfbG9ja19zdGF0ZS5sc19jb3VudCB2aWEg
bmZzNF9mbF9jb3B5X2xvY2soKSwgaG93ZXZlciwgdGhpcw0KPiByZWZjb3VudA0KPiBoYXMgYWxy
ZWFkeSBiZWVuIGluY3JlbWVudGVkIGluIHRoZSBuZnM0X2FsbG9jX3tsb2NrLHVubG9ja31kYXRh
KCkuDQo+IEttZW1sZWFrIHN1YnNlcXVlbnRseSByZXBvcnRzIGFuIHVucmVmZXJlbmNlZCBuZnM0
X2xvY2tfc3RhdGUgb2JqZWN0DQo+IGFzDQo+IGJlbG93IChhcm02NCBwbGF0Zm9ybSk6DQo+IA0K
PiB1bnJlZmVyZW5jZWQgb2JqZWN0IDB4ZmZmZjgwMDBmY2UwYjAwMCAoc2l6ZSAyNTYpOg0KPiAg
IGNvbW0gInN5c3RlbWQtc3lzdXNlciIsIHBpZCAxNjA4LCBqaWZmaWVzIDQyOTQ4OTI4MjUgKGFn
ZSAzMi4zNDhzKQ0KPiAgIGhleCBkdW1wIChmaXJzdCAzMiBieXRlcyk6DQo+ICAgICAyMCA1NyA0
YyBmYiAwMCA4MCBmZiBmZiAyMCA1NyA0YyBmYiAwMCA4MCBmZiBmZiAgIFdMLi4uLi4gV0wuLi4u
Lg0KPiAgICAgMDAgNTcgNGMgZmIgMDAgODAgZmYgZmYgMDEgMDAgMDAgMDAgMDAgMDAgMDAgMDAg
IC5XTC4uLi4uLi4uLi4uLi4NCj4gICBiYWNrdHJhY2U6DQo+ICAgICBbPDAwMDAwMDAwMGQxNTAx
MGQ+XSBrbWVtX2NhY2hlX2FsbG9jKzB4MTc4LzB4MjA4DQo+ICAgICBbPDAwMDAwMDAwZDdjMWQy
NjQ+XSBuZnM0X3NldF9sb2NrX3N0YXRlKzB4MTI0LzB4MWYwDQo+ICAgICBbPDAwMDAwMDAwOWM4
Njc2Mjg+XSBuZnM0X3Byb2NfbG9jaysweDkwLzB4NDc4DQo+ICAgICBbPDAwMDAwMDAwMTY4NmJk
NzQ+XSBkb19zZXRsaysweDY0LzB4ZTgNCj4gICAgIFs8MDAwMDAwMDBlMDE1MDBkND5dIG5mc19s
b2NrKzB4ZTgvMHgxZjANCj4gICAgIFs8MDAwMDAwMDA0ZjM4N2Q4ZD5dIHZmc19sb2NrX2ZpbGUr
MHgxOC8weDQwDQo+ICAgICBbPDAwMDAwMDAwNjU2YWI3OWI+XSBkb19sb2NrX2ZpbGVfd2FpdCsw
eDY4LzB4ZjgNCj4gICAgIFs8MDAwMDAwMDBmMTdjNGE0Yj5dIGZjbnRsX3NldGxrKzB4MjI0LzB4
MjgwDQo+ICAgICBbPDAwMDAwMDAwNTJhMjQyYzY+XSBkb19mY250bCsweDQxOC8weDczMA0KPiAg
ICAgWzwwMDAwMDAwMDRmNDcyOTFhPl0gX19hcm02NF9zeXNfZmNudGwrMHg4NC8weGQwDQo+ICAg
ICBbPDAwMDAwMDAwZDY4NTZlMDE+XSBlbDBfc3ZjX2NvbW1vbisweDgwLzB4ZjANCj4gICAgIFs8
MDAwMDAwMDA5YzRiZDFkZj5dIGVsMF9zdmNfaGFuZGxlcisweDJjLzB4ODANCj4gICAgIFs8MDAw
MDAwMDBiMWEwZDQ3OT5dIGVsMF9zdmMrMHg4LzB4Yw0KPiAgICAgWzwwMDAwMDAwMDU2YzYyYTBm
Pl0gMHhmZmZmZmZmZmZmZmZmZmZmDQo+IA0KPiBUaGlzIHBhdGNoIHJlbW92ZXMgdGhlIG9yaWdp
bmFsIHJlZmNvdW50X2luYygmbHNwLT5sc19jb3VudCkgdGhhdCB3YXMNCj4gcGFpcmVkIHdpdGgg
dGhlIG1lbWNweSgpIGxvY2sgY29weWluZy4NCj4gDQo+IEZpeGVzOiA3YjU4N2UxYTVhNmMgKCJO
RlM6IHVzZSBsb2Nrc19jb3B5X2xvY2soKSB0byBjb3B5IGxvY2tzLiIpDQo+IENjOiA8c3RhYmxl
QHZnZXIua2VybmVsLm9yZz4gIyA1LjAueC0NCj4gQ2M6IE5laWxCcm93biA8bmVpbGJAc3VzZS5j
b20+DQo+IFNpZ25lZC1vZmYtYnk6IENhdGFsaW4gTWFyaW5hcyA8Y2F0YWxpbi5tYXJpbmFzQGFy
bS5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL25mczRwcm9jLmMgfCAyIC0tDQo+ICAxIGZpbGUgY2hh
bmdlZCwgMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2Mu
YyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+IGluZGV4IDRkYmIwZWUyMzQzMi4uNmQyODEyYTM5Mjg3
IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvbmZzNHByb2MuYw0KPiArKysgYi9mcy9uZnMvbmZzNHBy
b2MuYw0KPiBAQCAtNjMwMSw3ICs2MzAxLDYgQEAgc3RhdGljIHN0cnVjdCBuZnM0X3VubG9ja2Rh
dGENCj4gKm5mczRfYWxsb2NfdW5sb2NrZGF0YShzdHJ1Y3QgZmlsZV9sb2NrICpmbCwNCj4gIAlw
LT5hcmcuc2VxaWQgPSBzZXFpZDsNCj4gIAlwLT5yZXMuc2VxaWQgPSBzZXFpZDsNCj4gIAlwLT5s
c3AgPSBsc3A7DQo+IC0JcmVmY291bnRfaW5jKCZsc3AtPmxzX2NvdW50KTsNCj4gIAkvKiBFbnN1
cmUgd2UgZG9uJ3QgY2xvc2UgZmlsZSB1bnRpbCB3ZSdyZSBkb25lIGZyZWVpbmcgbG9ja3MhDQo+
ICovDQo+ICAJcC0+Y3R4ID0gZ2V0X25mc19vcGVuX2NvbnRleHQoY3R4KTsNCj4gIAlwLT5sX2N0
eCA9IG5mc19nZXRfbG9ja19jb250ZXh0KGN0eCk7DQo+IEBAIC02NTI2LDcgKzY1MjUsNiBAQCBz
dGF0aWMgc3RydWN0IG5mczRfbG9ja2RhdGENCj4gKm5mczRfYWxsb2NfbG9ja2RhdGEoc3RydWN0
IGZpbGVfbG9jayAqZmwsDQo+ICAJcC0+cmVzLmxvY2tfc2VxaWQgPSBwLT5hcmcubG9ja19zZXFp
ZDsNCj4gIAlwLT5sc3AgPSBsc3A7DQo+ICAJcC0+c2VydmVyID0gc2VydmVyOw0KPiAtCXJlZmNv
dW50X2luYygmbHNwLT5sc19jb3VudCk7DQo+ICAJcC0+Y3R4ID0gZ2V0X25mc19vcGVuX2NvbnRl
eHQoY3R4KTsNCj4gIAlsb2Nrc19pbml0X2xvY2soJnAtPmZsKTsNCj4gIAlsb2Nrc19jb3B5X2xv
Y2soJnAtPmZsLCBmbCk7DQoNClRoYW5rcyBDYXRhbGluISBHb29kIGNhdGNoLi4uDQoNCkknbSBh
cHBseWluZyB0aGlzIHRvIG15IGxpbnV4LW5leHQgYnJhbmNoLg0KDQotLSANClRyb25kIE15a2xl
YnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
