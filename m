Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75874C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 20:26:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1A6D2081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 20:26:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gQigjFVx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1A6D2081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726106AbeKCFfP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 01:35:15 -0400
Received: from mail-dm3nam03on0103.outbound.protection.outlook.com ([104.47.41.103]:5088
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725728AbeKCFfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 3 Nov 2018 01:35:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZFlE3Da/KeSaB5t/m0kB5GbQRCTp0sIjoazYQnXYf44=;
 b=gQigjFVxLOdkzrCsDGaP9mAGd9agkwm/jZXHP1YHcpKbQFu3thfT7kHc4WwO4R7EmgJi4cs5FQcD0kU6KN+G9M/Ynt1CJeqUXNdr3We8UfVyAp/AWjcjp3HAu2ypBI9QcZzPwfqSvdnkotaXWjzYsil1kV03nqV7CtuECjkRW2E=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2256.namprd13.prod.outlook.com (52.135.93.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.9; Fri, 2 Nov 2018 20:26:36 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.024; Fri, 2 Nov 2018
 20:26:36 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "malahal@gmail.com" <malahal@gmail.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: "(deleted)" directories
Thread-Topic: "(deleted)" directories
Thread-Index: AQHUcmyqhAuTrD/t40CG05LKPmMcxKU8UwcAgABQ1ACAAEv8gA==
Date:   Fri, 2 Nov 2018 20:26:36 +0000
Message-ID: <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
         <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
         <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
In-Reply-To: <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2256;6:ccUHs/H5PZvBTuCTlIAao8CjW1LGFdEBh3a4yDlAqwvZOfKTYW47e2XDWk5M73nABm5evzP3H8I4q457nT4N1K4t9JpGLzVZz/NJfbVqfJMzxRL1PjQFahlWbidoLLW0PiN44ytrk319cwQoXku6PTDjX7tFmI8WwwoniaxAv9jM5fSAl1c5zw7uzBgmZIDLIdggSimMuO32CD5PWXjyVNN7uC37zE6mhLX4Nr1C9U8YxE1o4lS3vuXaihr6tka1cy8BSPGFj14puOoXr9lIA5txV1sNY7OMqqcrqC2ql7nAp5KU0ASILjU4BvYv0gmYf8gMnjuKzOro1wcoNXXFuf43WY6IHwPmqEwWHcZ64V1OKw6FCEmhieV4/M7QC1vRBByMhITsfB7oBc7Emk6ippTjrMc89Hg033aYlBUqG5nuv/Ww/jlOXLau55BsZ7tnJMzU1IHlw2wnd8hEn7b/Yw==;5:FggEGw+h+1LdYhXtSvk4PnWih41YHo840GRnCc3L2Kc6hsiW+GO4WQTXkWdks7iitCL5E+0xbw4hGqezn+gvhDYHzRjkvr06oJ2k2EeeoWnae3Vw8TuAxJZ6wHBW3BuvQ67juZok0wBLymemHCpDC6Q7mMGuTTCnFcg5KKpFALA=;7:8y9N0DYdyO3iqY8NUV3kcDvptNelj0HoypSyG4s+mFi8upVmLmDSDtF6CErQSC4Z4zeYQEdWKE8r6jyfai+gHwLDKF+egdlC2VBNcLjAGhk3Qr5v/9NAwwZPWVzZOVXQK8T0Tg6J9t46d5ke6nKArQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f8939b19-92fb-4299-ebaf-08d641017cff
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2256;
x-ms-traffictypediagnostic: SN6PR13MB2256:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB22564B5B6B5C230D8A082257B8CF0@SN6PR13MB2256.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(158342451672863)(20558992708506);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(3231382)(944501410)(52105095)(93006095)(93001095)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123562045)(20161123564045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2256;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2256;
x-forefront-prvs: 08444C7C87
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(39830400003)(366004)(346002)(396003)(53754006)(199004)(189003)(2501003)(229853002)(68736007)(102836004)(106356001)(8936002)(6506007)(110136005)(53546011)(105586002)(66066001)(6512007)(2906002)(3846002)(6116002)(99286004)(97736004)(81166006)(25786009)(6436002)(81156014)(316002)(8676002)(76176011)(4326008)(305945005)(6486002)(71200400001)(71190400001)(575784001)(86362001)(6246003)(2616005)(486006)(118296001)(14444005)(36756003)(256004)(476003)(11346002)(26005)(53936002)(39060400002)(14454004)(2900100001)(15974865002)(7736002)(186003)(5660300001)(478600001)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2256;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: NjfN0HuX1by8gXXiYqVPdnIIqlBvT8JqZmTB2K0HdIXUCmbGO4/PGQNYYza4jiN79U2ki+eKlw9oEwhD/8k61b5yi1iOYP/T0tYA1dI6zspyT2EgKV2GRAZ/3ITXycepjUdzO8bYU25Z3Upbv4kiYbH2tkkIFe3cf05bQVWDVnMS1at1oD6K2x4CUEkwWnaIgqBT2ujKbUM2AXlJvPyhsu3s/Ou9YhfjjcaBbah5lEVdhmP8w9orzH/y9yFXcu4p2/bDEIah3VEmoomlSjk+mJrApY4JqPuODHA6DkTkI8v+VqTe9vqB/d72xEtao0K3uf1LS6k8bI7qbLErF07EqldarIkxIR9Zxzlxi9D99Tg=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <4EDDC4159758734FB9831AA8EF0AF2B7@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f8939b19-92fb-4299-ebaf-08d641017cff
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Nov 2018 20:26:36.6162
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2256
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTAyIGF0IDIxOjI0ICswNTMwLCBNYWxhaGFsIE5haW5lbmkgd3JvdGU6
DQo+IEJlbiwgTkZTdjMgUkZDMTgxMy50eHQgc3RhdGVzOiAiSWYgdHdvIGZpbGUgaGFuZGxlcyBm
cm9tIHRoZSBzYW1lDQo+IHNlcnZlciBhcmUgZXF1YWwsIHRoZXkgbXVzdCByZWZlciB0byB0aGUg
c2FtZSBmaWxlLCBidXQgaWYgdGhleSAgYXJlDQo+IG5vdCBlcXVhbCwgbm8gY29uY2x1c2lvbnMg
Y2FuIGJlIGRyYXduLiIgR2FuZXNoYSBkb2VzIHJldHVybiBzYW1lDQo+IGZpbGVpZCBoZXJlIChp
bm9kZSkuDQo+IA0KPiBJbiBORlN2NCwgdGhleSBoYXZlIGludHJvZHVjZWQgInVuaXF1ZV9oYW5k
bGVzIiBhdHRyaWJ1dGUuIEkgZG9uJ3QNCj4gc2VlDQo+IExpbnV4IE5GUyBjbGllbnQgdXNpbmcg
dGhpcyBhdCBhbGwgdGhvdWdoLg0KDQpXaHkgZG9lcyB5b3VyIHNlcnZlciBuZWVkIHRvIGhhdmUg
bXVsdGlwbGUgZmlsZWhhbmRsZXMgcmVmZXIgdG8gdGhlDQpzYW1lIGZpbGUsIGFuZCB3aHkgZG8g
eW91IGV4cGVjdCBjbGllbnRzIHRvIHN1cHBvcnQgdGhpcz8NCg0KWWVzLCB0aGUgc3BlYyBhbGxv
d3MgaXQsIGJ1dCB0aGF0J3Mgbm90IGEgc3VmZmljaWVudCByZWFzb24uDQoNCj4gDQo+IFJlZ2Fy
ZHMsIE1hbGFoYWwuDQo+IE9uIEZyaSwgTm92IDIsIDIwMTggYXQgNDozNSBQTSBCZW5qYW1pbiBD
b2RkaW5ndG9uIDwNCj4gYmNvZGRpbmdAcmVkaGF0LmNvbT4gd3JvdGU6DQo+ID4gT24gMiBOb3Yg
MjAxOCwgYXQgMToyNiwgTWFsYWhhbCBOYWluZW5pIHdyb3RlOg0KPiA+IA0KPiA+ID4gSGkgQWxs
LCB3ZSBhcmUgdXNpbmcgTkZTLUdhbmVzaGEgd2l0aCBMaW51eCBORlMgY2xpZW50cy4gVGhlDQo+
ID4gPiBjbGllbnQncw0KPiA+ID4gc2hlbGwgcmVwb3J0cyB0aGUgZm9sbG93aW5nLiBCYXNlZCBv
biBsc29mLCB0aGUgZGlyZWN0b3J5IGlzDQo+ID4gPiBtYXJrZWQNCj4gPiA+IGRlbGV0ZWQuICJj
ZCB0byBST09UIGFuZCBjZCB0byB0aGUgc2FtZSBob21lIGRpcmVjdG9yeSBmaXhlcyB0aGUNCj4g
PiA+IGlzc3VlLiBUaGUgY2xpZW50IGJlaGF2ZXMgYXMgdGhvdWdoIHRoZSBkaXJlY3RvcnkgaXMg
ZGVsZXRlZCBhbmQNCj4gPiA+IHJlY3JlYXRlZCEgT3VyIE5GUy1HYW5lc2hhIHNlcnZlciBpbXBs
ZW1lbnRhdGlvbiB1c2VzIG11bHRpcGxlDQo+ID4gPiBmaWxlDQo+ID4gPiBoYW5kbGVzIHRoYXQg
cG9pbnQgdG8gdGhlIHNhbWUgb2JqZWN0LiBORlMgc3BlYyBzYXlzIHRoaXMgc2hvdWxkDQo+ID4g
PiBiZQ0KPiA+ID4gZmluZSwgYnV0IExpbnV4IE5GUyBzZWVtcyB0byBiZSBicm9rZW4gaW4gdGhp
cyByZWdhcmQuIHRjcGR1bXANCj4gPiA+IGRvZXMNCj4gPiA+IGluZGljYXRlIGZpbGUgaGFuZGxl
IGNoYW5nZSAobm90ZSB0aGF0IGFsbCBmaWxlIGhhbmRsZXMgYXJlDQo+ID4gPiBwZXJtYW5lbnQs
DQo+ID4gPiBtZWFuaW5nIHRoZXkgYXJlIHZhbGlkIGF0IHRoZSBzZXJ2ZXIgYW55IHRpbWUpIGFy
b3VuZCB0aGlzIGlzc3VlDQo+ID4gPiB0aW1lLg0KPiA+ID4gDQo+ID4gPiAic2hlbGwtaW5pdDog
ZXJyb3IgcmV0cmlldmluZyBjdXJyZW50IGRpcmVjdG9yeTogZ2V0Y3dkOiBjYW5ub3QNCj4gPiA+
IGFjY2Vzcw0KPiA+ID4gcGFyZW50IGRpcmVjdG9yaWVzOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0
b3J5Ig0KPiA+ID4gc2ggICAgICAgIDExMjU0NCAgICAgICAgICAgIG1hbGFoYWwgIGN3ZCAgICAg
ICBESVIgICAgICAgICAgICAgICANCj4gPiA+IDAsNjcNCj4gPiA+ICAgICAgNjU1MzYgICA0NTYw
NTIwOSAvaG9tZS9tYWxhaGFsIChkZWxldGVkKQ0KPiA+ID4gKDEwLjEyMC4xNTQuNDI6L25mcy9t
YWxhaGFsLWV4cG9ydC8pDQo+ID4gPiANCj4gPiA+IEZ1bmN0aW9uIG5mc19wcmltZV9kY2FjaGUo
KSBzZWVtcyB0byBpbnZhbGlkYXRlIHRoZSBkY2FjaGUgZW50cnkNCj4gPiA+IGlmDQo+ID4gPiBu
ZnNfc2FtZV9maWxlKCkgcmV0dXJucyBmYWxzZS4gbmZzX3NhbWVfZmlsZSgpIGRvZXMgc2VlbSB0
bw0KPiA+ID4gcmV0dXJuDQo+ID4gPiBmYWxzZSB3aXRoIHRoZSBmb2xsb3dpbmcgY2hhbmdlLCBp
ZiBJIHJlYWQgaXQgY29ycmVjdGx5LCBpZiB0aGVyZQ0KPiA+ID4gaXMgYQ0KPiA+ID4gZmlsZSBo
YW5kbGUgY2hhbmdlLiBDYW4gdGhpcyBiZSB0aGUgc291cmNlIG9mIG15IGlzc3VlPyBJdCBzZWVt
cw0KPiA+ID4gdGhhdA0KPiA+ID4gdGhlIGNsaWVudCBzaG91bGQgZG8gdGhpcyBvbmx5IGlmIHRo
ZSBmaWxlIGhhbmRsZSBpcyBOT1QgdmFsaWQNCj4gPiA+IChlLmcuDQo+ID4gPiBpZiBpdCBnZXRz
IEVTVEFMRSksIHJpZ2h0Pw0KPiA+ID4gDQo+ID4gPiBUaGUgZm9sbG93aW5nIGNvbW1pdCBzZWVt
cyB0byBhc3N1bWUgdGhhdCB0aGUgb2JqZWN0cyBhcmUNCj4gPiA+IGRpZmZlcmVudCBpZg0KPiA+
ID4gdGhleSBoYXZlIGRpZmZlcmVudCBmaWxlIGhhbmRsZXMhDQo+ID4gPiBjb21taXQgN2RjNzJk
NWY3YTBlYzk3YTUzZTEyNmM0NmUyY2JkMjU2MDc1Nzk1NQ0KPiA+ID4gQXV0aG9yOiBUcm9uZCBN
eWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20+DQo+ID4gPiBEYXRlOiAg
IFRodSBTZXAgMjIgMTM6Mzg6NTIgMjAxNiAtMDQwMA0KPiA+ID4gDQo+ID4gPiAgICAgTkZTOiBG
aXggaW5vZGUgY29ycnVwdGlvbiBpbiBuZnNfcHJpbWVfZGNhY2hlKCkNCj4gPiANCj4gPiBNeSB1
bmRlcnN0YW5kaW5nIGlzIHRoYXQgZm9yIE5GU3YzIHdlIGhhdmUgdG8gYXNzdW1lIHRoYXQgZGlz
dGluY3QNCj4gPiBmaWxlaGFuZGxlcyBhcmUgZGlzdGluY3Qgb2JqZWN0cywgYnV0IG1heWJlIEkn
bSB3cm9uZyBhYm91dCB0aGlzLg0KPiA+IA0KPiA+IEZvciBORlN2NC54LCB3ZSBjYW4gZm9sbG93
IHRoZSBndWlkYW5jZSBpbiBSRkNzIDU2NjEgb3IgNzUzMA0KPiA+IHNlY3Rpb24gMTAuMy40DQo+
ID4gdG8gZGV0ZXJtaW5lIGlmIHRoZSBkaWZmZXJpbmcgZmlsZWhhbmRsZXMgYXJlIHRoZSBzYW1l
IG9iamVjdCwNCj4gPiBzcGVjaWZpY2FsbHkNCj4gPiB0aGUgZmlsZWlkIHJlY29tbWVuZGVkIGF0
dHJpYnV0ZSBuZWVkcyB0byBiZSBpbXBsZW1lbnRlZC4gIElzDQo+ID4gR2FuZXNoYQ0KPiA+IHJl
dHVybmluZyB0aGUgc2FtZSBmaWxlaWQgZm9yIGJvdGggZmlsZWhhbmRsZXM/DQo+ID4gDQo+ID4g
QmVuDQotLSANClRyb25kIE15a2xlYnVzdA0KQ1RPLCBIYW1tZXJzcGFjZSBJbmMNCjQzMDAgRWwg
Q2FtaW5vIFJlYWwsIFN1aXRlIDEwNQ0KTG9zIEFsdG9zLCBDQSA5NDAyMg0Kd3d3LmhhbW1lci5z
cGFjZQ0KDQoNCg==
