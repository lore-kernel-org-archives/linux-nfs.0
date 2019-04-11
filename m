Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46119C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:32:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 085672084D
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:32:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="QT74vu1q"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726585AbfDKRcb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 13:32:31 -0400
Received: from mail-eopbgr810124.outbound.protection.outlook.com ([40.107.81.124]:5493
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726538AbfDKRca (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Apr 2019 13:32:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=X4pJbYWVRmo03r53gltB3eLseVdwvN35phi20IaIneo=;
 b=QT74vu1q7RNIeucNMGLqoD/DzYHI81w+TAMAKkyr2TF0uUjO8mt2OTT6qE0VB5xUJtQ3wo0hPBCjlWmBh75CqiAuVnk2+retEkxVRwhvScT15xAl52ZBJoIN8ygrA2rNBMuNry/FlkJ8PVPo5CcRDqMnZn6UHBs7vDXoLfJ0btk=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2477.namprd13.prod.outlook.com (52.135.95.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.9; Thu, 11 Apr 2019 17:32:25 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Thu, 11 Apr 2019
 17:32:25 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
Thread-Topic: [PATCH 1/1] NFSv4.1 fix incorrect return value in
 copy_file_range
Thread-Index: AQHU8IOGkX0JgFjPkkOfyqt8wY1bPqY3K0gAgAABlICAAAPcAIAAAsIAgAAEiQA=
Date:   Thu, 11 Apr 2019 17:32:24 +0000
Message-ID: <c75a8f3bddd431030fd215be27ee3acd2a5fb102.camel@hammerspace.com>
References: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
         <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com>
         <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com>
         <d7146ead1f35af97a8f107326904f13d4031b8fc.camel@hammerspace.com>
         <CAN-5tyE_QvwirK70sf8=_M+rcn1MVFi33s8gn1RODzB4sJx_Og@mail.gmail.com>
In-Reply-To: <CAN-5tyE_QvwirK70sf8=_M+rcn1MVFi33s8gn1RODzB4sJx_Og@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 29d7a7a0-5364-4e7b-b2da-08d6bea3a961
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2477;
x-ms-traffictypediagnostic: SN6PR13MB2477:
x-microsoft-antispam-prvs: <SN6PR13MB24773FCF3AC19FB72A020A30B82F0@SN6PR13MB2477.namprd13.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(396003)(346002)(39830400003)(136003)(189003)(199004)(54906003)(2906002)(102836004)(5660300002)(486006)(6246003)(118296001)(53936002)(53546011)(93886005)(316002)(6512007)(6116002)(3846002)(8936002)(26005)(81156014)(6916009)(446003)(11346002)(2616005)(86362001)(476003)(68736007)(71200400001)(186003)(4326008)(71190400001)(81166006)(76176011)(6506007)(478600001)(6436002)(14444005)(2501003)(36756003)(25786009)(8676002)(106356001)(105586002)(6486002)(256004)(66066001)(14454004)(5640700003)(2351001)(1361003)(99286004)(229853002)(7736002)(97736004)(305945005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2477;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: UJkqFiV+Bh+9UncIXjLw52V8O0yLUWyvBwSFPSe7ax6TRew0pemJI2CrrkEfGj1Bh+IjHae6nm8fNUDgO3cdc1+xHt/xgGlHhHjAyJUIQ6Vh3JHD1wGzGhfBUgMefmAxdBS+9WOEs+v2zMjdU4CZhJQGn5+nlDua1P6PBe1CWYWLNdFwFgFSg2wviGwrof0WPQabXnGVPSsW1352mvYwL96bBifhMr/JnGJyYAyvHSZQl3JNmqgPwMpjn9Qa7OkI0U7kus25uBZl9ldfuFBK3rXMv/bEal17nOzoZrJ1TlH7evabIYnieHv94lGFYUiaZMFoebOfU+9g3JLcEskTRGCVIa+8y08Pge9h6fWb/tWCiB8pvi0uo40l9xH5UoUXp5AGoX3xFyd7FdiKVs/SsKo69gBJuGXqBvQpLY1QXvg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <48E436F068DA2B40A9DA25215D3CF896@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 29d7a7a0-5364-4e7b-b2da-08d6bea3a961
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 17:32:24.8821
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2477
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTExIGF0IDEzOjE2IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gVGh1LCBBcHIgMTEsIDIwMTkgYXQgMTowNiBQTSBUcm9uZCBNeWtsZWJ1c3QgPA0K
PiB0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gT24gVGh1LCAyMDE5LTA0LTEx
IGF0IDEyOjUyIC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+IE9uIFRodSwg
QXByIDExLCAyMDE5IGF0IDEyOjQ2IFBNIFRyb25kIE15a2xlYnVzdA0KPiA+ID4gPHRyb25kbXlA
aGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+ID4gT24gVGh1LCAyMDE5LTA0LTExIGF0IDEy
OjI3IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+ID4gPiBGcm9tOiBPbGdh
IEtvcm5pZXZza2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBX
aGVuIFZGUyBjYWxscyBjb3B5X2ZpbGVfcmFuZ2Ugb24gYSA0LjAgbW91bnQgKGFuZCB3aGVuIGlu
DQo+ID4gPiA+ID4gYW5kDQo+ID4gPiA+ID4gb3V0DQo+ID4gPiA+ID4gZmlsZSBpcyB0aGUgc2Ft
ZSksIHdlIG5lZWQgdG8gcmV0dXJuIEVOT1RTVVBQIGluc3RlYWQgb2YNCj4gPiA+ID4gPiBFSU5W
QUwuDQo+ID4gPiA+ID4gU2luY2Ugbm8gQ09QWSBvcGVyYXRpb24gaXMgZGVmaW5lZCBpbiA0LjAs
IHRoZW4gbGlrZSAzLjAsIGl0DQo+ID4gPiA+ID4gc2hvdWxkDQo+ID4gPiA+ID4gZmFsbGJhY2sg
dG8gZG9pbmcgZG9fc3BsaWNlX2RpcmVjdCgpLg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IE90aGVy
d2lzZSB4ZnN0ZXN0IGdlbmVyaWMvMDc1LDA5MSwxMTIsMjYzIGZhaWwuDQo+ID4gPiA+ID4gDQo+
ID4gPiA+ID4gU2lnbmVkLW9mZi1ieTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5j
b20+DQo+ID4gPiA+ID4gLS0tDQo+ID4gPiA+ID4gIGZzL25mcy9uZnM0ZmlsZS5jIHwgNiArKysr
KysNCj4gPiA+ID4gPiAgMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKQ0KPiA+ID4gPiA+
IA0KPiA+ID4gPiA+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNGZpbGUuYyBiL2ZzL25mcy9uZnM0
ZmlsZS5jDQo+ID4gPiA+ID4gaW5kZXggNDViMjMyMi4uOWEyMjJiMCAxMDA2NDQNCj4gPiA+ID4g
PiAtLS0gYS9mcy9uZnMvbmZzNGZpbGUuYw0KPiA+ID4gPiA+ICsrKyBiL2ZzL25mcy9uZnM0Zmls
ZS5jDQo+ID4gPiA+ID4gQEAgLTEzMyw2ICsxMzMsMTIgQEAgc3RhdGljIHNzaXplX3QNCj4gPiA+
ID4gPiBuZnM0X2NvcHlfZmlsZV9yYW5nZShzdHJ1Y3QNCj4gPiA+ID4gPiBmaWxlDQo+ID4gPiA+
ID4gKmZpbGVfaW4sIGxvZmZfdCBwb3NfaW4sDQo+ID4gPiA+ID4gICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgIHN0cnVjdCBmaWxlICpmaWxlX291dCwNCj4gPiA+ID4gPiBsb2ZmX3QN
Cj4gPiA+ID4gPiBwb3Nfb3V0LA0KPiA+ID4gPiA+ICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICBzaXplX3QgY291bnQsIHVuc2lnbmVkIGludA0KPiA+ID4gPiA+IGZsYWdzKQ0KPiA+
ID4gPiA+ICB7DQo+ID4gPiA+ID4gKyAgICAgc3RydWN0IG5mc19zZXJ2ZXIgKnNlcnZlciA9DQo+
ID4gPiA+ID4gTkZTX1NFUlZFUihmaWxlX2lub2RlKGZpbGVfaW4pOw0KPiA+ID4gPiA+ICsgICAg
IHN0cnVjdCBuZnNfY2xpZW50ICpjbGllbnQgPSBzZXJ2ZXItPm5mc19jbGllbnQ7DQo+ID4gPiA+
ID4gKw0KPiA+ID4gPiA+ICsgICAgIGlmIChjbGllbnQtPmNsX21pbm9ydmVyc2lvbiA8IDEpDQo+
ID4gPiA+ID4gKyAgICAgICAgICAgICByZXR1cm4gLUVPUE5PVFNVUFA7DQo+ID4gPiA+ID4gKw0K
PiA+ID4gPiA+ICAgICAgIGlmIChmaWxlX2lub2RlKGZpbGVfaW4pID09IGZpbGVfaW5vZGUoZmls
ZV9vdXQpKQ0KPiA+ID4gPiA+ICAgICAgICAgICAgICAgcmV0dXJuIC1FSU5WQUw7DQo+ID4gPiA+
ID4gICAgICAgcmV0dXJuIG5mczQyX3Byb2NfY29weShmaWxlX2luLCBwb3NfaW4sIGZpbGVfb3V0
LA0KPiA+ID4gPiA+IHBvc19vdXQsDQo+ID4gPiA+ID4gY291bnQpOw0KPiA+ID4gPiANCj4gPiA+
ID4gTGV0J3MgcGxlYXNlIGp1c3QgbW92ZSB0aGUgdGVzdCBmb3IgTkZTX0NBUF9DT1BZIGZyb20N
Cj4gPiA+ID4gbmZzNDJfcHJvY19jb3B5KCkNCj4gPiA+ID4gaW50byB0aGUgYWJvdmUgZnVuY3Rp
b24uDQo+ID4gPiANCj4gPiA+IEJ1dCB0aGUgcmV0dXJuIG9yZGVyIG9mIGVycm9ycyBoZXJlIGZv
ciBkaWZmZXJlbnQgY29uZGl0aW9ucw0KPiA+ID4gbWF0dGVyLg0KPiA+ID4gRm9yIDQuMSsgbW91
bnRzLCBpZiBpbiA9PSBvdXQsIHdlJ2QgZXhwZWN0IEVJTlZBTCBldmVuIGlmIHNlcnZlcg0KPiA+
ID4gaXNuJ3QNCj4gPiA+IGNhcGFibGUuIEJ1dCB3ZSBjYW4ndCBqdXN0IHB1dCB0aGUgaW4gPT0g
b3V0IGZpcnN0IGJlY2F1c2UgZm9yDQo+ID4gPiA0LjAsDQo+ID4gPiB3ZQ0KPiA+ID4gbmVlZCB0
byBhbHdheXMgcmV0dXJuIEVPUE5PVFNVUFAuDQo+ID4gPiANCj4gPiA+ID4gQlRXOiBXaHkgZG8g
d2UgcmV0dXJuIC1FSU5WQUwgaW4gdGhlIGZpbGVfaW4gPT0gZmlsZV9vdXQgY2FzZT8NCj4gPiA+
ID4gSXMNCj4gPiA+ID4gdGhlcmUNCj4gPiA+ID4gYW55IHJlYXNvbiB3aHkgd2Ugc2hvdWxkbid0
IGp1c3QgcmV0dXJuIEVPUE5PVFNVUFAgdGhlcmUgdG9vIGluDQo+ID4gPiA+IG9yZGVyDQo+ID4g
PiA+IHRvIGxldCBzcGxpY2UoKSBmdWxmaWwgdGhlIG9wZXJhdGlvbj8NCj4gPiA+IA0KPiA+ID4g
WWVzOiBpbiA9PSBvdXQgLT4gRUlOVkFMIGlzIGEgc3BlYyByZXF1aXJlbWVudC4NCj4gPiA+IA0K
PiA+IA0KPiA+IFJldHVybmluZyBORlM0RVJSX0lOVkFMIHdoZW4gdGhlIGZpbGVzIGFyZSBpZGVu
dGljYWwgaXMgYQ0KPiA+IHJlcXVpcmVtZW50DQo+ID4gZm9yIHRoZSBORlN2NC4yIHNlcnZlci4N
Cj4gPiANCj4gPiBPbiB0aGUgb3RoZXIgaGFuZCwgdGhlIHJlcXVpcmVtZW50IGZvciB0aGUgTGlu
dXggZmlsZSBjb3B5DQo+ID4gb3BlcmF0aW9uIGlzDQo+ID4gdGhhdCBpdCBzaG91bGQgc3VjY2Vl
ZCBpbiB0aGlzIHNpdHVhdGlvbi4gU28gYXMgZmFyIGFzIEkgY2FuIHRlbGwsDQo+ID4gd2UNCj4g
PiB3aWxsIGNvbnRpbnVlIHRvIGZhaWwgeGZzdGVzdHMgdW50aWwgd2Ugd29yayBhcm91bmQgdGhl
IGRpc2NyZXBhbmN5DQo+ID4gd2l0aCB0aGUgcHJvdG9jb2wgcmVxdWlyZW1lbnQgaGVyZS4gVGhl
IHNpbXBsZXN0IHdheSB0byBkbyBzbyB3b3VsZA0KPiA+IGFwcGVhciB0byBiZSB0byByZXR1cm4g
RU9QTk9UU1VQUC4NCj4gDQo+IE9rIHNvIHlvdSBhcmUgYXJndWluZyB0aGF0IHRob3NlIHhmc3Rl
c3QncyBmb3IgY29weV9maWxlX3JhbmdlKCkgb24NCj4gdGhlIHNhbWUgZmlsZSBzaG91bGRuJ3Qg
ZmFpbCBmb3IgYW55IG9mIHRoZSBORlMgdmVyc2lvbiByZWdhcmRsZXNzIG9mDQo+IHRoZSBORlN2
NC4yIHJlcSBmb3Igbm90IGRvaW5nIGEgY29weSBvbiB0aGUgc2FtZSBmaWxlLiBMZXQgbWUgc2Vu
ZA0KPiBvdXQNCj4gYW5vdGhlciB2ZXJzaW9uIHRoYXQgYWRkcmVzc2VzIGJvdGggdGhlbi4gSSB3
aWxsIGNoYW5nZSB0aGUgImluID09DQo+IG91dCIgdG8gcmV0dXJuIEVPUE5PVFNVUFAgd2hpY2gg
d2lsbCBhbGxvdyB0aGUgZmFsbGJhY2sgZm9yIDQuMisgYW5kDQo+IGNoZWNrIGZvciB0aGUgc2Vy
dmVyIGNhcGFiaWxpdHkgYmVmb3JlIHRoYXQuDQoNCg0KUmlnaHQuIFRoZSBwb2ludCBvbiB0aGUg
Y2xpZW50IHNob3VsZCBiZSB0byBmdWxmaWwgdGhlIHJlcXVpcmVtZW50cyBvZg0KdGhlIGNvcHlf
ZmlsZV9yYW5nZSgpIHNwZWMsIHNvIHRoYXQgYXBwbGljYXRpb25zIGNhbiBjb2RlIHRvIHRoYXQg
c3BlYw0Kd2l0aG91dCBuZWVkaW5nIHRvIGtub3cgYW55ICBkZXRhaWxzIG9mIGhvdyB0aGUgTkZT
IGNsaWVudCB0cmllcyB0bw0KaW1wbGVtZW50IGl0LiBXaGVuIHRoZXJlIGlzIGEgZnVuY3Rpb25h
bGl0eSBnYXAgd2l0aCB0aGUgTkZTIHNwZWMgZm9yDQpDT1BZIChzdWNoIGFzIGlzIHRoZSBjYXNl
IGhlcmUpIHRoZW4gd2Ugc2hvdWxkIGZhbGwgYmFjayB0byBlbXVsYXRpb24NCm9mIHRoZSBjb3B5
X2ZpbGVfcmFuZ2UoKSBzcGVjLg0KDQoNCi4uLmFuZCBhZ2FpbiwgSSdkIGxpa2UgdG8gYXZvaWQg
YW55IHRlc3RzIG9mIGNsX21pbm9ydmVyc2lvbiBpbiB0aGUgTkZTDQpjb2RlLiBXZSBjYW4gYW5k
IHNob3VsZCBhbHdheXMgcmVwbGFjZSB0aGF0IHdpdGggdGVzdHMgZm9yIHNlcnZlcg0KZnVuY3Rp
b25hbGl0eSwgd2hpY2ggaXMgd2hhdCB0aGUgTkZTX0NBUF8qIGZsYWdzIGFyZSBmb3IuIFRoaXMg
aXMNCnBhcnRpY3VsYXJseSB0cnVlIG5vdyB0aGF0IHdlJ3JlIGV4cGVjdGVkIHRvIGNvZGUgdG8g
dGhlIG1vcmUgZmxleGlibGUNCm1pbm9yIHZlcnNpb25pbmcgc2NoZW1lIGFzIGRlc2NyaWJlZCBp
biBSRkM4MTc4Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWlu
dGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoN
Cg==
