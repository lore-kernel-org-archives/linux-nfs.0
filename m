Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28284C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 20:43:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC4342184C
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 20:43:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="vQjMgPjo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726721AbeLRUnP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 15:43:15 -0500
Received: from mail-eopbgr810108.outbound.protection.outlook.com ([40.107.81.108]:1920
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726446AbeLRUnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 15:43:14 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PVytTuFTLevODEq7NmPEfrq/yzfAO+uMq0EzFAf8KeY=;
 b=vQjMgPjolvDPG2QzPOMa88m84z6ru1L4XzLt+3ZEmVDvLyZq0ZbMonq+EX0au43gRb8HH8w7sRYF/V8mFEOlyo5ZIBNWyzTndDLGvZnFeqanF74/eKhO4HdBMdCEjZdw5ZwGhSlJNpURsf9FULyCiqIz49DrIJueF9tU8Ipot5A=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2352.namprd13.prod.outlook.com (52.135.94.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.15; Tue, 18 Dec 2018 20:43:05 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Tue, 18 Dec 2018
 20:43:05 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "vvs@virtuozzo.com" <vvs@virtuozzo.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Topic: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwCAAFXvAIAAC0AA
Date:   Tue, 18 Dec 2018 20:43:05 +0000
Message-ID: <48844583b23fbbac600dfc86c49a7c71c5db36eb.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
         <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
         <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
         <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
         <eef084b9-4f1e-99e7-4d1a-a6e88b61d564@virtuozzo.com>
In-Reply-To: <eef084b9-4f1e-99e7-4d1a-a6e88b61d564@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2352;6:2X1htD3bATk6r+EXOOKEyilDyd/btZLy24TopPgmGwCLdCyoDBkAb2U5t0OUA2E1Rqt+Q6VCfCR7Vs8JtKLSIfxZZvcRd2UxbXeBCYHgLgZsp4FW7j8JUSCLXRs5tsAfwHHsnEVJcEDqaXuOl6PcTr/eB+iv0OOJxhmNVpxhs3xrHBS5zYmBAKUka858C8Gey1bMcB43evW7U3/oyyFVOzSdjFyLYI4LKG5nFtD0K/GTS4jfjJ0ZLmbJ93AFgjKZR6wd04DEr/SZuCxlr50zQ4PKriySUwGEj0bWc4cyq+o9I5gAnA0m4/DNUTQHRWHUas9j9nAGe71QeQmzEzFByvW9jtl0so+W9ik5MKUZa8K/lRO+H8zHPWkR1RsROQJJi2CE8PL5osa/dOOzraluzjHvCrdvgIYCKGkIVGoyyItl6ihAtm/xTALWHu19xqY+RyeNMr5OxVoGsc21QweUmQ==;5:iBg3FOArh0M1LNizsp2aA5e1LDV1H+My0JwSwJIRX6pbPzWK+M6kbeJwSQNlni1EENdJkSAtQsRyaMj721P/vU/qXS8aqWosIFtp6N0EttLE0FDXEEtylprM+AmKdWMTElRoNZyWAKuzXTgk6IrMXnxy5UXsNExH5D2KAwQj+g4=;7:5rRkbUj3T3HnSnU22p3Z9vmBgDLOUTwklO6KyqfG3r+clX5t9u5dqzPbz5hFROJZbxA0wQj+AABH19WHKkfMOGsqEJWj5kAyY5mfhvZhoONPeyzH+WM9Hzu643uS+LtvB+VDVa89XyjLgiN/PhTxng==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7551e3be-c9a7-4c44-2915-08d665296942
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2352;
x-ms-traffictypediagnostic: SN6PR13MB2352:
x-microsoft-antispam-prvs: <SN6PR13MB2352648F77AA65C4ED46EA38B8BD0@SN6PR13MB2352.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(5005006)(8121501046)(3231475)(944501520)(52105112)(93006095)(93001095)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123562045)(20161123560045)(20161123564045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2352;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2352;
x-forefront-prvs: 08902E536D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(376002)(366004)(39830400003)(346002)(189003)(199004)(6486002)(476003)(6436002)(14454004)(229853002)(68736007)(8936002)(3846002)(110136005)(6116002)(54906003)(81166006)(93886005)(8676002)(2906002)(81156014)(305945005)(6246003)(99286004)(86362001)(53936002)(118296001)(7736002)(25786009)(4326008)(97736004)(4001150100001)(256004)(66066001)(102836004)(6512007)(186003)(26005)(105586002)(106356001)(76176011)(446003)(316002)(71190400001)(71200400001)(2616005)(5660300001)(2501003)(486006)(11346002)(478600001)(36756003)(6506007)(53546011);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2352;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: pot46CWRb+CVxXuqKcoAm7E9SB5akbVgLkwAgIlFAwLbKLWmiYL/VyjiCDUmAKXzEaToA+eYnnjXofkPtDpjR5LyWiFXyD+cWRNi2evR+lJmu+T/fmW43GqP74k944Sys8vm0lT+wmGAz9g+qex8GkzAHpbbEHnImWCe0uGiKvhCjMMl3GNqAqXvNSeH/9DS8mozMROUPzfHdZYVYySeDFatwJYPNmRNyfZugb8YiXJVf1Z58JL+LgV2wAjqxdFrAwZM/fEInybuQJm97qq4E6z9H9qA0Vg5McGQ0fWUot9OeSDtvvmBj6+qVlG5LgQC
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5C9D118885DA414BA2F6731F1E7749AA@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7551e3be-c9a7-4c44-2915-08d665296942
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Dec 2018 20:43:05.2521
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2352
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEyLTE4IGF0IDIzOjAyICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8xOC8xOCA1OjU1IFBNLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gPiA+IEl0
IHByb2JhYmx5IGFsc28gcmVxdWlyZXMgdXMgdG8gc3RvcmUgYSBwb2ludGVyIHRvIHN0cnVjdCBu
ZXQNCj4gPiA+ID4gaW4NCj4gPiA+ID4gdGhlDQo+ID4gPiA+IHN0cnVjdCBzdmNfcnFzdCBzbyB0
aGF0IG5mczRfY2FsbGJhY2tfY29tcG91bmQoKSBhbmQNCj4gPiA+ID4gc3ZjYXV0aF9nc3NfYWNj
ZXB0KCkgY2FuIGZpbmQgaXQsIGJ1dCB0aGF0IHNob3VsZCBiZSBPSyBzaW5jZQ0KPiA+ID4gPiB0
aGUNCj4gPiA+ID4gdHJhbnNwb3J0IGFscmVhZHkgaGFzIHRoYXQgcmVmZXJlbmNlZC4NCj4gDQo+
IE9rLCBJIGNhbiBmaXggdGhlc2UgZnVuY3Rpb25zIGFuZCB0aGVpciBzdWItY2FsbHMuDQo+IEhv
d2V2ZXIgIHJxc3QtPnJxX3hwcnQgaXMgdXNlZCBpbiBvdGhlciBmdW5jdGlvbnMgdGhhdCBzZWVt
cyBjYW4gYmUNCj4gY2FsbGVkIGluc2lkZSBzdmNfcHJvY2Vzc19jb21tb24oKSANCj4gLSBpbiB0
cmFjZV9zdmNfcHJvY2VzcyhycXN0cCwgcHJvZ3AtPnBnX25hbWUpOw0KPiAtIGluIHN2Y19yZXNl
cnZlX2F1dGgocnFzdHAsIC4uLikgLT4gc3ZjX3Jlc2VydmUoKQ0KPiAtIHN2Y19hdXRob3Jpc2Uo
KSAtPiBzdmNhdXRoX2dzc19yZWxlYXNlKCkNCj4gDQo+IEl0IHNlZW1zIEkgc2hvdWxkIGZpeCB0
aGVzZSBwbGFjZXMgdG9vLCBpdCBpc24ndD8NCj4gY291bGQgeW91IHBsZWFzZSBhZHZpc2UgaG93
IHRvIGZpeCBzdmNfcmVzZXJ2ZSgpID8NCg0KV2UgZG9uJ3Qgd2FudCBzdmNfcmVzZXJ2ZSgpIHRv
IHJ1biBhdCBhbGwgZm9yIHRoZSBiYWNrIGNoYW5uZWwsIHNvIEkNCmd1ZXNzIHRoYXQgYSB0ZXN0
IGZvciBycXN0cC0+cnFfeHBydCAhPSBOVUxMIGlzIGFwcHJvcHJpYXRlIHRoZXJlIHRvby4NCg0K
c3ZjYXV0aF9nc3NfcmVsZWFzZSgpIGlzIGp1c3QgdXNpbmcgcnFzdHAtPnJxX3hwcnQgdG8gZmlu
ZCB0aGUgbmV0DQpuYW1lc3BhY2UsIHNvIGlmIHlvdSBhZGQgYSBwb2ludGVyIHJxc3RwLT5ycV9u
ZXQgdG8gZml4DQpuZnM0X2NhbGxiYWNrX2NvbXBvdW5kLCB0aGVuIHRoYXQgd2lsbCBmaXggdGhl
IGdzcyBjYXNlIGFzIHdlbGwuDQoNCkZvciB0cmFjZV9zdmNfcHJvY2VzcygpLCBtYXliZSBwdWxs
IHJxc3QtPnJxX3hwcnQtPnhwdF9yZW1vdGVidWYgb3V0IG9mDQp0aGUgdHJhY2Vwb2ludCBkZWZp
bml0aW9uIGluIGluY2x1ZGUvdHJhY2UvZXZlbnRzL3N1bnJwYy5oIGFuZCBtYWtlIGl0DQphIHRy
YWNlcG9pbnQgYXJndW1lbnQgdGhhdCBpcyBhbGxvd2VkIHRvIGJlIE5VTEw/DQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
