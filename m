Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 859FBC65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 22:36:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2357520645
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 22:36:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="As56aB4x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2357520645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726297AbeLLWgD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 17:36:03 -0500
Received: from mail-eopbgr680116.outbound.protection.outlook.com ([40.107.68.116]:33888
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726294AbeLLWgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 17:36:03 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5P47SxEOqft8Pn86Gg3wUTRDeDABWB0osKYPLyVn7G0=;
 b=As56aB4xxDfGHw6VEcxZUMQRqzTy3dE5llFeTqaycpliabHgObUXMZxtou5Sg6S7SxEEPFAWl8pJF3lvq6U82JTBZSzvzQaOX1ROAwDbw/rFSa3PdPZMU/Vd1ZUjuXsohXQmoUc2EI1xYG0rKFI6gZ48M7gHsYJHrOnAqbOf08U=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2496.namprd13.prod.outlook.com (52.135.95.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.8; Wed, 12 Dec 2018 22:35:19 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1425.016; Wed, 12 Dec 2018
 22:35:19 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "ffilz@redhat.com" <ffilz@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: What is a reasonable minimum lease time?
Thread-Topic: What is a reasonable minimum lease time?
Thread-Index: AQHUkl/DKL24851jbkOOqxA4Y/SMO6V7qneAgAAGrwA=
Date:   Wed, 12 Dec 2018 22:35:18 +0000
Message-ID: <1635ac89b3d9e1f884289d5b7a20056874d10329.camel@hammerspace.com>
References: <043701d4925f$7b244530$716ccf90$@mindspring.com>
         <378995dd-00b2-a2e8-fbee-025d4fc2eb24@redhat.com>
         <1207626803.5525544.1544652679619.JavaMail.zimbra@desy.de>
In-Reply-To: <1207626803.5525544.1544652679619.JavaMail.zimbra@desy.de>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [24.75.238.70]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2496;6:Pk7rAaFFA6SrwQxBwMk6BwXanMwseYh1b9PtUHElUvX7533uLqBwJASQSBpI6djS8LGze7aGv6wXNEoEBHHJMIFCpzAmeX9m93vaNWAy7amtj1o2oSyiDA05nZb+TryBmn0mfw1Ukn2jNeaDExFMsb+Z3v5SHN8y+9Y6gh4tt/5UlV/WGNzqZ6hcegVhjbbRPsQwmN+OOmprlg4cEqZq8j2dVJIBbR6B/UbbHjgSqK9Cu+a+DevLKgSGsXJ6bEDJDp3L5uaKSBFOLybQ34xs44JTmRzLEjRQWWikVBWHJN7nPvnvPpM0uR67jXaw29mWMKuTseIOt+IV4QupdHSJmLuoxhA3EGTl0TMPsNOSm6Lu7bxes6l4ZCaLS6x5roUjd1L6e2qIBoKa7+/9SW0aC5hDSf0UOxeiPT7mYL9H7/qE2+0tEAekp66AIfvKYeeCIvTJXy5Bkr/bLnicFNlvzg==;5:9zJnyFNUZJJEqH88SX0oRqYcSFk8MnS4lYGM6xdN7bcR/uG9dNfnmh1qQKxnWPOdb20PH0sJWtB6QgQiyCr5GOGiI6kyWlXx1tam0czsdMZVE6Dk7HMBGYgX6N3MgtX3LtbJg8TZPlzjo1R5u4plcWyY8CbPnq1NIe8a/tfWjmA=;7:keAUELKqJrOtNsJfc3hFca+4TpDkaRyz0FDXO+UyJi5Kq5GuEgvTPZnoWV5YUUR7otlitMsPOZ+4hJ8rmDxcFpi/FSZBrLiivN5wbrEsXGaIylQsjKzeehjqEMppAHef5nT0ugowEuAb4ioMu74Zkg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 9ccb9d0b-5cc7-432a-ebea-08d66082185f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2496;
x-ms-traffictypediagnostic: SN6PR13MB2496:
x-microsoft-antispam-prvs: <SN6PR13MB2496516FF3CF170CBB8B7B17B8A70@SN6PR13MB2496.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230020)(999002)(6040522)(2401047)(8121501046)(5005006)(10201501046)(3231475)(944501520)(52105112)(93006095)(93001095)(3002001)(148016)(149066)(150057)(6041310)(20161123560045)(20161123558120)(20161123562045)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2496;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2496;
x-forefront-prvs: 0884AAA693
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(136003)(39830400003)(376002)(366004)(13464003)(199004)(189003)(256004)(14444005)(2906002)(25786009)(4001150100001)(105586002)(229853002)(106356001)(478600001)(186003)(76176011)(97736004)(102836004)(53546011)(3846002)(6116002)(6506007)(7736002)(4326008)(6436002)(86362001)(26005)(68736007)(66066001)(305945005)(53936002)(6512007)(6246003)(71200400001)(5660300001)(71190400001)(6486002)(15974865002)(8936002)(476003)(486006)(14454004)(11346002)(36756003)(99286004)(118296001)(2501003)(2616005)(81156014)(110136005)(81166006)(316002)(8676002)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2496;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: qYw4mINnB5eEuruk2zFQITdUcNo8ikRb0caf8d1Qgv4x1GqGZaTaPrZ2A9Jxk48jn5+8Mq2YF2g242qt46kEiePcbTiBLWLIH1oZantnnhZoDuu+fZqtnoDLFWe+QvdMh6B9tJvh0+QGcScymDVgxtr/58X556co2zUgqPl2x1DfvraXszzbVFh/dC8ZY02QPOJkQ3T3XjAiURQuvpbg54/o0EaCwj0syuXTVEB7IuNlFsXw6FhP/QNakEVrTJxDGzUSU2gfHiNbTG31aczwonbkvkp2mXGnMby/ATGHpXsXjUk+P2w0hSCZN7UccKe9
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <DDE9C1811100214FA0AC83ECE1DB436C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9ccb9d0b-5cc7-432a-ebea-08d66082185f
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Dec 2018 22:35:18.8787
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2496
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE4LTEyLTEyIGF0IDIzOjExICswMTAwLCBNa3J0Y2h5YW4sIFRpZ3JhbiB3cm90
ZToNCj4gSGkgRnJhbmssDQo+IA0KPiBJTUhPLCB2ZXJ5IHNob3J0IGxlYXNlcyBjYW4gdHJpZ2dl
ciBhIG1hc3NpdmUgc3RhdGUgcmVjb3Zlcnkgb24NCj4gbmV0d29yayBoaWNjdXBzLg0KPiANCj4g
T3VyIHNlcnZlciBvZmZlcnMgOTAgc2Vjb25kcyB0byB0aGUgY2xpZW50LiBUaGUgY2xpZW50IHVz
dWFsbHkgcmVuZXcNCj4gbGVhc2UgKHNlcXVlbmNlKSBvbmNlIGluIGEgbWludXRlLg0KPiBEdXJp
bmcgaGlnaCBJTyBwZXJpb2RzIGxlYXNlIGlzIG5vdCByZXF1aXJlZCBhbmQgd2hlbiBpZGxlLCB0
aGVuIG9uY2UNCj4gaW4gYSBtaW51dGUgaXMgc3VmZmljaWVudCB0bw0KPiBrZWVwIHRoZSBtb3Vu
dCBhbGl2ZS4gSW4gYSB3b3JzdCBjYXNlLCB3aGVuIGEgY2xpZW50IGdvdCBhIGxvY2sgYW5kDQo+
IGRpc3BlcnNhbCwgYSBjb21wZXRpbmcgbG9jay9vcGVuDQo+IHdpbGwgYmxvY2sgb25seSBmb3Ig
OTBzLiBXaGF0ZXZlciBudW1iZXIgeW91IGhhdmUsIGl0IHNob3VsZCBiZSANCj4gDQoNCkdpdmVu
IHRoYXQgVENQIFNZTiB0aW1lb3V0cyBnZW5lcmFsbHkgZm9sbG93IGFuIGV4cG9uZW50aWFsIGxh
dywgYW5kDQpjYW4gZWFzaWx5IHJlYWNoID4gMjBzLCB0aGVuIEknZCBhcmd1ZSBhIDJzIGxlYXNl
IGlzIG9uIHRoZSBleHRyZW1lbHkNCnNob3J0IGVuZCBvZiB0b2xlcmFibGUuIFlvdSBwcm9iYWJs
eSB3YW50IHRvIGRvIHNvbWV0aGluZyBhIGxvdCBsYXJnZXINCmlmIHlvdSB3YW50IGxvY2sgcmVj
b3ZlcnkgYWZ0ZXIgYSBzZXJ2ZXIgY3Jhc2ggdG8gYmUgcmVsaWFibGUuDQoNCj4gDQo+IEJUVywg
SUVURiBtYWlsaW5nIGxpc3QgcHJvYmFibHkgYSBiZXR0ZXIgcGxhY2UgZm9yIHRoaXMgcXVlc3Rp
b24uDQo+IA0KPiBSZWdhcmRzLA0KPiAgICBUaWdyYW4uDQo+IA0KPiANCj4gLS0tLS0gT3JpZ2lu
YWwgTWVzc2FnZSAtLS0tLQ0KPiA+IEZyb206ICJGcmFuayBGaWx6IiA8ZmZpbHpAcmVkaGF0LmNv
bT4NCj4gPiBUbzogImxpbnV4LW5mcyIgPGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+DQo+ID4g
U2VudDogV2VkbmVzZGF5LCBEZWNlbWJlciAxMiwgMjAxOCAxMDoxNDo1OSBQTQ0KPiA+IFN1Ympl
Y3Q6IFdoYXQgaXMgYSByZWFzb25hYmxlIG1pbmltdW0gbGVhc2UgdGltZT8NCj4gPiBXZSBoYXZl
IGFuIGlzc3VlIHdpdGggdGhlIEdhbmVzaGEgc2VydmVyIHdpdGggdmVyeSBzaG9ydCAoMiBzZWNv
bmQpDQo+ID4gbGVhc2UgdGltZXMuIEdhbmVzaGEgdXNlcyBhIDEgc2Vjb25kIGdyYW51bGFyaXR5
IGZvciBsZWFzZQ0KPiA+IG1hbmFnZW1lbnQsDQo+ID4gYW5kIGNvbnNpZGVycyBhIHRpbWUgc2lu
Y2UgbGFzdCByZW5ld2VkIGVxdWFsIHRvIHRoZSBsZWFzZSB0aW1lIGFzDQo+ID4gdG9vDQo+ID4g
bG9uZy4gVGhlIHJlc3VsdCBpcyB0aGF0IHRoZSBsZWFzZSBwZXJpb2QgbWF5IGJlIHNob3J0IGNs
b3NlIHRvIDINCj4gPiBzZWNvbmRzIGRlcGVuZGluZyBvbiB3aGVuIHdpdGhpbiBhIGdpdmVuIHNl
Y29uZCB0aGluZ3MgYWN0dWFsbHkNCj4gPiBoYXBwZW5lZA0KPiA+IChzbyBhIGxhc3QgcmVuZXcg
YXQgMC45OSB3aXRoIGEgc3Vic2VxdWVudCByZW5ldyBhdCAyLjAxIHdoaWNoIGlzDQo+ID4ganVz
dA0KPiA+IG92ZXIgb25lIHNlY29uZCBsb29rcyBsaWtlIDIgc2Vjb25kcyB0byBHYW5lc2hhIGFu
ZCB0aHVzIGlzID49IHRoZQ0KPiA+IDINCj4gPiBzZWNvbmQgbGVhc2UgdGltZSBhbmQgbm90IGdv
b2QgZW5vdWdoLiBBIHNpbXBsZSBjaGFuZ2Ugd291bGQgYmUgdG8NCj4gPiBjaGFuZ2UgdGhlID49
IHRvIGEgPiwgd2hpY2ggZ2l2ZXMgb25lIG1vcmUgc2Vjb25kLCBidXQgaXQgc3RpbGwNCj4gPiBj
b3VsZA0KPiA+IHJlc3VsdCBpbiB0aGUgbGVhc2UgdGltZSBiZWluZyBhbG1vc3QgMSBzZWNvbmQg
dG9vIHNob3J0IHdoaWNoIGlzDQo+ID4gc2lnbmlmaWNhbnQgd2l0aCBhIDIgc2Vjb25kIGxlYXNl
IHRpbWUuIEJ1dCBpZiB0aGUgbWluaW11bQ0KPiA+IHJlYXNvbmFibGUNCj4gPiBsZWFzZSB0aW1l
IGlzIG1vcmUgbGlrZSA1IG9yIDEwIHNlY29uZHMsIHRoYXQgMSBzZWNvbmQgYmVjb21lcyBsZXNz
DQo+ID4gc2lnbmlmaWNhbnQuDQo+ID4gDQo+ID4gVGhlIGJpZ2dlciBmaXggd291bGQgYmUgdG8g
dXNlIGEgZmluZXIgZ3JhaW5lZCB0aW1lLCBidXQgdGhhdCBhZGRzDQo+ID4gY29tcGxleGl0eSwg
YnV0IGlmIHBlb3BsZSByZWFsbHkgd2FudCB0byBydW4gd2l0aCAyIHNlY29uZCBsZWFzZQ0KPiA+
IHRpbWVzDQo+ID4gYW5kIGl0IG1ha2VzIGFueSBraW5kIG9mIHNlbnNlLCB3ZSB3b3VsZCBuZWVk
IHRvIG1ha2UgdGhhdCBjaGFuZ2UuDQo+ID4gDQo+ID4gVGhhbmtzDQo+ID4gDQo+ID4gDQo+ID4g
RnJhbmsNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpDVE8sIEhhbW1lcnNwYWNlIEluYw0KNDMwMCBF
bCBDYW1pbm8gUmVhbCwgU3VpdGUgMTA1DQpMb3MgQWx0b3MsIENBIDk0MDIyDQp3d3cuaGFtbWVy
LnNwYWNlDQoNCg0K
