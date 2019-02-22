Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F1DFC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 13:45:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF1382075C
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 13:45:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="h/Vpfgl/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726285AbfBVNpt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 08:45:49 -0500
Received: from mail-eopbgr710115.outbound.protection.outlook.com ([40.107.71.115]:26848
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726275AbfBVNps (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 08:45:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1GAOfRZQRX12t9pRd+eh+PzedViCRRz1/bVA0XQ46to=;
 b=h/Vpfgl/17mbTlxrorPLJMZL3asGNjoCWWjCmRo+B8a9OK/6u/6Pf2a8DYzrBaIAnxgwwXPoZou915pQPsiTyMptzFe4d/voqfoz91FnXQzzpXJyLm2tITKI2EKGoGllKjQRhfomtB5+2ym2/5+nzavPa8ZJuL42cSpmcI0mq2Y=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2573.namprd13.prod.outlook.com (52.135.96.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.6; Fri, 22 Feb 2019 13:45:44 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.018; Fri, 22 Feb 2019
 13:45:44 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Thread-Topic: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Thread-Index: AQHUySyIDqRlQFwo+E+ucUjvP+DatqXrvYkAgAAZ7AA=
Date:   Fri, 22 Feb 2019 13:45:44 +0000
Message-ID: <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
         <1550837576.6456.3.camel@redhat.com>
In-Reply-To: <1550837576.6456.3.camel@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0c2c8630-97af-45eb-589f-08d698cc0b34
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2573;
x-ms-traffictypediagnostic: SN6PR13MB2573:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNTczOzIzOmRJdmhkTlBXWDBFQ1EzS3ZaYXZHaEUrNjFx?=
 =?utf-8?B?NmhTNUZtbFRYcFc5aW5jcWFXN3A4aWhhdFYzMmZlSXRrN092a2lqRVdyUFV1?=
 =?utf-8?B?NGJrK3JydVhUTkpZemJ0TGk3RExxYkdncXVsNUhNMFJicE1IUmJzRDZHWjJL?=
 =?utf-8?B?cmZCUVBPU1pPdVg1SGlKOGVBWC8vREJwWTd4bktseThiRHMvNHh5Wi81emc0?=
 =?utf-8?B?Z3pXeFp1eVFMMStUanhxdU5zK3JTNm1iYUxEV3VBTlJlRHZPbE16NVlwZnFE?=
 =?utf-8?B?UUxRNWYxTi9VVDlCZWJXQVBwUjRlcE9nTEdPbVBwdmhMa1ZQaFBSM091QW9D?=
 =?utf-8?B?Y1ZhNTlpY0RZMERBR0hjQWwyRy9GOWR0alhXUmNQdGF4aGtWemk5L2JYclk2?=
 =?utf-8?B?bXBybnBtRDMrd01hbHg5WE05dzUvZ3NoTlRVcDFFekFJTktvckVKczhWSGFZ?=
 =?utf-8?B?NitHcTZzKy9Cd3pMRmhzUFltQ1pVK2FIRk9SUllKbzJGaCsrNFhjM1JjVkJ1?=
 =?utf-8?B?YWtVWVh0T0d3ZUlqblRhTUlqdU5aSkpWbEViOGdzS3ZSUUhVVzJtcDNKMEhs?=
 =?utf-8?B?eDBvMHF3SittN0FrRXZ0aWRrNVg1bW9kVDQvSzg1ZThLeTFzTkV1UE1tS3kz?=
 =?utf-8?B?eTQwbGlIdnF6eFk5S0gwVWxEOHRXYVI2WWZoMS9DUG4xRjNBL2V6aEEycjVI?=
 =?utf-8?B?TytWTEM2aTZwZlZCbjY2NERQNi92MHJkMnVZZUxnL2cwVW5OZXdWZ2xIRlAy?=
 =?utf-8?B?UmRiVjZtNndZZ2dlWERyZWtxeE0rR3d2UTlmS0NKUndXSFl1L1VtUlc2WDN6?=
 =?utf-8?B?Tmk4eGttY3ZCK3dVdkt2UlVkdjZaczkrbUl1RHpvY25tdXRBT3JjdzVTZnhI?=
 =?utf-8?B?OWFEdTQ0SmUreitiWWRCcUVOTGRQL1hka01VMHlHVlhXN2FWdVlERGhiY2hC?=
 =?utf-8?B?RnZYYkJoeVZBN3R4bVYxdVVxU21PRkozdUUwWGZXN1RpRXdMSXBrMUp4cmV6?=
 =?utf-8?B?RE9nU3ZwZTBYZmlGZ2RtWVNFWHFRT0JQL1cxd3F1MkpsVFA5Yko1TzNZcVpp?=
 =?utf-8?B?Uk1GbTVUL1BiU1VXRXhhdEQxWEljYWVRMEdvQjVLQkdiUm1OZStTNmlaN1Bo?=
 =?utf-8?B?Tm9ZZlVRRENlN0hwWlN4LzJyM1ZqVjRNaEZXblB2SDRqanBjZ1N0RkdWUUdi?=
 =?utf-8?B?bUhWQ0VBeXhHQnIyWlZTWEVDeTUza2xXTUVlM0ZCUVh3bnFJU202NFAzMWYy?=
 =?utf-8?B?ZTM0T3BubG9MYWlETlkzV1ZaWjI3eDlrUW9ESHUyYWpoRXViNzZSV2Y1aXc0?=
 =?utf-8?B?V2RRekVpb0tOMGZxc3FwR1VLVTQyUkxMQ3pFd0JTS01UZnBCbkhOQjhJaWxn?=
 =?utf-8?B?V2tXR3hPZnFsd0lTanZXMExGc25ybGZMWmdWTGZ4c1hqMEJ1VkUzVXBXWGJs?=
 =?utf-8?B?dE41Z0Uvd3JINGs0SmRLREVFMzNNdHUvUTZNTmNyLzhwVENZN0xpenhZY284?=
 =?utf-8?B?Mk14RFdVNWFhdW1jWEVBR2xBL0cxWUJndjRwcEh2M1hJNEdScHpRdy82cXM0?=
 =?utf-8?B?Nk04dUFISE1TWEpjUUhjQ0hNTVlVS2F0RFM3R3M1MWJZbmJOR2RDWEJzYWZS?=
 =?utf-8?B?c2tXV3FHNXhscy9OOTU0T05pKzNRUmUvaHE2VWxiUjhSNjV4KzFDVk5nPT0=?=
x-microsoft-antispam-prvs: <SN6PR13MB25737FA558D9BFB1B3D38A67B87F0@SN6PR13MB2573.namprd13.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(39830400003)(366004)(396003)(136003)(189003)(199004)(3846002)(486006)(11346002)(476003)(2616005)(186003)(478600001)(110136005)(446003)(316002)(256004)(105586002)(36756003)(71190400001)(6116002)(71200400001)(14444005)(26005)(2906002)(6506007)(4326008)(102836004)(8936002)(8676002)(81156014)(6486002)(97736004)(76176011)(6246003)(2201001)(81166006)(99286004)(6512007)(53936002)(5660300002)(7736002)(118296001)(66066001)(2501003)(14454004)(25786009)(6436002)(106356001)(86362001)(68736007)(305945005)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2573;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: xeW25QWfLnLVTxl7+PJ95PV4TrYxmY88T2GDGm4KGHo5hDAzt8DGG5C28I1fuJUL94alGmo5fpS5Iv4p3pxK4TskVxak1zg6Mavmrrxix2E6Bl9jr4Jcy0yqgxn8RLCfXy3owIsAN+6IWeg0ajnYqHt+6jjQinp4/QFURiIKXjZT1Lu330HL295VXQj3iPxLM+3ykgp+Jqgz5clHGjw4uYzSbyQkvlnEQ3UEA5cUbSKjX+WHeM83ssLxeu4kWJyd0n+dA/T1DGybXZ5JGzicKaZQCOhjycbA1swhp7gbgWZaC2/fBLQt33F5SXawkAbZnWIVSubjBW7/j3j/78frjU7Cc5HKgeSExE7UIN2bGjUWt7MtRu63H2269ziD0wWuq26LiFpsV/6JixP2kbs4/TFHWMiPvdO3cToZdkRG8Jw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <29FA2B05AC1CBC488DCA2CFD609B0026@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0c2c8630-97af-45eb-589f-08d698cc0b34
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 13:45:44.7403
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2573
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAyLTIyIGF0IDA3OjEyIC0wNTAwLCBEYXZlIFd5c29jaGFuc2tpIHdyb3Rl
Og0KPiBIaSBPbGdhLA0KPiANCj4gRG8geW91IGhhdmUgYSByZXByb2R1Y2VyIGZvciB0aGlzPyAg
QSBudW1iZXIgb2YgbW9udGhzIGFnbyBJIGRpZCBhDQo+IHNpZ25pZmljYW50IGFtb3VudCBvZiB0
ZXN0aW5nIHdpdGggaGFsZi1jbG9zZWQgY29ubmVjdGlvbnMsIGFmdGVyIHdlDQo+IGhhZCByZXBv
cnRzIG9mIGNvbm5lY3Rpb25zIHN0dWNrIGluIEZJTl9XQUlUMiBpbiBzb21lIG9sZGVyIGtlcm5l
bHMuIA0KPiBXaGF0IEkgZm91bmQgd2FzIHdpdGgga2VybmVscyB0aGF0IGhhZCB0aGUgdGNwIGtl
ZXBhbGl2ZXMgKGNvbW1pdA0KPiA3ZjI2MGU4NTc1YmY1M2I5M2I3Nzk3OGMxZTM5ZjhlNjc2MTI3
NTljKSwgSSBjb3VsZCBvbmx5IHJlcHJvZHVjZSBhDQo+IGhhbmcgb2YgYSBmZXcgbWludXRlcywg
YWZ0ZXIgd2hpY2ggdGltZSB0aGUgdGNwIGtlZXBhbGl2ZSBjb2RlIHdvdWxkDQo+IHJlc2V0IHRo
ZSBjb25uZWN0aW9uLg0KPiANCj4gVGhhdCBzYWlkIGl0IHdhcyBhIHdoaWxlIGFnbyBhbmQgc29t
ZXRoaW5nIHN1YnRsZSBtYXkgaGF2ZSBjaGFuZ2VkLiANCj4gQWxzbyBJJ20gbm90IG5vdCBzdXJl
IGlmIHlvdXIgaGVhZGVyIGltcGxpZXMgYW4gaW5kZWZpbml0ZSBoYW5nIG9yDQo+IGp1c3QNCj4g
YSBmZXcgbWludXRlcy4NCj4gDQo+IFRoYW5rcy4NCj4gDQo+IA0KPiBPbiBXZWQsIDIwMTktMDIt
MjAgYXQgMDk6NTYgLTA1MDAsIE9sZ2EgS29ybmlldnNrYWlhIHdyb3RlOg0KPiA+IEZyb206IE9s
Z2EgS29ybmlldnNrYWlhIDxrb2xnYUBuZXRhcHAuY29tPg0KPiA+IA0KPiA+IFdoZW4gc2VydmVy
IHJlcGxpZXMgd2l0aCBhbiBBQ0sgdG8gY2xpZW50J3MgRklOL0FDSywgY2xpZW50IGVuZHMNCj4g
PiB1cCBzdHVjayBpbiBhIFRDUF9GSU5fV0FJVDIgc3RhdGUgYW5kIGNsaWVudCdzIG1vdW50IGhh
bmdzLg0KPiA+IEluc3RlYWQsIG1ha2Ugc3VyZSB0byBjbG9zZSBhbmQgcmVzZXQgY2xpZW50J3Mg
c29ja2V0IGFuZCB0cmFuc3BvcnQNCj4gPiB3aGVuIHRyYW5zaXRpb25lZCBpbnRvIHRoYXQgc3Rh
dGUuDQoNClNvLCBwbGVhc2UgZG8gbm90ZSB0aGF0IHdlIGRvIG5vdCB3YW50IHRvIGlnbm9yZSB0
aGUgRklOX1dBSVQyIHN0YXRlDQpiZWNhdXNlIGl0IGltcGxpZXMgdGhhdCB0aGUgc2VydmVyIGhh
cyBub3QgY2xvc2VkIHRoZSBzb2NrZXQgb24gaXRzDQpzaWRlLiBUaGF0IGFnYWluIG1lYW5zIHRo
YXQgd2UgY2Fubm90IHJlLWVzdGFibGlzaCBhIGNvbm5lY3Rpb24gdXNpbmcNCnRoZSBzYW1lIHNv
dXJjZSBJUCtwb3J0IHRvIHRoZSBzZXJ2ZXIsIHdoaWNoIGlzIHByb2JsZW1hdGljIGZvcg0KcHJv
dG9jb2xzIHN1Y2ggYXMgTkZTdjMgd2hpY2ggcmVseSBvbiBzdGFuZGFyZCBkdXBsaWNhdGUgcmVw
bHkgY2FjaGUNCmZvciBjb3JyZWN0IHJlcGxheSBzZW1hbnRpY3MuDQoNClRoaXMgaXMgd2h5IHdl
IGRvbid0IGp1c3Qgc2V0IHRoZSBUQ1BfTElOR0VSMiBzb2NrZXQgb3B0aW9uIGFuZCBjYWxsDQpz
b2NrX3JlbGVhc2UoKS4gVGhlIGNob2ljZSB0byB0cnkgdG8gd2FpdCBpdCBvdXQgaXMgZGVsaWJl
cmF0ZSBiZWNhdXNlDQp0aGUgYWx0ZXJuYXRpdmUgaXMgdGhhdCB3ZSBlbmQgdXAgd2l0aCBidXN5
LXdhaXRpbmcgcmUtY29ubmVjdGlvbg0KYXR0ZW1wdHMuDQoNCkNoZWVycw0KICBUcm9uZA0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3Bh
Y2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
