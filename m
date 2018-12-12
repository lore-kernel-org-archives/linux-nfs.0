Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4013C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 18:03:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6742720839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 18:03:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="u1Eknl7g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6742720839
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727799AbeLLSDc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 13:03:32 -0500
Received: from mail-eopbgr730096.outbound.protection.outlook.com ([40.107.73.96]:43456
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727748AbeLLSDc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 13:03:32 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ou32ctPMtZ+KZXbYgNtS8FiksCXKiOJtZkMbGGEQA2k=;
 b=u1Eknl7gQ8Hun1hpPfcqSH8S5PaeRyuGdWwsXVhdPd6nqJZR2z0JNFtBhfTMwlR73n9ybtpt9YW+stFo8474U67K7sBSYAaTSM7KxiU0WQ/6hIyjlAx7W6Arhsi8UJKvtsoopv1zFXUKwL87dBL6AB5asaC+9ElKDfR8fhtAW8w=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2256.namprd13.prod.outlook.com (52.135.93.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1425.9; Wed, 12 Dec 2018 18:02:43 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1425.016; Wed, 12 Dec 2018
 18:02:42 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
Thread-Topic: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
Thread-Index: AQHUkiHeJLBUoo3NPE2KzZb14GrSrKV7UuKAgAAOVwCAAARAgA==
Date:   Wed, 12 Dec 2018 18:02:42 +0000
Message-ID: <99a88b32d140228d5382eb176d0f19df27483654.camel@hammerspace.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
         <20181212135157.4489-2-dwysocha@redhat.com>
         <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
         <1544636846.3750.2.camel@redhat.com>
In-Reply-To: <1544636846.3750.2.camel@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [24.75.238.72]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2256;6:b04hnLmIRL3XzrMPFmIosRbeQPYAbDTvlp6SC8pkrlFhKx/0g0CG7Q6uyBQcuOhBH9CAi2Apq2PZwOZJv+fGDu8Mhks6s75k5z4TMqNr0JXpF5jIx1c8/z+gjhNlDk/KeGL/6aZkoAFZ67YXDKX5ZhNAJYmpfMhEhNlbqatbA2/X6vzJCaWAs4WKAkoBn02iOWm3IxSpv2m0dmOqcs7FdDHzuqir5qvi3gqHHRSWVVduKsPGllQoBXHOOwQm3q178kKobtiGSchMK3Ee4z1z+Nn+0MZ4Ty8xDMmnC0P+Mu2uCiE+aj/l99WDV6dszMliUHJdiT4fB8bKOfvd5Ac88Qy123xGDoGe+3l9WseMDtlluXx/6SFgKR/tVFJQkmIijrVc5Evr0VevbcgZiRCTJjxsltyC7gCH4c1HBmko9cGkPxdqzEbDTRDwgEvC0ujcmLC/cE5cbadWcvEVKv4DNw==;5:SGHUpoGrxz+uoPbaaGCJ+Rf396kf73MBwglWz29bv+zxb9iVUyecoRs4loBBPJ+gdjLcKqh8lbhfMPjxUH5RRmbhHyDuWPrt3JI3H2lvfHyiZGAuR2IRY6ZHRhgC9T3f5edSh/SiFBgNTjJcNtm0q2RIgmNaOtENL/kZ/BrnnR8=;7:BZgDI9f62ZR1CQ6C12MjxEENgX41iXoIUkY1X+f+JBWCvn1p7klIjYGjrb+7wajXxZKlg4rUR2ATOlrpAwEU43TpXTGFpqC2NznQtUtviDyYHuUJnPLl/Kks8rbZFeBskBCFoNhuMsdzaRb7jXOQNA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: bc0230c4-022d-4739-6e24-08d6605c035e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2256;
x-ms-traffictypediagnostic: SN6PR13MB2256:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB22561F10BEAADC67252D299FB8A70@SN6PR13MB2256.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230017)(999002)(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(10201501046)(3231472)(944501520)(52105112)(3002001)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(20161123558120)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2256;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2256;
x-forefront-prvs: 0884AAA693
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(346002)(39830400003)(376002)(366004)(199004)(189003)(102836004)(6506007)(14454004)(229853002)(6486002)(6436002)(186003)(26005)(5660300001)(110136005)(93886005)(305945005)(7736002)(316002)(76176011)(106356001)(105586002)(99286004)(2906002)(3846002)(81156014)(6116002)(4001150100001)(97736004)(6512007)(446003)(11346002)(476003)(53936002)(2616005)(6246003)(86362001)(66066001)(575784001)(8936002)(81166006)(71190400001)(8676002)(71200400001)(2501003)(486006)(36756003)(4326008)(14444005)(118296001)(256004)(478600001)(68736007)(25786009);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2256;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: ZrdBgJJCZhyQnEWqCJF9NPVvqF53F6Ezyz3CaP5wDzuBtGsuclsR86I1Ht+LSkbVW5lwJzo75CNbriuz0CNBlsXuZUyRLllrUhRY7v0qrNB2ORsUAsol4UoDyQoW112/8t5TfAhFCwLqadkFSGnj9KXPHqZcgz8BkicQBt9LwddV0uiTuXkhublprgCoMiQniwmli7qnyRpY7b/rf0vIxbh9m1sHZY/ykvt0RB1Yj7Gj0nJT/3TRG/4a1vCFcw1Ki1ndMXOMug+SHmzgHdx2j15OYl3nCnOAWFBQ19UJsfWkaU/JgwHeYTdv/IhIzRpk
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <A98BDEDDD9B3124B85B2A9155CF02F97@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bc0230c4-022d-4739-6e24-08d6605c035e
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Dec 2018 18:02:42.8020
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2256
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE4LTEyLTEyIGF0IDEyOjQ3IC0wNTAwLCBEYXZlIFd5c29jaGFuc2tpIHdyb3Rl
Og0KPiBPbiBXZWQsIDIwMTgtMTItMTIgYXQgMTY6NTYgKzAwMDAsIFRyb25kIE15a2xlYnVzdCB3
cm90ZToNCj4gPiBPbiBXZWQsIDIwMTgtMTItMTIgYXQgMDg6NTEgLTA1MDAsIERhdmUgV3lzb2No
YW5za2kgd3JvdGU6DQo+ID4gPiBDb21taXQgOWIzMDg4OWM1NDhhIGNoYW5nZWQgdGhlIGhhbmRs
aW5nIG9mIFRDUF9DTE9TRSBpbnNpZGUNCj4gPiA+IHhzX3RjcF9zdGF0ZV9jaGFuZ2UuICBQcmlv
ciB0byB0aGlzIGNoYW5nZSwgdGhlIFhQUlRfQ09OTkVDVEVEDQo+ID4gPiBiaXQNCj4gPiA+IHdh
cyBjbGVhcmVkIHVuY29uZGl0aW9uYWxseSBpbnNpZGUgeHBydF9kaXNjb25uZWN0X2RvbmUsIHNp
bWlsYXINCj4gPiA+IHRvIHRoZSBoYW5kbGluZyBvZiBUQ1BfQ0xPU0VfV0FJVC4gIEFmdGVyIHRo
ZSBjaGFuZ2UgdGhlIGNsZWFyaW5nDQo+ID4gPiBvZiBYUFJUX0NPTk5FQ1RFRCBkZXBlbmRzIG9u
IHN1Y2Nlc3NmdWxseSBxdWV1ZWluZyBhIHdvcmsgYmFzZWQNCj4gPiA+IHhwcnRfYXV0b2Nsb3Nl
IHdoaWNoIGRlcGVuZHMgb24gWFBSVF9MT0NLRUQgYW5kIG1heSBub3QgaGFwcGVuLg0KPiA+ID4g
VGhpcyBpcyBzaWduaWZpY2FudCBpbiB0aGUgY2FzZSBvZiBhbiB1bmV4cGVjdGVkIFJTVCBmcm9t
IHRoZQ0KPiA+ID4gc2VydmVyLCBhcyB0aGUgY2xpZW50IHdpbGwgb25seSBzZWUgeHNfdGNwX3N0
YXRlX2NoYW5nZSBjYWxsZWQNCj4gPiA+IHdpdGgNCj4gPiA+IHNrX3N0YXRlID09IFRDUF9DTE9T
RS4gIFJlc3RvcmUgdGhlIHVuY29uZGl0aW9uYWwgY2xlYXJfYml0IG9uDQo+ID4gPiBYUFJUX0NP
Tk5FQ1RFRCB3aGlsZSBoYW5kbGluZyBUQ1BfQ0xPU0UgYW5kIG1ha2UgaXQgY29uc2lzdGVudA0K
PiA+ID4gd2l0aCBoYW5kbGluZyBUQ1BfQ0xPU0VfV0FJVC4NCj4gPiA+IA0KPiA+ID4gU2lnbmVk
LW9mZi1ieTogRGF2ZSBXeXNvY2hhbnNraSA8ZHd5c29jaGFAcmVkaGF0LmNvbT4NCj4gPiA+IC0t
LQ0KPiA+ID4gIG5ldC9zdW5ycGMveHBydHNvY2suYyB8IDEgKw0KPiA+ID4gIDEgZmlsZSBjaGFu
Z2VkLCAxIGluc2VydGlvbigrKQ0KPiA+ID4gDQo+ID4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJw
Yy94cHJ0c29jay5jIGIvbmV0L3N1bnJwYy94cHJ0c29jay5jDQo+ID4gPiBpbmRleCA4YTVlODIz
ZTBiMzMuLmI5Nzg5MDM2MDUxZCAxMDA2NDQNCj4gPiA+IC0tLSBhL25ldC9zdW5ycGMveHBydHNv
Y2suYw0KPiA+ID4gKysrIGIvbmV0L3N1bnJwYy94cHJ0c29jay5jDQo+ID4gPiBAQCAtMTQ5Miw2
ICsxNDkyLDcgQEAgc3RhdGljIHZvaWQgeHNfdGNwX3N0YXRlX2NoYW5nZShzdHJ1Y3Qgc29jaw0K
PiA+ID4gKnNrKQ0KPiA+ID4gIAkJaWYgKHNrLT5za19lcnIpDQo+ID4gPiAgCQkJeHBydF93YWtl
X3BlbmRpbmdfdGFza3MoeHBydCwgLXNrLQ0KPiA+ID4gPiBza19lcnIpOw0KPiA+ID4gIAkJLyog
VHJpZ2dlciB0aGUgc29ja2V0IHJlbGVhc2UgKi8NCj4gPiA+ICsJCWNsZWFyX2JpdChYUFJUX0NP
Tk5FQ1RFRCwgJnhwcnQtPnN0YXRlKTsNCj4gPiA+ICAJCXhzX3RjcF9mb3JjZV9jbG9zZSh4cHJ0
KTsNCj4gPiA+ICAJfQ0KPiA+ID4gICBvdXQ6DQo+ID4gDQo+ID4gSGkgRGF2ZSwNCj4gPiANCj4g
PiBUaGlzIGlzbid0IG5lZWRlZCBmb3IgNC4yMCBvciBuZXdlciBiZWNhdXNlIGNhbGxfdHJhbnNt
aXQoKSB3aWxsDQo+ID4gbm93DQo+ID4gYWx3YXlzIGNhbGwgeHBydF9lbmRfdHJhbnNtaXQoKS4g
SSBzdWdnZXN0IHRoYXQgYSBzdGFibGUgZml4IGRvDQo+ID4gc29tZXRoaW5nIHNpbWlsYXIgKHBl
cmhhcHMgY29uZGl0aW9uYWwgb24gdGhlIGVycm9yIHJldHVybmVkIGJ5DQo+ID4geHBydF90cmFu
c21pdCgpPykuDQo+ID4gDQo+IA0KPiBDYW4geW91IGV4cGxhaW4gdGhlIGhhbmRsaW5nIGluIHhz
X3RjcF9zdGF0ZV9jaGFuZ2UgLSB3aHkNCj4gWFBSVF9DT05ORUNURUQgd291bGQgbmVlZCB0byBy
ZW1haW4gc2V0IGxvbmdlciBpbiB0aGUgY2FzZSBvZg0KPiBoYW5kbGluZw0KPiBUQ1BfQ0xPU0Ug
Y2FzZSByYXRoZXIgdGhhbiBUQ1BfQ0xPU0VfV0FJVD8gIEl0IHNlZW1zIGxpa2UgaWYgd2UgZ2V0
DQo+IGFuDQo+IFJTVCB3ZSdsbCBnbyBkaXJlY3RseSB0byBUQ1BfQ0xPU0UgYW5kIHdoeSB3b3Vs
ZCB0aGUgWFBSVF9DT05ORUNURUQNCj4gYml0DQo+IGdldHRpbmcgY2xlYXJlZCBuZWVkIHRvIGJl
IGRlbGF5ZWQgaW4gdGhhdCBjYXNlPw0KPiANCj4gSSB3aWxsIGxvb2sgaW50byB0aGUgYXBwcm9h
Y2ggeW91IG1lbnRpb24gdGhvdWdoIGF0IHRoZSBtb21lbnQgSSBkbw0KPiBub3QNCj4gc2VlIGhv
dyBpdCBoZWxwcyBiZWNhdXNlIHRoZSB1bmRlcmx5aW5nIGlzc3VlIHNlZW1zIHRvIGJlIGNsZWFy
aW5nIG9mDQo+IHRoZSBYUFJUX0NPTk5FQ1RFRCBiaXQuDQo+IA0KDQpTZWUgeHBydF9jbGVhcl9s
b2NrZWQoKS4gRHJvcHBpbmcgdGhlIFhQUlRfTE9DSyB3aWxsIGF1dG9tYXRpY2FsbHkNCnRyaWdn
ZXIgYXV0b2Nsb3NlIGlmICBYUFJUX0NMT1NFX1dBSVQgaXMgc2V0LCByZWdhcmRsZXNzIG9mIHdo
ZXRoZXIgb3INCm5vdCB0aGVyZSBhcmUgb3RoZXIgdGFza3Mgd2FpdGluZyBmb3IgdGhlIGxvY2su
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhh
bW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
