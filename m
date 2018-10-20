Return-Path: <SRS0=ViGU=NA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB76FC67863
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Oct 2018 18:22:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 88AC921470
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Oct 2018 18:22:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="v0znXtpr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88AC921470
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727413AbeJUCd0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 20 Oct 2018 22:33:26 -0400
Received: from mail-co1nam03on0131.outbound.protection.outlook.com ([104.47.40.131]:37597
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727373AbeJUCd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Oct 2018 22:33:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HFvk5UlrYTsyaCjfCQxybMdNLzcPLCvDYFKKtXbawPE=;
 b=v0znXtprDJDDVrjgY6Qx826U+Fx/WqptuKVP69/vIYt2URy21KXstH2sX1lef4fXW5vhMiD5hqwLcmDDjkA/DWbNpEvMurn0F06tcfqB2DeAajrWbFhYC23TnFvbgu4ZvlRPIN6ou+598itDyb8xIXj/6HJzfZqkPHhaEVN92CI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2399.namprd13.prod.outlook.com (52.135.94.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1273.13; Sat, 20 Oct 2018 18:22:07 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1273.012; Sat, 20 Oct 2018
 18:22:07 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: readdir request re-requests entries
Thread-Topic: readdir request re-requests entries
Thread-Index: H8yKhw0r4+oCbbuxhZVTOCszpD1bqo+8NYCA
Date:   Sat, 20 Oct 2018 18:22:07 +0000
Message-ID: <f9f24f44266292dc5fa41f633344b11cf84cc4f8.camel@hammerspace.com>
References: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
In-Reply-To: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2399;6:gyosGVvcG1TqK2QiFEx3zyO5RwU00ivMoYQhLLu4OlVl8ur5ZFEsa+Oa2JN3dEqWJrZ5C7k+b/RZCm4Tu/FJ0Y558Rv7db90xCY6mZVZsYlRvHTdj8hoKGO7Hq/APYFBj3nAieOEZHKKCZfkiIoFHksh5Q636MJAUYeI59BfZPi3SVUVd4qPTqKSbJHd0lNDZnoetyV2NfXaDaQ4bRQLXMGuiyyqilFUUPXSXGiXH8ZqP3qenavjz+ajfl/MljDPR9x40PuLjFnkh7KNoNb16ZNWudfaWl2SP16w6WB+PpOrIt2ZYUZj3JViCyDnMhLnPWt1llPMkjh5qhHNjRZWEVw7ARIaKdU35cdWBs7GcMx5BQ4nt86VpGKo/SOebcNSjVpJAo5miEtv5DOP7ZOxzDQ+SMwoHv7y9vSvauJDIUoZA4sdTXrS5nT/cAfipssJfPFuNkOc2W6b3CXno7J5+w==;5:WdZyQJPj4x6mZti3VQ18rE2lTRhqTQATrhAGsjbvSZXsYEhb/PoKGs7mpjqEtGgGGvI4zUsLsHLHuyE5e+N6pnWR3xHicmyQzXAoJRk6qXeXnSThyG80ltzbGWyJ9pH+hStyI2Av9lUPCKghcIHMcYwD0y03N4FTM1OiGKCBDHM=;7:cnjYqgo1qUtgtdDzuXA1oM0MA1QwGSpZX4CmD9HvV56RbdjyDr72euYyS4Wjp6GVv8zSkL3Iezxq4QttAdS3NeqXV+hIlnbPJcXDC/4S9S8ULj2iKJbxIkr0avxH9Br/sR+vqJff1NV9v9yqYGlQ3A==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 5179b3ae-1872-44dd-dfbc-08d636b8f168
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2399;
x-ms-traffictypediagnostic: SN6PR13MB2399:
x-microsoft-antispam-prvs: <SN6PR13MB2399D0883C7E980E8F33BCB2B8FA0@SN6PR13MB2399.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(10201501046)(3002001)(3231355)(944501410)(52105095)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123562045)(20161123564045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2399;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2399;
x-forefront-prvs: 0831C25939
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(396003)(136003)(39830400003)(199004)(189003)(105586002)(25786009)(5660300001)(2900100001)(8676002)(6506007)(3480700004)(7736002)(81156014)(4001150100001)(81166006)(186003)(6486002)(2906002)(76176011)(110136005)(97736004)(305945005)(6512007)(14444005)(256004)(8936002)(6436002)(68736007)(118296001)(102836004)(53936002)(476003)(86362001)(2616005)(3846002)(6116002)(14454004)(478600001)(11346002)(413944005)(71190400001)(71200400001)(2501003)(446003)(486006)(5250100002)(26005)(66066001)(106356001)(6346003)(99286004)(6246003)(36756003)(229853002)(316002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2399;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-message-info: CYN9SEG8AX5P9G758PmeL0LgIb1XxgUIXD1boXJ4i/9XaUozUKWAAC+AK5e32Z9IBroM0zqsQ4VT/w4AjeNgXS7friU4Yr98/YZCcIOMKmHG0FIFb4+cOwc6BW8olrWoAEk+LcO07W/WAl5500y1h7sj0tYUM98khgBKq6kgaPPVgsVYe0TIBbPXbhFvZ2WBxNrv+F0D1h6MFJF9A4I01jnhMAVE8mZWpLVPKXnilqw0Hnq6MEU3CAa3ppbSFBGNY5MXqJmIZ6UzQHwht8AiED999JUzZ1hecreg5JliHkEXUMrv0X/w8K+r1EubWBsGnthyLu9iF/RK8l4919PeemV9w02lAKOjIMikeQuYBqw=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <B61FA519F3381546854156846E6E576C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5179b3ae-1872-44dd-dfbc-08d636b8f168
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Oct 2018 18:22:07.0630
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2399
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
Message-ID: <20181020182207.QvfxEttc6zzbvvulpHM8sj33TW29FqfyDxZ4DLcimKo@z>

T24gU2F0LCAyMDE4LTEwLTIwIGF0IDAwOjExICswMjAwLCBNa3J0Y2h5YW4sIFRpZ3JhbiB3cm90
ZToNCj4gRGVhciBORlMgZmVsbG93cywNCj4gDQo+IHdlIGhhdmUgbm90aWNlIGEgYmVoYXZpb3Ig
b2YgbmZzIGNsaWVudCB3aGVuIGl0ZXJhdGluZyBvdmVyIGEgYmlnDQo+IGRpcmVjdG9yeS4gVGhl
IGNsaWVudCByZS1yZXF1ZXN0cyBlbnRyaWVzIHRoYXQgYWxyZWFkeSBoYXMgYmVlbi4gRm9yDQo+
IGV4YW1wbGUsIGEgY2xpZW50IGlzc3VlcyBSRUFERElSIG9uIGEgZGlyZWN0b3J5IHdpdGggMWsg
ZmlsZXMuDQo+IEluaXRpYWwgY29va2llDQo+IGlzIDAsIG1heGNvdW50IDMyNzY4Lg0KPiANCj4g
YyAtPiBzIGNvb2tpZSAwDQo+IHMgLT4gYyBsYXN0IGNvb2tpZSAxNTkNCj4gYyAtPiBzIGNvb2tp
ZSAxMDUNCj4gcyAtPiBjIGxhc3QgY29va2llIDI1OQ0KPiBjIC0+IHMgY29va2llIDIwNw0KPiAN
Cj4gLi4uDQo+IA0KPiBhbmQgc28gb24uIFRoZSBpbnRlcmVzdGluZyB0aGluZyBpcywgaWYgSSBt
b3VudCB3aXRoIHJzaXplIDgxOTINCj4gKG1heGNvdW50IDgxOTIpLCB0aGVuIGZpcnN0IGNvdXBs
ZQ0KPiBvciByZXF1ZXN0cyBhcmUgYXNraW5nIGZvciBjb3JyZWN0IGNvb2tpZXMgLSAwLCA0Mywg
ODEsIDEwNS4gQWdhaW4NCj4gMTA1IGFzIHdpdGggbWF4Y291bnQgMzI2NzguIFRvDQo+IG1lIGl0
IGxvb2tzIGxpa2UgdGhhdCB0aGVyZSBpcyBzb21lIGtpbmQgb2YgaW50ZXJuYWwgcGFnZSAoYWN0
dWFsbHkNCj4gTkZTX01BWF9SRUFERElSX1BBR0VTKSBhbGlnbm1lbnQNCj4gYW5kIGVudHJpZXMg
d2hpY2ggZG8gbm90IGZpdCBpbnRvIGluaXRpYWxseSBhbGxvY2F0ZWQgUEFHRV9TSVpFICoNCj4g
TkZTX01BWF9SRUFERElSX1BBR0VTIG1lbW9yeQ0KPiBqdXN0IGdldCBkcm9wcGVkLg0KPiANCj4g
QXMgMzAlIG9mIGVhY2ggcmVwbHkgaXMgdGhyb3duIGF3YXksIGxpc3Rpbmcgb2YgbGFyZ2UgZGly
ZWN0b3JpZXMgbWF5DQo+IHByb2R1Y2UgbXVjaCBtb3JlIHJlcXVlc3RzDQo+IHRoYW4gcmVxdWly
ZWQuDQo+IA0KPiBJcyBpdCBhbiBleHBlY3RlZCBiZWhhdmlvcj8NCg0KWWVzLg0KDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
