Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 190E7C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 21:51:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0BF720674
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 21:51:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="WEFs7ijs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726511AbfDBVvr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 17:51:47 -0400
Received: from mail-eopbgr680104.outbound.protection.outlook.com ([40.107.68.104]:12929
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726097AbfDBVvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 17:51:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lx2Zja3GqEy7a1vgEEHBid9JMYbBdmB+T+LPq5FHP84=;
 b=WEFs7ijsNtFqIMKi+TM9JZ4FUvZgtCeGKQPdUIoeSli0tsJVVHSF9euvAxTkGu8K7uHFWlckKmbaYKJZB1K5rDQr55WQ37XkxvLnmJUdeT0hi042UCgoG0yro4mLh+DW9Rz+fDDrZlf8Ts9+AJ/FYwUDkS+d2n8xHpmBIEyG7IE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2303.namprd13.prod.outlook.com (52.135.94.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.9; Tue, 2 Apr 2019 21:51:42 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1771.007; Tue, 2 Apr 2019
 21:51:42 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "bradley.kuszmaul@oracle.com" <bradley.kuszmaul@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: directory delegations
Thread-Topic: directory delegations
Thread-Index: AQHU6KcNiRPQ7r4+DEebmwXdEDXzDKYpDBcAgAAU+ICAACXbAIAAJEkA
Date:   Tue, 2 Apr 2019 21:51:42 +0000
Message-ID: <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
         <20190402161116.GA2828@fieldses.org>
         <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
         <20190402194148.GA5269@fieldses.org>
In-Reply-To: <20190402194148.GA5269@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [63.235.104.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 40062463-5383-4c8d-3e63-08d6b7b56497
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2303;
x-ms-traffictypediagnostic: SN6PR13MB2303:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB230321D622556447DF07E5A5B8560@SN6PR13MB2303.namprd13.prod.outlook.com>
x-forefront-prvs: 0995196AA2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(366004)(376002)(346002)(136003)(396003)(189003)(199004)(110136005)(305945005)(256004)(76176011)(86362001)(186003)(68736007)(53936002)(11346002)(2501003)(81156014)(4326008)(3480700005)(26005)(6512007)(6306002)(6486002)(105586002)(5660300002)(118296001)(99286004)(2906002)(93886005)(66066001)(6246003)(316002)(36756003)(3846002)(71200400001)(229853002)(106356001)(97736004)(486006)(221733001)(6116002)(102836004)(14454004)(7736002)(966005)(476003)(446003)(25786009)(2616005)(8936002)(8676002)(6506007)(478600001)(81166006)(7116003)(71190400001)(6436002)(111123002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2303;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: vmPuFTy/sHTkVJUrtyRXaVR/6Xlyli05DL0RsJDCEqQLbj5x8k1SlFGD4LEL4fl3DO6I6UYgCbcwrmiqDhWyC9oNQdDPqCVZJ8Ca8r2gJBKFSjl2G4ej6fvugflqRt1IdI0I2uyLvb1Duv/heB/fvC28BqETwpKJiZRGnbdnUqEvLHWa41+TIvM39VAOyw5hsWOPiVBQcDexLVu4DC7y748PpxqmwD+ipeEM3SIUhk8zoEkaMMIMMFf3KbbdUIyUWIjHkvo7JIWQ5gqGqsCqtsxjRZZ7vMKN6AsyNZclnnOrlDUUl7MlXZ0Kn2GpCTWljP4Jq+IX3GBkEFKfC7rkcmQt3QIup5JQf4ewpoMU0oyaH4FdoA83DCVUwUGQ/KUqw5/nYOHzZkVGmOFt/chpAiom44MmtnkDNpY3KP6wDoY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <64096E5C9108794789701650882273AC@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 40062463-5383-4c8d-3e63-08d6b7b56497
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Apr 2019 21:51:42.2519
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2303
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTA0LTAyIGF0IDE1OjQxIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFR1ZSwgQXByIDAyLCAyMDE5IGF0IDAxOjI2OjE5UE0gLTA0MDAsIEJyYWRsZXkgQy4g
S3Vzem1hdWwgd3JvdGU6DQo+ID4gTXkgc2ltcGxlIG1vZGVsIG9mIG1ldGFkYXRhIG9wZXJhdGlv
bnMgaXMgdG8gdW50YXIgc29tZXRoaW5nIGxpa2UNCj4gPiB0aGUgbGludXggc291cmNlcy4NCj4g
PiANCj4gPiBFYWNoIGZpbGUgaW5jdXJzIGEgTE9PS1VQLCBDUkVBVEUsIFNFVEFUVFIsIGFuZCBX
UklURSwgZWFjaCBvZg0KPiA+IHdoaWNoDQo+ID4gaXMgZmFpcmx5IGhpZ2ggbGF0ZW5jeSAoZXZl
biB0aGUgV1JJVEUgZW5kcyB1cCBiZWluZyBkb25lDQo+ID4gZXNzZW50aWFsbHkgc3luY2hyb25v
dXNseSBiZWNhdXNlIHRhciBjbG9zZXMgdGhlIGZpbGUgYWZ0ZXIgaXRzDQo+ID4gd3JpdGUoMikg
Y2FsbC4pDQo+IA0KPiBBbiBvcmRpbmFyeSBmaWxlIHdyaXRlIGRlbGVnYXRpb24gY2FuIGhlbHAg
d2l0aCBzb21lIG9mIHRoYXQuDQo+IA0KPiA+IEkgZ3Vlc3MgZGlyZWN0b3J5IGRlbGVnYXRpb25z
IG1pZ2h0IHNhdmUgdGhlIGNvc3Qgb2YgTE9PS1VQLg0KPiA+IA0KPiA+IElzIHRoZXJlIGFueSBo
b3BlIGZvciBnZXR0aW5nIHdyaXRlIGRlbGVnYXRpb25zPw0KPiA+IA0KPiA+IFdoYXQgb3RoZXIg
c3RlcHMgbWlnaHQgYmUgcG9zc2libGU/DQo+IA0KPiBUcm9uZCwgd2Fzbid0IHRoZXJlIGEgZHJh
ZnQgZGVzY3JpYmluZyB5b3VyIGlkZWEgdGhhdCBhIHNlcnZlciBzaG91bGQNCj4gYmUNCj4gYWJs
ZSB0byBncmFudCBhIHdyaXRlIGRlbGVnYXRpb24gb24gY3JlYXRlIGFuZCBkZWxheSB0aGUgc3lu
Yz8gIEkNCj4gY2FuJ3QNCj4gZmluZCBpdCByaWdodCBub3cuDQoNCg0KRG8geW91IG1lYW4gdGhp
cyBvbmU/IA0KaHR0cHM6Ly90b29scy5pZXRmLm9yZy9odG1sL2RyYWZ0LWhheW5lcy1uZnN2NC1k
ZWxzdGlkLTAwDQoNCkNoZWVycw0KICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4
IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1t
ZXJzcGFjZS5jb20NCg0KDQo=
