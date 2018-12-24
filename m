Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20EF9C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 09:53:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B7BD021721
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 09:53:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="m8NCQorM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725268AbeLXJxP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 04:53:15 -0500
Received: from mail-eopbgr740130.outbound.protection.outlook.com ([40.107.74.130]:18720
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725298AbeLXJxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 04:53:15 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=iYQPPahA9Vb5fCj1o+RfVWaZCDwzzkWre3DknQURu1A=;
 b=m8NCQorMs6XwgnNjvR2DbUEBa8iQ9NirEq9+A67OVB8rhnF1XHiyB616wf7hwOmf4mDZ7N2KMuPBG1qE00hno8zmTq0rb+f3AxiN3WhDRuTAyMecwCj1MjdSMqpeWQSjN1f4jsm9T+L246EfACTTUK+uGJjWmX/1wqD7vQ5nokc=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2479.namprd13.prod.outlook.com (52.135.95.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1471.17; Mon, 24 Dec 2018 09:53:10 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1471.018; Mon, 24 Dec 2018
 09:53:10 +0000
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
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwCAA82tgIACq6GAgAH5nYCAAGMRgIAAA+8AgAAl6gCAAArKgIAADvOA
Date:   Mon, 24 Dec 2018 09:53:10 +0000
Message-ID: <57db94b668327d579d7e052fd8e9e8d007b586e9.camel@hammerspace.com>
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
         <6051cc19f72f9104806f628666ce54b31a5b184a.camel@hammerspace.com>
         <29ca1423-619d-ace5-53b3-d6567abf067b@virtuozzo.com>
In-Reply-To: <29ca1423-619d-ace5-53b3-d6567abf067b@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [84.202.42.9]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2479;6:bepbA31Gf96iLDWVNKQ3/ZIqbkl9o9lEzvLcrCn4owovhEBIJmip0JEUBt7x5ttSVjq15DQjPnNEXiPhy88TPsqeZ6jQO69ky2LRKUVXK5mTm9chLU0cNEwT/HwHAs47CBLcbuiNS/ZA0F+Ondy2n6BtmaV4ZaCUl5xDItSzj/f9ggJqzNRGHoKoPxIJz0ujPfX7CsBX5iiZWRPj5L69VsK09RmObLNG9dpo6mv0CTjIaMK54tu3Rau9NvdQ5zGSsesGVgyQx3HYLsce66bP3/r7QiJJgitywVFbyWGYWGheWbuqe2ztBGogvwr72I6Mh74++SRDMWpf4YFa8ida5WxQEAVqif2pzb5wPMeabTPyJfvt8rUsGnbeIZAkjIm0SoBZgHvxQOiKyXL8YEAl2R4riUNQn1Jzg2gvtUFz5NKR8yZ/uVkNTm/59Yc4B+m3gDCL0aXxPXJXc7jPMpQmUg==;5:isdIGrRhI/rAHlmDldSxhTZ7H5Yppr9vMp9iqL2h0dIRCYhADAghonPRTNk0rBeN+OT5/xaXJk6f5B7t7t4QmKWiCPs+4QrvNNLt3hzdhFs9p0aQKw60IEPzZSQVyEZHq10jFmvvfjPQxPDzRnBabVq3f6fnStb0OqfvR/9Bijo=;7:sQ4A0t0xkLOPLykYhP27I3vqlO50+NQMn2qHUZsn0/UsTavQImVhkFptXKK+CtFvKDZLNCq/VtgqbHejj0yzPR/dwpUQXY/lmhKkQPUNCUPntX9zxfQBiDTn/OgI38al73mCSlt7YW8spEuaRJCD/g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 223e4fb5-537a-4b24-b069-08d669859ced
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600098)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2479;
x-ms-traffictypediagnostic: SN6PR13MB2479:
x-microsoft-antispam-prvs: <SN6PR13MB24794B4C068BFF1787C567A3B8BB0@SN6PR13MB2479.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220043)(2401047)(8121501046)(3002001)(10201501046)(93006095)(93001095)(3231475)(944501520)(52105112)(6041310)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2479;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2479;
x-forefront-prvs: 0896BFCE6C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39830400003)(366004)(136003)(376002)(346002)(189003)(199004)(76176011)(68736007)(3846002)(14454004)(486006)(6246003)(106356001)(476003)(2906002)(8936002)(81166006)(102836004)(8676002)(81156014)(6116002)(105586002)(7736002)(305945005)(478600001)(6506007)(53546011)(93886005)(36756003)(6436002)(71190400001)(6512007)(71200400001)(256004)(110136005)(54906003)(316002)(186003)(6346003)(26005)(86362001)(2501003)(446003)(11346002)(118296001)(99286004)(2616005)(4001150100001)(4326008)(66066001)(25786009)(229853002)(53936002)(6486002)(97736004)(5660300001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2479;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 7Y7YDrzBmiPqjQ8T3dpm2QzzADu+qfQyDlpsUaMwDSKHslF+iU3JOv3gH37/grNzd9yCOhZhKFM8kP7XZK/UCpHTllT8VTnytBUy4qzGAfcbRlu3MzKUxcYuAEpnuJV9VRt+PzEdGzu2iphlJPsDMkbdjKXpwBP+lZjFhkcjpm3xkGJojZOCVnChq2hT/atgZHR34vVfBgzQtudnpSOV0u6f77dy7B1WmH4LkkPUGjNY4xbcSKS/4bEvic34Dod8A9dZ/+GyngFhHjOmQC1V7p61NofauIBz/rLClaWjXSCcnX3rk6vr8caIkMh0VQaX
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <28B1D20916CD304D873E2400F15F294B@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 223e4fb5-537a-4b24-b069-08d669859ced
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Dec 2018 09:53:10.2402
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2479
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTI0IGF0IDExOjU5ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8yNC8xOCAxMToyMSBBTSwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIE1v
biwgMjAxOC0xMi0yNCBhdCAwOTowNSArMDMwMCwgVmFzaWx5IEF2ZXJpbiB3cm90ZToNCj4gPiA+
IE9uIDEyLzI0LzE4IDg6NTEgQU0sIFZhc2lseSBBdmVyaW4gd3JvdGU6DQo+ID4gPiA+IE9uIDEy
LzI0LzE4IDI6NTYgQU0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiA+ID4gPiBPbiBTYXQs
IDIwMTgtMTItMjIgYXQgMjA6NDYgKzAzMDAsIFZhc2lseSBBdmVyaW4gd3JvdGU6DQo+ID4gPiA+
ID4gPiBPbiAxMi8yMS8xOCA0OjAwIEFNLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3cm90ZToNCj4g
PiA+ID4gPiA+ID4gT24gVHVlLCBEZWMgMTgsIDIwMTggYXQgMDI6NTU6MTVQTSArMDAwMCwgVHJv
bmQgTXlrbGVidXN0DQo+ID4gPiA+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+ID4gPiA+IE5vLiBX
ZSBkb24ndCBjYXJlIGFib3V0IHhwdF9mbGFncyBmb3IgdGhlIGJhY2sgY2hhbm5lbA0KPiA+ID4g
PiA+ID4gPiA+IGJlY2F1c2UNCj4gPiA+ID4gPiA+ID4gPiB0aGVyZSBpcw0KPiA+ID4gPiA+ID4g
PiA+IG5vICJzZXJ2ZXIgdHJhbnNwb3J0Ii4gVGhlIGFjdHVhbCB0cmFuc3BvcnQgaXMgc3RvcmVk
DQo+ID4gPiA+ID4gPiA+ID4gaW4NCj4gPiA+ID4gPiA+ID4gPiB0aGUNCj4gPiA+ID4gPiA+ID4g
PiAnc3RydWN0DQo+ID4gPiA+ID4gPiA+ID4gcnBjX3Jxc3QnLCBhbmQgaXMgdGhlIHN0cnVjdCBy
cGNfeHBydCBjb3JyZXNwb25kaW5nIHRvDQo+ID4gPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4g
PiA+ID4gY2xpZW50DQo+ID4gPiA+ID4gPiA+ID4gc29ja2V0IG9yIFJETUEgY2hhbm5lbC4NCj4g
PiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gPiBJT1c6IEFsbCB3ZSByZWFsbHkgbmVlZCBp
biBzdmNfcHJvY2Vzc19jb21tb24oKSBpcyB0bw0KPiA+ID4gPiA+ID4gPiA+IGJlDQo+ID4gPiA+
ID4gPiA+ID4gYWJsZSB0bw0KPiA+ID4gPiA+ID4gPiA+IHJ1bg0KPiA+ID4gPiA+ID4gPiA+IHJx
c3RwLT5ycV94cHJ0LT54cHRfb3BzLT54cG9fcHJlcF9yZXBseV9oZHIoKSwgYW5kIHRoYXQNCj4g
PiA+ID4gPiA+ID4gPiBjYW4NCj4gPiA+ID4gPiA+ID4gPiBiZQ0KPiA+ID4gPiA+ID4gPiA+IHBh
c3NlZA0KPiA+ID4gPiA+ID4gPiA+IGVpdGhlciBhcyBhIHBvaW50ZXIgdG8gdGhlIHN0cnVjdCBz
dmNfeHBydF9vcHMgaXRzZWxmLg0KPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+ID4gRm9yIHdo
YXQgaXQncyB3b3J0aCwgSSdkIHJhdGhlciBnZXQgcmlkIG9mIHRoYXQgb3AtLWl0J3MNCj4gPiA+
ID4gPiA+ID4gYW4NCj4gPiA+ID4gPiA+ID4gYXdmdWxseQ0KPiA+ID4gPiA+ID4gPiByb3VuZGFi
b3V0IHdheSBqdXN0IHRvIGRvICJzdmNfcHV0bmwocmVzdiwgMCk7IiBpbiB0aGUNCj4gPiA+ID4g
PiA+ID4gdGNwDQo+ID4gPiA+ID4gPiA+IGNhc2UuDQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+
IERvIHlvdSBtZWFuIHRoYXQgc3ZjX2NyZWF0ZV94cHJ0KHNlcnYsICJ0Y3AtYmMiLCAuLi4pIHdh
cw0KPiA+ID4gPiA+ID4gdXNlZA0KPiA+ID4gPiA+ID4gT05MWQ0KPiA+ID4gPiA+ID4gdG8gY2Fs
bCANCj4gPiA+ID4gPiA+IHN2Y190Y3BfcHJlcF9yZXBseV9oZHIoKSBpbiBzdmNfcHJvY2Vzc19j
b21tb24oKSA/DQo+ID4gPiA+ID4gPiBBbmQgYWNjb3JkaW5nIGNhbGwgZm9yIHJkbWEtYmMgZG9l
cyBub3RoaW5nIHVzZWZ1bCBhdCBhbGw/IA0KPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiBJJ3Zl
IGp1c3QgdHJpZWQgdG8gcmVtb3ZlIHN2Y19jcmVhdGVfeHBydCgpIGZyb20NCj4gPiA+ID4gPiA+
IHhzX3RjcF9iY191cCgpDQo+ID4gPiA+ID4gPiBhbmQNCj4gPiA+ID4gPiA+IGp1c3QgDQo+ID4g
PiA+ID4gPiBwcm92aWRlIHBvaW50ZXIgdG8gc3ZjX3RjcF9wcmVwX3JlcGx5X2hkcigpDQo+ID4g
PiA+ID4gPiBpbiAgc3ZjX3Byb2Nlc3NfY29tbW9uKCkgDQo+ID4gPiA+ID4gPiB2aWEgcGVyLW5l
dG5zIHN1bnJwY19uZXQgLS0gYW5kIHNlZW1zIGl0IHdhcyBlbm91Z2gsIG15DQo+ID4gPiA+ID4g
PiB0ZXN0Y2FzZQ0KPiA+ID4gPiA+ID4gd29ya2VkIGNvcnJlY3RseS4NCj4gPiA+ID4gPiANCj4g
PiA+ID4gPiBJIGRvbid0IHNlZSBob3cgdGhhdCBmdW5jdGlvbiBpcyByZWxhdGVkIHRvIG5ldCBu
YW1lc3BhY2VzLg0KPiA+ID4gPiA+IEFzDQo+ID4gPiA+ID4gZmFyIGFzIEkNCj4gPiA+ID4gPiBj
YW4gdGVsbCwgaXQgb25seSBzaWduYWxzIHdoZXRoZXIgb3Igbm90IHRoZSB0eXBlIG9mDQo+ID4g
PiA+ID4gdHJhbnNwb3J0DQo+ID4gPiA+ID4gdXNlcyB0aGUNCj4gPiA+ID4gPiBUQ1AgcmVjb3Jk
IG1hcmtpbmcgc2NoZW1lLg0KPiA+ID4gPiANCj4gPiA+ID4gV2UgbmVlZCB0byBrbm93IHdoaWNo
IGtpbmQgb2YgdHJhbnNwb3J0IGlzIHVzZWQgaW4gc3BlY2lmaWVkDQo+ID4gPiA+IG5ldA0KPiA+
ID4gPiBuYW1lc3BhY2UsDQo+ID4gPiA+IGZvciBleGFtcGxlIGluaXRfbnMgY2FuIHVzZSBSRE1B
IHRyYW5zcG9ydCBhbmQgbmV0bnMgInNlY29uZCINCj4gPiA+ID4gY2FuDQo+ID4gPiA+IHVzZSAN
Cj4gPiA+ID4gVENQIHRyYW5zcG9ydCBhdCB0aGUgc2FtZSB0aW1lLg0KPiA+ID4gPiBJZiB5b3Ug
ZG8gbm90IGxpa2UgYW4gaWRlYSB0byB1c2UgZnVuY3Rpb24gcG9pbnRlciBhcyBhIG1hcmsgLS0N
Cj4gPiA+ID4gb2sNCj4gPiA+ID4gSSBjYW4gc2F2ZSBvbmx5IHNvbWUgYm9vbGVhbiBmbGFnIG9u
IHN1bnJwY19uZXQsIGNoZWNrIGl0IGluDQo+ID4gPiA+IHN2Y19wcm9jZXNzX2NvbW1vbigpIA0K
PiA+ID4gPiBhbmQgaWYgaXQgaXMgc2V0IC0tIGNhbGwgc3ZjX3RjcF9wcmVwX3JlcGx5X2hkcigp
IGRpcmVjdGx5Lg0KPiA+IA0KPiA+IEknbSBub3QgYWdhaW5zdCB0aGUgaWRlYSBvZiB1c2luZyBh
IGZ1bmN0aW9uIHBvaW50ZXIsIGJ1dCBJJ20NCj4gPiBzYXlpbmcNCj4gPiB0aGF0IHRoZSB0cmFu
c3BvcnQgaXMgbm90IHVuaXF1ZSBwZXItbmV0bnMuIEluc3RlYWQsIHRoZSB0cmFuc3BvcnQNCj4g
PiBpcw0KPiA+IHVzdWFsbHkgcGVyIE5GUyBtb3VudCwgYnV0IHlvdSBjYW4gYWx3YXlzIHJldHJp
ZXZlIGEgcG9pbnRlciB0byBpdA0KPiA+IGRpcmVjdGx5IGluIGJjX3N2Y19wcm9jZXNzKCkgZnJv
bSByZXEtPnJxX3hwcnQuIA0KPiANCj4gWW91J3JlIHJpZ2h0LCBJIHdhcyB3cm9uZyBiZWNhdXNl
IEkgd2FzIGZvY3VzZWQgb24gY3JlYXRpb24gb2YgZmFrZQ0KPiB0cmFuc3BvcnQgc3ZjX3hwcnQu
DQo+IFllcywgd2UgY2Fubm90IHVzZSBwZXItbmV0bnMgcG9pbnRlciBoZXJlLg0KPiANCj4gPiA+
IG1vcmVvdmVyLCBJIGNhbiBkbyBub3QgY2hhbmdlIHN1bnJwY19uZXQgYXQgYWxsLA0KPiA+ID4g
SSBjYW4gY2hlY2sgaW4gYmNfc3ZjX2NvbW1vbigpIHdoaWNoIHRyYW5zcG9ydCB1c2VzIGluY29t
aW5nDQo+ID4gPiBzdmNfcmVxDQo+ID4gPiBhbmQgcHJvdmlkZSBzdWNoIGZsYWcgYXMgbmV3IHBh
cmFtZXRlciB0byBzdmNfcHJvY2Vzc19jb21tb24oKS4NCj4gPiANCj4gPiBUaGUgZnVuY3Rpb24g
b3IgZmxhZyB1c2VkIGJ5IGJjX3N2Y19jb21tb24oKSBjb3VsZCBiZSBhZGRlZCB0byByZXEtDQo+
ID4gPiBycV94cHJ0LT5vcHMgYXMgYW5vdGhlciAnYmNfJyBmaWVsZCBhbmQgdGhlbiBwYXNzZWQg
dG8NCj4gPiBzdmNfcHJvY2Vzc19jb21tb24oKSBhcyB0aGUgcGFyYW1ldGVyLg0KPiANCj4gQ2Fu
IEkganVzdCBjaGVjayBycXN0cC0+cnFfcHJvdCA/IEl0IGlzIGluaGVyaXRlZCBmcm9tIGluY29t
aW5nDQo+IHN2Y19yZXEsDQo+IGFuZCBpdCBzZWVtcyBpdCBlbm91Z2ggdG8gY2hlY2sgaXRzIHBy
b3BvLCBpdCBpc24ndD8gDQo+IA0KPiBzdmNfcHJvY2Vzc19jb21tb24oKQ0KPiAuLi4NCj4gICAg
ICAgICAvKiBTZXR1cCByZXBseSBoZWFkZXIgKi8NCj4gICAgICAgICBpZiAocnFzdHAtPnJxX3By
b3QgPT0gSVBQUk9UT19UQ1ApDQo+ICAgICAgICAgICAgICAgICBzdmNfdGNwX3ByZXBfcmVwbHlf
aGRyKHJxc3RwKTsNCg0KWWVzLiBJbiB0aGVzZSBkYXlzIHdpdGggcmV0cG9saW5lIHNsb3dpbmcg
ZG93biBhbGwgaW5kaXJlY3QgZnVuY3Rpb24NCmNhbGxzLCB0aGVuIHRoZSBhYm92ZSBpcyBwcm9i
YWJseSB0aGUgYmV0dGVyIHNvbHV0aW9uLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
