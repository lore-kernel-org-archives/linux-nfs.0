Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC6DC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 01:58:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 61CE120672
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 01:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="rO4if3IH"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729721AbeLTB6z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 20:58:55 -0500
Received: from mail-eopbgr760098.outbound.protection.outlook.com ([40.107.76.98]:35189
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728835AbeLTB6z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 20:58:55 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hnZhgX6ICk5LLGdoIqSgHIHEhW5YU8COzhvNx9Bte14=;
 b=rO4if3IHEshvYUnZ5a+cbgyX3v7vFXKV6Qox7mA7Uz0ytnf72fkWLx7INMOQARImV5IA5DK3hmJBVPqI/3ihJIHMmsSlHjRbnEOxp82cKgy8QKgDSAE59+TW7+ANoCtynQkR+OzAHYa71NWM78aRGWpxL60KpVmBq+65WuyPvzg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2351.namprd13.prod.outlook.com (52.135.94.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.15; Thu, 20 Dec 2018 01:58:50 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1471.011; Thu, 20 Dec 2018
 01:58:49 +0000
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
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwCAAFXvAIAAC0AAgAD2awCAAO6fgIAABX+A
Date:   Thu, 20 Dec 2018 01:58:49 +0000
Message-ID: <76d71f3412b3104b917aa836eede3447db35bda0.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
         <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
         <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
         <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
         <eef084b9-4f1e-99e7-4d1a-a6e88b61d564@virtuozzo.com>
         <48844583b23fbbac600dfc86c49a7c71c5db36eb.camel@hammerspace.com>
         <d0b35e30-2eae-123e-19c6-fcd3cd93ab86@virtuozzo.com>
         <2459cc18-3c14-fb68-def6-eb09fc096613@virtuozzo.com>
In-Reply-To: <2459cc18-3c14-fb68-def6-eb09fc096613@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [12.37.220.163]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2351;6:/eta/WMNnRGUeLtKGkCIg8sw6C6cDduYil20oI7RhIW103kPYJs6kZqR3USf7YHwqDw+KvUaoS6SpDSlluw6GQzm7kubP/ue2F72wQ9UI0Ua6l6lu6IY8FyvlipSJ39AR0yTP9Zssfl3Lk8FeWyvpg2jg3+YKoF1sEAW/Y5aSo8UJKSDgKMcZh7rIUkOdYtqMQaekDfBxZkrr6NJqCdzkohEmNDJZMxQXTK0Lqcq9Jt0pPWwwh0DpUbSSBLKlwpnEXn8uAdrB3rpbu9UDXGz7BmVjHXheaONUfLLulyH/Ixyh/GioZ2fP9Xm5AvOkjRMHhBO2orTwXlXb2j2vAlOOOwo6GchEU35R+qLlJ96yDWm8o4OSel1qnVwVANsYhqZR+TO2fprBzszyMTzLA2gRJM2EpS0ibOUpOORfOARLXH2rjkEjt4ASBb+c1OA0WhTPQUkbqQXv/N6ySVW7DrNtw==;5:HtMmIR7XyutD3oNAFN+MFL63X3obc0nqb6jCpG3s5rgGbFvwBq6Zi+L7Yz0c1JU+ufyTyE+ckJSWBX5BkSQO2rkGGWmJoc/18EugLKPAz9Wn/FWWP95tgU2TkCW0hLfXIwl/5reU/CtOvEJdNwCsBO8C42eEawGHgRsKSymFQxo=;7:h56jlC7qZV5dNDyX39AEgOxzFpJ02XEB4NjEJQqSRLFktck1EIHtRVAuVFOt4dNI6ZW0ljCnqWy7BDzJUOZ38mD8FjnNjCAR1MNCIghMgtcnM/ZPstLcvXYaj2jdpIMnhpAEAAHUKaugqn2MrjCpcQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: e7fe0f56-d9f9-4beb-4385-08d6661eaf2f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2351;
x-ms-traffictypediagnostic: SN6PR13MB2351:
x-microsoft-antispam-prvs: <SN6PR13MB23514F55ECFE3AFB24FB990EB8BF0@SN6PR13MB2351.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(5005026)(6040522)(2401047)(8121501046)(93006095)(93001095)(3231475)(944501520)(52105112)(3002001)(10201501046)(149066)(150057)(6041310)(20161123562045)(20161123560045)(20161123564045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2351;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2351;
x-forefront-prvs: 0892FA9A88
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(396003)(376002)(39830400003)(136003)(189003)(199004)(97736004)(14454004)(93886005)(478600001)(6246003)(26005)(106356001)(105586002)(25786009)(476003)(2616005)(68736007)(186003)(7736002)(486006)(2501003)(99286004)(8676002)(76176011)(81156014)(81166006)(305945005)(4326008)(4001150100001)(229853002)(102836004)(6506007)(53546011)(6486002)(6436002)(446003)(118296001)(71190400001)(86362001)(11346002)(71200400001)(6512007)(66066001)(316002)(36756003)(8936002)(14444005)(256004)(575784001)(6306002)(54906003)(5660300001)(6116002)(3846002)(53936002)(2906002)(15974865002)(110136005)(413944005)(966005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2351;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: fnSJGdQMtP+B/NiAv0T51ipT/Wu/SNoZlbpZvaLc+dwLHKVmB3YoXibayvfJUZchUyQvHlqmMrU9d32gcgBJqAxjzHvRlanrkX0Uc/PYeqBKFn993sLFYddeaJIqH4zCYuVunV8G6zVaIeCZ5pxKeq0RKlzsvIJaRgHyNJeVQED/hoLD7OEX/jCcprwPtxFI9QLry8BX+eEiUGzu1rWUrp3Q2FNS9cqM5k/m2toEoYZR7eZNBtTX6agrVpNyJyVuosWhxtTf3QMbfqs/RF/LKUkRT11iBXR4U56+9dyBNOaN27ejIEEWJEmAwyCp8OkQ
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <8532A51C8D64CB4C86D73F8CC5032432@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e7fe0f56-d9f9-4beb-4385-08d6661eaf2f
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Dec 2018 01:58:49.2565
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2351
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTEyLTIwIGF0IDA0OjM5ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBEZWFyIFRyb25kLA0KPiBSZWQgSGF0IHNlY3VyaXR5IGJlbGlldmVzIHRoZSBwcm9ibGVtIGlz
IHF1aXRlIGltcG9ydGFudCBzZWN1cml0eQ0KPiBpc3N1ZToNCj4gaHR0cHM6Ly9hY2Nlc3MucmVk
aGF0LmNvbS9zZWN1cml0eS9jdmUvY3ZlLTIwMTgtMTY4ODQNCj4gDQo+IEZpeCBzaG91bGQgYmUg
YmFja3BvcnRlZCB0byBhZmZlY3RlZCBkaXN0cmlidXRpb25zLg0KPiANCj4gQ291bGQgeW91IHBs
ZWFzZSBhcHByb3ZlIG15IGZpcnN0IHBhdGNoIGFuZCBwdXNoIGl0IHRvIHN0YWJsZUAgPw0KPiBG
cm9tIG15IFBvViBpdCBpcyBjb3JyZWN0bHkgZml4ZXMgdGhlIHByb2JsZW0sIGl0IGJyZWFrcyBu
b3RoaW5nIGFuZA0KPiBlYXN5IGZvciBiYWNrcG9ydHMsDQo+IGxpZ2h0bHkgbW9kaWZpZWQgaXQg
Y2FuIGJlIGV2ZW4gbGl2ZS1wYXRjaGVkLg0KPiANCj4gT3RoZXIgcGF0Y2hlcyBpbmNsdWRpbmcg
c3dpdGNoIHRvIHVzaW5nIGVtcHR5IHJxc3QtPnJxX3hwcnQgY2FuIHdhaXQuDQo+IA0KDQpUaGF0
IHBhdGNoIGlzIG5vdCBhY2NlcHRhYmxlIGZvciB1cHN0cmVhbS4NCg0KDQoNCj4gVGhhbmsgeW91
LA0KPiAJVmFzaWx5IEF2ZXJpbg0KPiANCj4gT24gMTIvMTkvMTggMjoyNSBQTSwgVmFzaWx5IEF2
ZXJpbiB3cm90ZToNCj4gPiBPbiAxMi8xOC8xOCAxMTo0MyBQTSwgVHJvbmQgTXlrbGVidXN0IHdy
b3RlOg0KPiA+ID4gT24gVHVlLCAyMDE4LTEyLTE4IGF0IDIzOjAyICswMzAwLCBWYXNpbHkgQXZl
cmluIHdyb3RlOg0KPiA+ID4gPiBPbiAxMi8xOC8xOCA1OjU1IFBNLCBUcm9uZCBNeWtsZWJ1c3Qg
d3JvdGU6DQo+ID4gPiA+ID4gPiA+IEl0IHByb2JhYmx5IGFsc28gcmVxdWlyZXMgdXMgdG8gc3Rv
cmUgYSBwb2ludGVyIHRvIHN0cnVjdA0KPiA+ID4gPiA+ID4gPiBuZXQNCj4gPiA+ID4gPiA+ID4g
aW4NCj4gPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gPiA+IHN0cnVjdCBzdmNfcnFzdCBzbyB0
aGF0IG5mczRfY2FsbGJhY2tfY29tcG91bmQoKSBhbmQNCj4gPiA+ID4gPiA+ID4gc3ZjYXV0aF9n
c3NfYWNjZXB0KCkgY2FuIGZpbmQgaXQsIGJ1dCB0aGF0IHNob3VsZCBiZSBPSw0KPiA+ID4gPiA+
ID4gPiBzaW5jZQ0KPiA+ID4gPiA+ID4gPiB0aGUNCj4gPiA+ID4gPiA+ID4gdHJhbnNwb3J0IGFs
cmVhZHkgaGFzIHRoYXQgcmVmZXJlbmNlZC4NCj4gPiA+ID4gDQo+ID4gPiA+IE9rLCBJIGNhbiBm
aXggdGhlc2UgZnVuY3Rpb25zIGFuZCB0aGVpciBzdWItY2FsbHMuDQo+ID4gPiA+IEhvd2V2ZXIg
IHJxc3QtPnJxX3hwcnQgaXMgdXNlZCBpbiBvdGhlciBmdW5jdGlvbnMgdGhhdCBzZWVtcw0KPiA+
ID4gPiBjYW4gYmUNCj4gPiA+ID4gY2FsbGVkIGluc2lkZSBzdmNfcHJvY2Vzc19jb21tb24oKSAN
Cj4gPiA+ID4gLSBpbiB0cmFjZV9zdmNfcHJvY2VzcyhycXN0cCwgcHJvZ3AtPnBnX25hbWUpOw0K
PiA+ID4gPiAtIGluIHN2Y19yZXNlcnZlX2F1dGgocnFzdHAsIC4uLikgLT4gc3ZjX3Jlc2VydmUo
KQ0KPiA+ID4gPiAtIHN2Y19hdXRob3Jpc2UoKSAtPiBzdmNhdXRoX2dzc19yZWxlYXNlKCkNCj4g
PiA+ID4gDQo+ID4gPiA+IEl0IHNlZW1zIEkgc2hvdWxkIGZpeCB0aGVzZSBwbGFjZXMgdG9vLCBp
dCBpc24ndD8NCj4gPiA+ID4gY291bGQgeW91IHBsZWFzZSBhZHZpc2UgaG93IHRvIGZpeCBzdmNf
cmVzZXJ2ZSgpID8NCj4gPiA+IA0KPiA+ID4gV2UgZG9uJ3Qgd2FudCBzdmNfcmVzZXJ2ZSgpIHRv
IHJ1biBhdCBhbGwgZm9yIHRoZSBiYWNrIGNoYW5uZWwsDQo+ID4gPiBzbyBJDQo+ID4gPiBndWVz
cyB0aGF0IGEgdGVzdCBmb3IgcnFzdHAtPnJxX3hwcnQgIT0gTlVMTCBpcyBhcHByb3ByaWF0ZSB0
aGVyZQ0KPiA+ID4gdG9vLg0KPiA+ID4gDQo+ID4gPiBzdmNhdXRoX2dzc19yZWxlYXNlKCkgaXMg
anVzdCB1c2luZyBycXN0cC0+cnFfeHBydCB0byBmaW5kIHRoZQ0KPiA+ID4gbmV0DQo+ID4gPiBu
YW1lc3BhY2UsIHNvIGlmIHlvdSBhZGQgYSBwb2ludGVyIHJxc3RwLT5ycV9uZXQgdG8gZml4DQo+
ID4gPiBuZnM0X2NhbGxiYWNrX2NvbXBvdW5kLCB0aGVuIHRoYXQgd2lsbCBmaXggdGhlIGdzcyBj
YXNlIGFzIHdlbGwuDQo+ID4gPiANCj4gPiA+IEZvciB0cmFjZV9zdmNfcHJvY2VzcygpLCBtYXli
ZSBwdWxsIHJxc3QtPnJxX3hwcnQtPnhwdF9yZW1vdGVidWYNCj4gPiA+IG91dCBvZg0KPiA+ID4g
dGhlIHRyYWNlcG9pbnQgZGVmaW5pdGlvbiBpbiBpbmNsdWRlL3RyYWNlL2V2ZW50cy9zdW5ycGMu
aCBhbmQNCj4gPiA+IG1ha2UgaXQNCj4gPiA+IGEgdHJhY2Vwb2ludCBhcmd1bWVudCB0aGF0IGlz
IGFsbG93ZWQgdG8gYmUgTlVMTD8NCj4gPiANCj4gPiBUaGlzIG9uZSBzZWVtcyB3b3JrcywgY291
bGQgeW91IHBsZWFzZSBjaGVjayBpdCBiZWZvcmUgZm9ybWFsDQo+ID4gc3VibWl0ID8NCj4gPiAg
IE5GU3Y0IGNhbGxiYWNrLTE2NDQgIFswMDJdIC4uLi4gIDQ3MzEuMDY0MzcyOiBzdmNfcHJvY2Vz
czoNCj4gPiBhZGRyPShudWxsKSB4aWQ9MHgwYjA5MjRlMyBzZXJ2aWNlPU5GU3Y0IGNhbGxiYWNr
IHZlcnM9MSBwcm9jPTENCj4gPiANCj4gPiBGcmFua2x5IHNwZWFraW5nIEknbSBhZnJhaWQgdGhh
dCBJIG1pc3NlZCBzb21ldGhpbmcsDQo+ID4gcnFzdHAtPnJxX3hwcnQgaXMgd2lkZWx5IHVzZWQg
YW5kIG5vYm9keSBleHBlY3QgdGhhdCBpdCBjYW4gYmUNCj4gPiBOVUxMLg0KPiA+IA0KPiA+IEFu
ZCBldmVuIEkgbWlzc2VkIG5vdGhpbmcgLS0gIGl0J3MgcXVpdGUgdHJpY2t5IGFueXdheS4NCj4g
PiBGdXR1cmUgY2FobmdlcyBjYW4gYWRkIG5ldyBjYWxscyBvciBleGVjdXRlIG9sZCBub24tZW1w
dHkteHBydC0NCj4gPiBhd2FyZQ0KPiA+IGZ1bmN0aW9ucyBhbmQgdHJpZ2dlciBjcmFzaCBpbiBz
b21lIGV4b3RpYyBjb25maWd1cmF0aW9uLg0KPiA+IA0KPiA+IFRoYW5rIHlvdSwNCj4gPiAJVmFz
aWx5IEF2ZXJpbg0KPiA+IA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkNUTywgSGFtbWVyc3BhY2Ug
SW5jDQo0MzAwIEVsIENhbWlubyBSZWFsLCBTdWl0ZSAxMDUNCkxvcyBBbHRvcywgQ0EgOTQwMjIN
Cnd3dy5oYW1tZXIuc3BhY2UNCg0KDQo=
