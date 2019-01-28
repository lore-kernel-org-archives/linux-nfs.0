Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE40AC282C8
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 17:59:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70B982148E
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 17:59:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="SIvgSZzv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726786AbfA1R7i (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jan 2019 12:59:38 -0500
Received: from mail-eopbgr720116.outbound.protection.outlook.com ([40.107.72.116]:51430
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726762AbfA1R7i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jan 2019 12:59:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9iih5oL1pQoYGQNpifXIZFh3DJOO16nxDlUwRbkwT+k=;
 b=SIvgSZzv+Gpb3p3wLY9hk8vYXJHyhG2CF3au/zmszclq4kavwEwvMe/x+qhpFF7YTX8qj4Wo6UfvVICBBWEyd7ChdnHc75oED8uoS337/nTFtMFMNmcPLcuPh8jsafp/zAHLFt/VSICENZoX/NcK1n8V/2PcZdukczMe1fF9nYI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2301.namprd13.prod.outlook.com (52.135.94.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.14; Mon, 28 Jan 2019 17:59:33 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1580.014; Mon, 28 Jan 2019
 17:59:33 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Always return the error that truncates a flushing
 page
Thread-Topic: [PATCH] NFS: Always return the error that truncates a flushing
 page
Thread-Index: AQHUtlPAp5BRF0OngU+mS50qV7mcpqXE+ciA
Date:   Mon, 28 Jan 2019 17:59:33 +0000
Message-ID: <9fc3d4ee7d8eafdfdb7b7c1397ecb25dd22e12b7.camel@hammerspace.com>
References: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
In-Reply-To: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2301;6:Gd9EoZyEc2acwiZwTHFfAAlFWEZsV16rCMGny1wBhFw0NzGr1i7kjxUWU/1w1K65qo/wDNZR6wLvMM5tUE/UoMsx/WVd4PMxNUNWY6lSBRtC/5zZrxSYCPYLzuHWeTJzZR/Eup1NgQfnbBw5o/s89cYdOAD2LBXO5vW8DmOs/52bGtCeq3HTASeQKRAo+JyFbhA/tDmuklvBymx9qkt0r3gmzqQ4Uxci7AN6lBUTWlqlSaI+pbC9gNXGtliaeZxetOw+JSSbt92vIBVDiDDtD6uIUrtE7aJr8Y2n+sot+2uPu96U8VT/9dn3N2JhN1shXMOFpm+57oHbUwYX84XEL9VjHCTW52OjCO/IvfWhnjNQeuZTz9780Xn8BFiIZ3uPZozbjNe1q6yb3cwRzyzgFeowsSNBHciEm1OYO8SkB4Fyzl5QTV/4qWlpZu9fH5SpXnnwqqdsGyz7vqQ0CXKPKA==;5:KBzMmhkQzNpP52i8c1Mj9fXIvmxtixWeSMU4oLHlsD6RSmZ3zcHZur+Md8jJhG2deDKTmURDTuUG3KALWQJnlRx9g5424r3j0UJdO6hziZOP2Kjsyrzw3qv+CDz8IeKo2j1W5hL3lT7oLLe+592BLNcHxqUOaFsvuCozrFBsuwJqWgizf7Wup94BM7N0tNHOOjmOQ5SQVaOBqzTFcY0qTg==;7:xy9whnvsNHhFDzUmoHVlrYwuKjf8MvW1fokZqrbmR/UTlnfA4TRXu/8XIB/4PZbDSp1VLMzYS0SRznFLQzP+SmiqSVS/Tfi2Np0N8kt91dhDPtVPhfBUt/dHQbpz7GihPGcvDVNTSS1Quk6h8UHwKA==
x-ms-office365-filtering-correlation-id: 42fb2431-79a6-42de-cde0-08d6854a5bc7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2301;
x-ms-traffictypediagnostic: SN6PR13MB2301:
x-microsoft-antispam-prvs: <SN6PR13MB2301EB206DDD313B98121AD6B8960@SN6PR13MB2301.namprd13.prod.outlook.com>
x-forefront-prvs: 0931CB1479
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39840400004)(136003)(376002)(366004)(346002)(189003)(199004)(6512007)(86362001)(2906002)(6116002)(186003)(486006)(4326008)(3846002)(6436002)(25786009)(36756003)(26005)(478600001)(97736004)(105586002)(6486002)(2616005)(106356001)(99286004)(76176011)(68736007)(6346003)(11346002)(118296001)(110136005)(316002)(53546011)(66066001)(256004)(71200400001)(14444005)(14454004)(81166006)(8676002)(53936002)(102836004)(6246003)(446003)(305945005)(81156014)(476003)(229853002)(8936002)(2501003)(6506007)(71190400001)(7736002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2301;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: BOLAonSNsPj/GI2wf5XBsv05kyjrekpg+SeEuG2/jtHDmfSgT2Z0fjgCg7PJZnZEQX1zX8Fw+NjOs7Ds8SjM8vMsKb5G3StTLTEaIwTrfDTqWVEoe/OkETVKjo4ogIIluQNvmziqgTrWb58Yx1OpKGeBF1ms0U1DvwsVlfZpvANul26JCzhvOgDTZWZnP7Cl3ZFQmVXCkrW+V+Y1e2OOwMSgCPbu6QhUsgStWqq2c4iJwonb2xf6UVRilzlo6iW5AenXeXNydUHQ6oY7CLHLKIyByRT8pnDBLDhMSPTTG0TZorSPNDy0ToGkibcdxWktIibqnFIprXLIuq4wN0fIgqCkzZHPyZWaGrRYlPZi/tvI0nuSE5/0OhNeynEA3UqYg/tXyAk2IlpAgvHTA6TMx5Z5KHEducah1G/tngpPKro=
Content-Type: text/plain; charset="utf-8"
Content-ID: <39863F0021CD7B4C84FE154A28B93D60@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 42fb2431-79a6-42de-cde0-08d6854a5bc7
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jan 2019 17:59:33.2188
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2301
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU3VuLCAyMDE5LTAxLTI3IGF0IDEwOjE5IC0wNTAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBXZSBjYW4ndCBoYXZlIG5mc193Yl9wYWdlKCkgdHJ1bmNhdGUgdGhlIHBhZ2UgZnJv
bSB0aGUgbWFwcGluZyBpZg0KPiB0aGVyZSdzDQo+IGFuIGVycm9yIG9uIHRoZSBjb250ZXh0IHdp
dGhvdXQgcmV0dXJuaW5nIHRoYXQgZXJyb3IsIGJlY2F1c2Ugd2UgbWF5DQo+IGJlIGluDQo+IG5m
c191cGRhdGVwYWdlKCkgaG9sZGluZyB0aGUgcGFnZSBhbmQgdHJ5aW5nIHRvIHVwZGF0ZSB0aGUN
Cj4gcmVxdWVzdC4gIE5vdA0KPiBoYXZpbmcgYW55IGVycm9yIHJldHVybmVkIG1lYW5zIHdlJ2xs
IHByb2NlZWQgdG8gY3JlYXRlIGEgbmV3IHJlcXVlc3QNCj4gYW5kDQo+IGRlcmVmZXJlbmNlIHRo
ZSB0cnVuY2F0ZWQgcGFnZS0+bWFwcGluZy4NCj4gDQo+IElmIHdlJ3JlIGdvaW5nIHRvIHJlbW92
ZSB0aGUgcGFnZSwgYWx3YXlzIHJldHVybiB0aGUgZXJyb3IgdGhhdA0KPiBzaWduYWxlZCB1cw0K
PiB0byBkbyBzbyBpbiBuZnNfcGFnZV9hc3luY19mbHVzaCgpLg0KPiANCj4gRml4ZXM6IGMzNzNm
ZmY3YmQyNSAoIk5GU3Y0OiBEb24ndCBzcGVjaWFsIGNhc2UgImxhdW5kZXIiIikNCj4gQ2M6IHN0
YWJsZUB2Z2VyLmtlcm5lbC5vcmcgIyB2NC4xMQ0KPiBTaWduZWQtb2ZmLWJ5OiBCZW5qYW1pbiBD
b2RkaW5ndG9uIDxiY29kZGluZ0ByZWRoYXQuY29tPg0KPiAtLS0NCj4gIGZzL25mcy93cml0ZS5j
IHwgNiArKysrLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDIgZGVsZXRp
b25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL3dyaXRlLmMgYi9mcy9uZnMvd3JpdGUu
Yw0KPiBpbmRleCA1YTBiYmY5MTdhMzIuLmMyNzQzMzkxNzZjYyAxMDA2NDQNCj4gLS0tIGEvZnMv
bmZzL3dyaXRlLmMNCj4gKysrIGIvZnMvbmZzL3dyaXRlLmMNCj4gQEAgLTYyMiw5ICs2MjIsMTEg
QEAgc3RhdGljIGludCBuZnNfcGFnZV9hc3luY19mbHVzaChzdHJ1Y3QNCj4gbmZzX3BhZ2Vpb19k
ZXNjcmlwdG9yICpwZ2lvLA0KPiAgCVdBUk5fT05fT05DRSh0ZXN0X2JpdChQR19DTEVBTiwgJnJl
cS0+d2JfZmxhZ3MpKTsNCj4gIA0KPiAgCXJldCA9IDA7DQo+IC0JLyogSWYgdGhlcmUgaXMgYSBm
YXRhbCBlcnJvciB0aGF0IGNvdmVycyB0aGlzIHdyaXRlLCBqdXN0IGV4aXQNCj4gKi8NCj4gLQlp
ZiAobmZzX2Vycm9yX2lzX2ZhdGFsX29uX3NlcnZlcihyZXEtPndiX2NvbnRleHQtPmVycm9yKSkN
Cj4gKwkvKiBJZiB0aGVyZSBpcyBhIGZhdGFsIG9uIHNlcnZlciBlcnJvciBvbiB0aGlzIGNvbnRl
eHQsIGp1c3QNCj4gZXhpdCAqLw0KPiArCWlmIChuZnNfZXJyb3JfaXNfZmF0YWxfb25fc2VydmVy
KHJlcS0+d2JfY29udGV4dC0+ZXJyb3IpKSB7DQo+ICsJCXJldCA9IHJlcS0+d2JfY29udGV4dC0+
ZXJyb3I7DQo+ICAJCWdvdG8gb3V0X2xhdW5kZXI7DQo+ICsJfQ0KPiAgDQo+ICAJaWYgKCFuZnNf
cGFnZWlvX2FkZF9yZXF1ZXN0KHBnaW8sIHJlcSkpIHsNCj4gIAkJcmV0ID0gcGdpby0+cGdfZXJy
b3I7DQoNCkhpIEJlbg0KDQpXZSB3ZXJlIGFwcGFyZW50bHkgYm90aCBsb29raW5nIGF0IHRoZSBz
YW1lIGNvZGUgbGFzdCB3ZWVrIOKYui4gSSBoYXZlIGENCnNpbWlsYXIgcGF0Y2gsIGJ1dCB0aGF0
IGFsc28gZml4ZXMgYSBzaW1pbGFyIGNsb2JiZXJpbmcgaXNzdWUgd2l0aCB0aGUNCm5mc19lcnJv
cl9pc19mYXRhbCgpIGVycm9yIGp1c3QgYSBmZXcgbGluZXMgZnVydGhlciBkb3duLg0KDQpXaXRo
b3V0IHRoZSBleHRyYSBodW5rLCB3ZSBjb3VsZCBlbmQgdXAgY29udmVydGluZyBhbiBpbnRlcnJ1
cHRlZCBjYWxsDQppbnRvIGEgJ3N1Y2Nlc3NmdWwnIHdyaXRlLg0KDQpDaGVlcnMNCiAgVHJvbmQN
Cg0KLS0tDQpGcm9tIDY3NmQzMzQwYWJjMjZjZTlmZjJiNzYwOWMyOTM0NTRkZWM2ZDQ4OTcgTW9u
IFNlcCAxNyAwMDowMDowMCAyMDAxDQpGcm9tOiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xl
YnVzdEBoYW1tZXJzcGFjZS5jb20+DQpEYXRlOiBUdWUsIDIyIEphbiAyMDE5IDA3OjM0OjQ1IC0w
NTAwDQpTdWJqZWN0OiBbUEFUQ0hdIE5GUzogRml4IHVwIHJldHVybiB2YWx1ZSBvbiBmYXRhbCBl
cnJvcnMgaW4NCiBuZnNfcGFnZV9hc3luY19mbHVzaCgpDQoNCkVuc3VyZSB0aGF0IHdlIHJldHVy
biB0aGUgZmF0YWwgZXJyb3IgdmFsdWUgdGhhdCBjYXVzZWQgdXMgdG8gZXhpdA0KbmZzX3BhZ2Vf
YXN5bmNfZmx1c2goKS4NCg0KRml4ZXM6IGE2NTk4ODEzYTRjNSAoIk5GUzogRG9uJ3Qgd3JpdGUg
YmFjayBmdXJ0aGVyIHJlcXVlc3RzLi4uIikNClNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVz
dCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCkNjOiBzdGFibGVAdmdlci5rZXJu
ZWwub3JnICMgdjQuMTIrDQotLS0NCiBmcy9uZnMvd3JpdGUuYyB8IDkgKysrKystLS0tDQogMSBm
aWxlIGNoYW5nZWQsIDUgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdp
dCBhL2ZzL25mcy93cml0ZS5jIGIvZnMvbmZzL3dyaXRlLmMNCmluZGV4IDVhMGJiZjkxN2EzMi4u
ZjEyY2IzMWE0MWU1IDEwMDY0NA0KLS0tIGEvZnMvbmZzL3dyaXRlLmMNCisrKyBiL2ZzL25mcy93
cml0ZS5jDQpAQCAtNjIxLDExICs2MjEsMTIgQEAgc3RhdGljIGludCBuZnNfcGFnZV9hc3luY19m
bHVzaChzdHJ1Y3QgbmZzX3BhZ2Vpb19kZXNjcmlwdG9yICpwZ2lvLA0KIAluZnNfc2V0X3BhZ2Vf
d3JpdGViYWNrKHBhZ2UpOw0KIAlXQVJOX09OX09OQ0UodGVzdF9iaXQoUEdfQ0xFQU4sICZyZXEt
PndiX2ZsYWdzKSk7DQogDQotCXJldCA9IDA7DQorCXJldCA9IHJlcS0+d2JfY29udGV4dC0+ZXJy
b3I7DQogCS8qIElmIHRoZXJlIGlzIGEgZmF0YWwgZXJyb3IgdGhhdCBjb3ZlcnMgdGhpcyB3cml0
ZSwganVzdCBleGl0ICovDQotCWlmIChuZnNfZXJyb3JfaXNfZmF0YWxfb25fc2VydmVyKHJlcS0+
d2JfY29udGV4dC0+ZXJyb3IpKQ0KKwlpZiAobmZzX2Vycm9yX2lzX2ZhdGFsX29uX3NlcnZlcihy
ZXQpKQ0KIAkJZ290byBvdXRfbGF1bmRlcjsNCiANCisJcmV0ID0gMDsNCiAJaWYgKCFuZnNfcGFn
ZWlvX2FkZF9yZXF1ZXN0KHBnaW8sIHJlcSkpIHsNCiAJCXJldCA9IHBnaW8tPnBnX2Vycm9yOw0K
IAkJLyoNCkBAIC02MzUsOSArNjM2LDkgQEAgc3RhdGljIGludCBuZnNfcGFnZV9hc3luY19mbHVz
aChzdHJ1Y3QgbmZzX3BhZ2Vpb19kZXNjcmlwdG9yICpwZ2lvLA0KIAkJCW5mc19jb250ZXh0X3Nl
dF93cml0ZV9lcnJvcihyZXEtPndiX2NvbnRleHQsIHJldCk7DQogCQkJaWYgKG5mc19lcnJvcl9p
c19mYXRhbF9vbl9zZXJ2ZXIocmV0KSkNCiAJCQkJZ290byBvdXRfbGF1bmRlcjsNCi0JCX0NCisJ
CX0gZWxzZQ0KKwkJCXJldCA9IC1FQUdBSU47DQogCQluZnNfcmVkaXJ0eV9yZXF1ZXN0KHJlcSk7
DQotCQlyZXQgPSAtRUFHQUlOOw0KIAl9IGVsc2UNCiAJCW5mc19hZGRfc3RhdHMocGFnZV9maWxl
X21hcHBpbmcocGFnZSktPmhvc3QsDQogCQkJCU5GU0lPU19XUklURVBBR0VTLCAxKTsNCi0tIA0K
Mi4yMC4xDQoNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
