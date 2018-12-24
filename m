Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECAA9C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 08:21:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 946EF2171F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 08:21:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="tfxlRCZM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726803AbeLXIVI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 03:21:08 -0500
Received: from mail-eopbgr820112.outbound.protection.outlook.com ([40.107.82.112]:54928
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726780AbeLXIVI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 03:21:08 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LwLi40T8ixqC2Y45es54gEGV2lyoZUW4n6hfKFE2o1Q=;
 b=tfxlRCZMdc6EpFSfLCiY6+WDI+a7w+nNLk0ctvaJqPE6QWalu+zmdzH4CcxP4kaDLxQZTUKT52QJyEJ+cmAVC1KfdgBKevmRUGsG19uexC6dlwEK3VKO4PiizeRwydxGXwG7dWOtzRXNOhO6otpv+WEYYj8gtnT/MhX0OWngsr4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2496.namprd13.prod.outlook.com (52.135.95.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1471.11; Mon, 24 Dec 2018 08:21:05 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1471.018; Mon, 24 Dec 2018
 08:21:04 +0000
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
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwCAA82tgIACq6GAgAH5nYCAAGMRgIAAA+8AgAAl6gA=
Date:   Mon, 24 Dec 2018 08:21:04 +0000
Message-ID: <6051cc19f72f9104806f628666ce54b31a5b184a.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
         <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
         <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
         <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
         <20181221010007.GA10196@fieldses.org>
         <9082b04a-8235-4b9d-39ae-1462fe350935@virtuozzo.com>
         <b80a9496d933064c0080ef277e79a07b69ae80b1.camel@hammerspace.com>
         <c57c4ebc-7be7-2f66-deda-bb8df6393099@virtuozzo.com>
         <83f3d959-1193-7222-f190-aee1de7eef0c@virtuozzo.com>
In-Reply-To: <83f3d959-1193-7222-f190-aee1de7eef0c@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [84.202.42.9]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2496;6:JI5K5SwWCAZAmRogqiL7n1k+4r4TTSDwJCIfQjdfhDojbRHNpN1WT8IGc7P9+ryeryrMaAPTrfoWGc6yeGWhaHY5ARQjNw1tYbc1BnpqCRFtr20YzWC0gpxtPtPxLR8ffm519tXy+VnZwwUTaAafAW6DpkBednYDt4+BPNsbsFSaEwHQr4CMn0bOWX8nK2WSMBWWob37QeypjUQMmtPux7fBw99ZwFqhV8ybmMAdWlJ0OsVhtdQawMjU6O+szfu7pOqvdI6JWFJjAeMB1blJyx+t47kcVIAm1HJYRKV/lpVCR2oUeG1nvevBIaZh+bVVtB4vC5SOHdCLS45/ai+44aAwV3BkUn2LZ5p/HFExHlPNvHjVb5zDL4VGCh8Bj9DinO/8GrxjUDdG+gZH86lM97vj5IZXgthISDOh2FGKhCimNbSLrogLXj/2fjUZTRomNEpJNtesGHlRwGbiqT/mrg==;5:MAhwUhaCMwEHEaLPdvgfN3NFqzAqCapw2PIHZfwBWPhnvj06DQBFRiJzudKcuvALwEOR62nr9Djz8wyuK9mF3Xl5mdbCpStGonzEcqo5jjIt+yXbFTBa1sU3tMFInMfXzLG69O9T50pTHmoZmwC6vzDG1pujPT8Inyqy5vy4LL0=;7:uFgWuvq8Lrn/Jtjxm6cxkPUUMFFyoHlNLWuK3vXIRy4D/IC0aiBM9OaYYcWXl65i7uQSuICedZ6S85IqB0z0oiA1TVo9ZZ6JG2abEydDM70RkFKI/FYnfu1U746SKPiFV2rEAHS6ADhVG8YED/P7gg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 6a79017e-bafb-49ed-f6b1-08d66978bf71
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2496;
x-ms-traffictypediagnostic: SN6PR13MB2496:
x-microsoft-antispam-prvs: <SN6PR13MB24969F9E1D347FFA42C2E33BB8BB0@SN6PR13MB2496.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(2401047)(8121501046)(3002001)(10201501046)(93006095)(93001095)(3231475)(944501520)(52105112)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123564045)(20161123562045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2496;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2496;
x-forefront-prvs: 0896BFCE6C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(39830400003)(366004)(396003)(346002)(199004)(189003)(118296001)(68736007)(186003)(316002)(8676002)(93886005)(26005)(97736004)(105586002)(2501003)(110136005)(305945005)(102836004)(6506007)(53546011)(76176011)(81166006)(66066001)(99286004)(6486002)(81156014)(106356001)(229853002)(54906003)(4001150100001)(256004)(6512007)(71200400001)(71190400001)(14454004)(2616005)(53936002)(25786009)(486006)(2906002)(11346002)(86362001)(5660300001)(446003)(476003)(6246003)(478600001)(36756003)(7736002)(3846002)(6116002)(6436002)(4326008)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2496;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: f39V6Vnwoiul4do6IOPK1NNw+d3suv4fHhgDh/AAo4M0zwH0IbfzsO/fBqnYIAEyJA2U1ysIhTBE70dXcfB1hD8SHuvH5LJxs5ak3QEp4DU2h66Viwil/825WnUYBdiE3WvKyF0cqxRaomHYr4v0xAShN6lqL+aUtF1NDbgOXdAEhhUgRo9rIHndFDANVa2ZJvvwFVpBgXHzyJ55v7K11VPk1tQvs3gUY/rv1Wl943KaO5QzZuR9FGf8GnxNANN4PiF8pkqcMFWRkn4CF0xXYtj3FuV19aDml1fSpcNrDthRhokdtZkdKNzFkXS9+0PQ
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <BA6C83698BD08E46A30E52076E70523F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6a79017e-bafb-49ed-f6b1-08d66978bf71
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Dec 2018 08:21:04.6291
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2496
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTI0IGF0IDA5OjA1ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8yNC8xOCA4OjUxIEFNLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0KPiA+IE9uIDEyLzI0
LzE4IDI6NTYgQU0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiA+IE9uIFNhdCwgMjAxOC0x
Mi0yMiBhdCAyMDo0NiArMDMwMCwgVmFzaWx5IEF2ZXJpbiB3cm90ZToNCj4gPiA+ID4gT24gMTIv
MjEvMTggNDowMCBBTSwgYmZpZWxkc0BmaWVsZHNlcy5vcmcgd3JvdGU6DQo+ID4gPiA+ID4gT24g
VHVlLCBEZWMgMTgsIDIwMTggYXQgMDI6NTU6MTVQTSArMDAwMCwgVHJvbmQgTXlrbGVidXN0DQo+
ID4gPiA+ID4gd3JvdGU6DQo+ID4gPiA+ID4gPiBOby4gV2UgZG9uJ3QgY2FyZSBhYm91dCB4cHRf
ZmxhZ3MgZm9yIHRoZSBiYWNrIGNoYW5uZWwNCj4gPiA+ID4gPiA+IGJlY2F1c2UNCj4gPiA+ID4g
PiA+IHRoZXJlIGlzDQo+ID4gPiA+ID4gPiBubyAic2VydmVyIHRyYW5zcG9ydCIuIFRoZSBhY3R1
YWwgdHJhbnNwb3J0IGlzIHN0b3JlZCBpbg0KPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gPiAn
c3RydWN0DQo+ID4gPiA+ID4gPiBycGNfcnFzdCcsIGFuZCBpcyB0aGUgc3RydWN0IHJwY194cHJ0
IGNvcnJlc3BvbmRpbmcgdG8gdGhlDQo+ID4gPiA+ID4gPiBjbGllbnQNCj4gPiA+ID4gPiA+IHNv
Y2tldCBvciBSRE1BIGNoYW5uZWwuDQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IElPVzogQWxs
IHdlIHJlYWxseSBuZWVkIGluIHN2Y19wcm9jZXNzX2NvbW1vbigpIGlzIHRvIGJlDQo+ID4gPiA+
ID4gPiBhYmxlIHRvDQo+ID4gPiA+ID4gPiBydW4NCj4gPiA+ID4gPiA+IHJxc3RwLT5ycV94cHJ0
LT54cHRfb3BzLT54cG9fcHJlcF9yZXBseV9oZHIoKSwgYW5kIHRoYXQgY2FuDQo+ID4gPiA+ID4g
PiBiZQ0KPiA+ID4gPiA+ID4gcGFzc2VkDQo+ID4gPiA+ID4gPiBlaXRoZXIgYXMgYSBwb2ludGVy
IHRvIHRoZSBzdHJ1Y3Qgc3ZjX3hwcnRfb3BzIGl0c2VsZi4NCj4gPiA+ID4gPiANCj4gPiA+ID4g
PiBGb3Igd2hhdCBpdCdzIHdvcnRoLCBJJ2QgcmF0aGVyIGdldCByaWQgb2YgdGhhdCBvcC0taXQn
cyBhbg0KPiA+ID4gPiA+IGF3ZnVsbHkNCj4gPiA+ID4gPiByb3VuZGFib3V0IHdheSBqdXN0IHRv
IGRvICJzdmNfcHV0bmwocmVzdiwgMCk7IiBpbiB0aGUgdGNwDQo+ID4gPiA+ID4gY2FzZS4NCj4g
PiA+ID4gDQo+ID4gPiA+IERvIHlvdSBtZWFuIHRoYXQgc3ZjX2NyZWF0ZV94cHJ0KHNlcnYsICJ0
Y3AtYmMiLCAuLi4pIHdhcyB1c2VkDQo+ID4gPiA+IE9OTFkNCj4gPiA+ID4gdG8gY2FsbCANCj4g
PiA+ID4gc3ZjX3RjcF9wcmVwX3JlcGx5X2hkcigpIGluIHN2Y19wcm9jZXNzX2NvbW1vbigpID8N
Cj4gPiA+ID4gQW5kIGFjY29yZGluZyBjYWxsIGZvciByZG1hLWJjIGRvZXMgbm90aGluZyB1c2Vm
dWwgYXQgYWxsPyANCj4gPiA+ID4gDQo+ID4gPiA+IEkndmUganVzdCB0cmllZCB0byByZW1vdmUg
c3ZjX2NyZWF0ZV94cHJ0KCkgZnJvbSB4c190Y3BfYmNfdXAoKQ0KPiA+ID4gPiBhbmQNCj4gPiA+
ID4ganVzdCANCj4gPiA+ID4gcHJvdmlkZSBwb2ludGVyIHRvIHN2Y190Y3BfcHJlcF9yZXBseV9o
ZHIoKQ0KPiA+ID4gPiBpbiAgc3ZjX3Byb2Nlc3NfY29tbW9uKCkgDQo+ID4gPiA+IHZpYSBwZXIt
bmV0bnMgc3VucnBjX25ldCAtLSBhbmQgc2VlbXMgaXQgd2FzIGVub3VnaCwgbXkNCj4gPiA+ID4g
dGVzdGNhc2UNCj4gPiA+ID4gd29ya2VkIGNvcnJlY3RseS4NCj4gPiA+IA0KPiA+ID4gSSBkb24n
dCBzZWUgaG93IHRoYXQgZnVuY3Rpb24gaXMgcmVsYXRlZCB0byBuZXQgbmFtZXNwYWNlcy4gQXMN
Cj4gPiA+IGZhciBhcyBJDQo+ID4gPiBjYW4gdGVsbCwgaXQgb25seSBzaWduYWxzIHdoZXRoZXIg
b3Igbm90IHRoZSB0eXBlIG9mIHRyYW5zcG9ydA0KPiA+ID4gdXNlcyB0aGUNCj4gPiA+IFRDUCBy
ZWNvcmQgbWFya2luZyBzY2hlbWUuDQo+ID4gDQo+ID4gV2UgbmVlZCB0byBrbm93IHdoaWNoIGtp
bmQgb2YgdHJhbnNwb3J0IGlzIHVzZWQgaW4gc3BlY2lmaWVkIG5ldA0KPiA+IG5hbWVzcGFjZSwN
Cj4gPiBmb3IgZXhhbXBsZSBpbml0X25zIGNhbiB1c2UgUkRNQSB0cmFuc3BvcnQgYW5kIG5ldG5z
ICJzZWNvbmQiIGNhbg0KPiA+IHVzZSANCj4gPiBUQ1AgdHJhbnNwb3J0IGF0IHRoZSBzYW1lIHRp
bWUuDQo+ID4gSWYgeW91IGRvIG5vdCBsaWtlIGFuIGlkZWEgdG8gdXNlIGZ1bmN0aW9uIHBvaW50
ZXIgYXMgYSBtYXJrIC0tIG9rDQo+ID4gSSBjYW4gc2F2ZSBvbmx5IHNvbWUgYm9vbGVhbiBmbGFn
IG9uIHN1bnJwY19uZXQsIGNoZWNrIGl0IGluDQo+ID4gc3ZjX3Byb2Nlc3NfY29tbW9uKCkgDQo+
ID4gYW5kIGlmIGl0IGlzIHNldCAtLSBjYWxsIHN2Y190Y3BfcHJlcF9yZXBseV9oZHIoKSBkaXJl
Y3RseS4NCg0KSSdtIG5vdCBhZ2FpbnN0IHRoZSBpZGVhIG9mIHVzaW5nIGEgZnVuY3Rpb24gcG9p
bnRlciwgYnV0IEknbSBzYXlpbmcNCnRoYXQgdGhlIHRyYW5zcG9ydCBpcyBub3QgdW5pcXVlIHBl
ci1uZXRucy4gSW5zdGVhZCwgdGhlIHRyYW5zcG9ydCBpcw0KdXN1YWxseSBwZXIgTkZTIG1vdW50
LCBidXQgeW91IGNhbiBhbHdheXMgcmV0cmlldmUgYSBwb2ludGVyIHRvIGl0DQpkaXJlY3RseSBp
biBiY19zdmNfcHJvY2VzcygpIGZyb20gcmVxLT5ycV94cHJ0LiANCg0KDQo+IG1vcmVvdmVyLCBJ
IGNhbiBkbyBub3QgY2hhbmdlIHN1bnJwY19uZXQgYXQgYWxsLA0KPiBJIGNhbiBjaGVjayBpbiBi
Y19zdmNfY29tbW9uKCkgd2hpY2ggdHJhbnNwb3J0IHVzZXMgaW5jb21pbmcgc3ZjX3JlcQ0KPiBh
bmQgcHJvdmlkZSBzdWNoIGZsYWcgYXMgbmV3IHBhcmFtZXRlciB0byBzdmNfcHJvY2Vzc19jb21t
b24oKS4NCg0KVGhlIGZ1bmN0aW9uIG9yIGZsYWcgdXNlZCBieSBiY19zdmNfY29tbW9uKCkgY291
bGQgYmUgYWRkZWQgdG8gcmVxLQ0KPnJxX3hwcnQtPm9wcyBhcyBhbm90aGVyICdiY18nIGZpZWxk
IGFuZCB0aGVuIHBhc3NlZCB0bw0Kc3ZjX3Byb2Nlc3NfY29tbW9uKCkgYXMgdGhlIHBhcmFtZXRl
ci4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
