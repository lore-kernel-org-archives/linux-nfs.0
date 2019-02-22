Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 198F6C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 15:51:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B57292070B
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 15:50:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="e0TcubmC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727121AbfBVPu6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 10:50:58 -0500
Received: from mail-eopbgr730118.outbound.protection.outlook.com ([40.107.73.118]:44507
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725887AbfBVPu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 10:50:58 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kRTXzQlVED1IPsiK2bYjewltvUJo/znPWrP0Top1g7g=;
 b=e0TcubmCi2sn20riZOx5mceoc6XDq8nzwcA9wQn/G6Kjl4sV0WG078RV8gWVTOIIu/AwrBDoWbIR7JfDrN2aFyU2+BUqH5LXrBtqpbrQ0KIWCymz9Fqu3aGRXhFm/M3/NArwWU1cRKD66kS0hYcMSY/KU3gnTXdD2tYCa27c7XM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2430.namprd13.prod.outlook.com (52.135.95.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.11; Fri, 22 Feb 2019 15:50:54 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.018; Fri, 22 Feb 2019
 15:50:54 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Thread-Topic: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Thread-Index: AQHUySyIDqRlQFwo+E+ucUjvP+DatqXrvYkAgAAZ7ACAABEcgIAABU+AgAABbgCAAAsfAA==
Date:   Fri, 22 Feb 2019 15:50:54 +0000
Message-ID: <132998d93b8eb3d85c63a4176536b7b1403e0f88.camel@hammerspace.com>
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
         <1550837576.6456.3.camel@redhat.com>
         <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
         <CAN-5tyE5dm07V_8Qqse5qrLQVzrYXELM1EY2ySpCedBUBKYsLQ@mail.gmail.com>
         <05e439b3c419f3ac173feb770d3d2ae1d7500a2d.camel@hammerspace.com>
         <CAN-5tyFu4g40XJ7JzTSbidaEA30NeLQXFWD4t9pkRufesV-vJw@mail.gmail.com>
In-Reply-To: <CAN-5tyFu4g40XJ7JzTSbidaEA30NeLQXFWD4t9pkRufesV-vJw@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d271d43e-420a-44aa-99f1-08d698dd875d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2430;
x-ms-traffictypediagnostic: SN6PR13MB2430:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDMwOzIzOlRtV3lXOW1MUC85MkFYWHdrMU0zZFZyZ3lp?=
 =?utf-8?B?cFY1NFhERUQ1T3dLb0xNeTJ4T282aUdNU2tCaTVZTU1zV2puSzRxY2VLaHJl?=
 =?utf-8?B?c0tqZ1Z5b3JaNFlRS09kN0w1QVdRQ1pta1crRHRreVNIUEJweTdmL0lBQnhs?=
 =?utf-8?B?UklrYzY2aCtJejFOb25RakZOUWdvVFA3U2hFKzFqQTluNzc5aFRKSENPbGdu?=
 =?utf-8?B?U055WnVEVHg2VHE0MnIwVHZzK05wT1RSWG1Kb1hJcGhkSjdITGM1NUllRWFB?=
 =?utf-8?B?Q25iRmdaU0JWMFp5aUhOaFZFUDE3eGtnbzkzeXh2Q1E0UmdxNStJejVZZ3k1?=
 =?utf-8?B?MXhwSjdBU2wxdE1wV05rWGNTUkVoeDBjdTgrMVhOMFI2WGNNWHMwejFTZDZy?=
 =?utf-8?B?ZGJaN2M2d2hVZ3VBOXhueFM4eTVVVEs2ZkpUd292NEV2L0FVckNRVWZXTTBQ?=
 =?utf-8?B?WDB2c0haWFFmaXJNbDlyNldMQ1pYSDNlSllhQ3NhUHgzNVRZczd1V0d3dGp0?=
 =?utf-8?B?bW5tM0RWWndYM1lNMm1kQWJLV29VODg2KzY0Zy9VRVMzTkFjZ1lCUWl0RWdy?=
 =?utf-8?B?d3MyTDdvelA4RERxeVIrK0lKeHo3c3FhVXZPbnc5SnY4SWpoRG5GVDkyY3k2?=
 =?utf-8?B?TUtQMHc1SDI0L1VWSGVlRTQ3U3o4YzRkWXNkV2xYSFFaczcvei84NDA4WGlM?=
 =?utf-8?B?Vjc0dFJlenVKZC9PR0tDVGNwbnl5TXdsN3l4Ui9zRkt5b3Bld3FsRnNrQXd6?=
 =?utf-8?B?bUdVamo1aDFxNlA0d3h1eS94MzkwSW03UUhpd0NNeFFBS215RFNFWlBlL2o1?=
 =?utf-8?B?MXdwSG1aMklxazdkTjU3bk1kMTk0NGJnNllVaXdiaWFvZCtDTC9FZEN2R2Z4?=
 =?utf-8?B?anM4aGJQNG94Uyt2WXQ2UDBzNGkrSEhzUElISnRPUmxWQUFOWTlDZm1GYklS?=
 =?utf-8?B?b0U1S1ZXNlNiS1lkSWpKUEUvZytTRHYxdG0wS3Y3THlnQnArY3Rsek5MaUVX?=
 =?utf-8?B?M0Fia3JNRTZXbHFkR3pwRUw0Z1VlWFNiSUtNR1huUXJhZVBQdDkxTURQdXNJ?=
 =?utf-8?B?MzBCd1g3OVlnT053Q2srcE9PUWhkOWlWYnNNR0s1VXpyV3dpRDQvRVVpSG50?=
 =?utf-8?B?TThpNWczYjR5cHFETEoya3lhZjhkNVVERFkxaG9RamRjcWF5ZjhyQWkzQUNp?=
 =?utf-8?B?RzFMM1FkYlV2c1hEQm45RnUxai9IT0YyZWQycmlGUkVFRVhRNUhSN3lmRWtG?=
 =?utf-8?B?ZFZERCt3S0FjbEVpUWc3eGVJd0dqLy9haFVxSjNUUlN3U2pzS3J2MjUvS2V6?=
 =?utf-8?B?NUNaRTR6Wm9jYkV2NGF1cVJOcnduYUpqdXo1cUJaS0lBT1FDU1FNS0RDaEgw?=
 =?utf-8?B?QkhOcXhwaE5XK3F6anJXc2RyQm1EcWtUZEM2QmMyODNXSjNXRU5leFVaaE5M?=
 =?utf-8?B?MUZFY2VXcnAvOTVDdlJVUGNzSFdCYnZ0b01DN1QybFdKdldhd2dMTWhMalE4?=
 =?utf-8?B?c1FlWUd0Y04yVHNUaS9malJkeUw3cHc3TEEyblZRUFZ5WTJyQ3kzazgrQ3ZR?=
 =?utf-8?B?OTdxVFBPeWZMM2E3d1JkWVFydHlWWFFYeDNOTURCUWFkSHhhT3VvR2tGa2c0?=
 =?utf-8?B?ajlXcVoyaWEzS0d0UWgrWUxJOTRtUHBtTkFzZXVEazk0WDE0Y2p3QjlRQnFG?=
 =?utf-8?B?OENGNjcwaG9JRmF4U1JEeVpDc3NVMWZvVFhYY09DWjI5bHYrVWY0eWtZUEx0?=
 =?utf-8?B?d2g4dkVyWWZtYXg3NDBmLzYvMWpOQnVTZnZGdkVlVjk2UXN4cWdLK2gxUSsr?=
 =?utf-8?B?dWdUTkdhUitFVGVUSGR2TzlmaGNVanl0aEw3WTVHd2JnSVE9PQ==?=
x-microsoft-antispam-prvs: <SN6PR13MB24301681AC29140E7307C286B87F0@SN6PR13MB2430.namprd13.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39830400003)(346002)(136003)(376002)(366004)(199004)(189003)(81166006)(8676002)(81156014)(6436002)(99286004)(106356001)(2501003)(4326008)(6486002)(105586002)(316002)(478600001)(86362001)(54906003)(6246003)(1361003)(97736004)(8936002)(2351001)(229853002)(93886005)(68736007)(186003)(66066001)(26005)(446003)(476003)(6346003)(6512007)(6116002)(6506007)(53546011)(71200400001)(102836004)(486006)(2616005)(14454004)(5660300002)(2906002)(256004)(11346002)(14444005)(36756003)(5640700003)(25786009)(3846002)(76176011)(6916009)(118296001)(305945005)(53936002)(7736002)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2430;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: WsHGHZ2qYtuM5s9biAznupR8kyxmoQQPoBEYQwZQokBMMs2AzntIcHI/vUsj+tWdbJvA7+IKeZ8Hu424UhPobOOq/ptYLpSKVCmLDB6DMxNwsWWPF7ItSELfmDjnHRYhusQjUaubfesllyLql12VPEQR4X5yIJBT2aWV2WBEp1/wyS31zBUH4jbig00Tq7AR+uOwTVkyd6+y0+ENGgLlO487Xy522nDj4Vn48aD0kgz5z78G9I2Vm6KxTjBTGT4K4PuVfSyFiPvQT4Z/UMWobUwklrftefnFTO8oiMx5HaE6YnTRcpQs0xUjGBK48CL5AeS/d61k2uj72SU8Yy3C4x+Edx9YJsUMGaBgZKSU5h/Zl2V3QT7y5qJD969UVfdb0AwRrwildKUD6Q8sg3eiEAfMId5omGH/ZG5QQnEWmdE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <A630C17ED3521142A654B1F406AC3166@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d271d43e-420a-44aa-99f1-08d698dd875d
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 15:50:54.4515
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2430
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAyLTIyIGF0IDEwOjExIC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gRnJpLCBGZWIgMjIsIDIwMTkgYXQgMTA6MDYgQU0gVHJvbmQgTXlrbGVidXN0DQo+
IDx0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gT24gRnJpLCAyMDE5LTAyLTIy
IGF0IDA5OjQ2IC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+IE9uIEZyaSwg
RmViIDIyLCAyMDE5IGF0IDg6NDUgQU0gVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+IHRyb25kbXlA
aGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+ID4gT24gRnJpLCAyMDE5LTAyLTIyIGF0IDA3
OjEyIC0wNTAwLCBEYXZlIFd5c29jaGFuc2tpIHdyb3RlOg0KPiA+ID4gPiA+IEhpIE9sZ2EsDQo+
ID4gPiA+ID4gDQo+ID4gPiA+ID4gRG8geW91IGhhdmUgYSByZXByb2R1Y2VyIGZvciB0aGlzPyAg
QSBudW1iZXIgb2YgbW9udGhzIGFnbyBJDQo+ID4gPiA+ID4gZGlkDQo+ID4gPiA+ID4gYQ0KPiA+
ID4gPiA+IHNpZ25pZmljYW50IGFtb3VudCBvZiB0ZXN0aW5nIHdpdGggaGFsZi1jbG9zZWQgY29u
bmVjdGlvbnMsDQo+ID4gPiA+ID4gYWZ0ZXINCj4gPiA+ID4gPiB3ZQ0KPiA+ID4gPiA+IGhhZCBy
ZXBvcnRzIG9mIGNvbm5lY3Rpb25zIHN0dWNrIGluIEZJTl9XQUlUMiBpbiBzb21lIG9sZGVyDQo+
ID4gPiA+ID4ga2VybmVscy4NCj4gPiA+ID4gPiBXaGF0IEkgZm91bmQgd2FzIHdpdGgga2VybmVs
cyB0aGF0IGhhZCB0aGUgdGNwIGtlZXBhbGl2ZXMNCj4gPiA+ID4gPiAoY29tbWl0DQo+ID4gPiA+
ID4gN2YyNjBlODU3NWJmNTNiOTNiNzc5NzhjMWUzOWY4ZTY3NjEyNzU5YyksIEkgY291bGQgb25s
eQ0KPiA+ID4gPiA+IHJlcHJvZHVjZQ0KPiA+ID4gPiA+IGENCj4gPiA+ID4gPiBoYW5nIG9mIGEg
ZmV3IG1pbnV0ZXMsIGFmdGVyIHdoaWNoIHRpbWUgdGhlIHRjcCBrZWVwYWxpdmUNCj4gPiA+ID4g
PiBjb2RlDQo+ID4gPiA+ID4gd291bGQNCj4gPiA+ID4gPiByZXNldCB0aGUgY29ubmVjdGlvbi4N
Cj4gPiA+ID4gPiANCj4gPiA+ID4gPiBUaGF0IHNhaWQgaXQgd2FzIGEgd2hpbGUgYWdvIGFuZCBz
b21ldGhpbmcgc3VidGxlIG1heSBoYXZlDQo+ID4gPiA+ID4gY2hhbmdlZC4NCj4gPiA+ID4gPiBB
bHNvIEknbSBub3Qgbm90IHN1cmUgaWYgeW91ciBoZWFkZXIgaW1wbGllcyBhbiBpbmRlZmluaXRl
DQo+ID4gPiA+ID4gaGFuZw0KPiA+ID4gPiA+IG9yDQo+ID4gPiA+ID4ganVzdA0KPiA+ID4gPiA+
IGEgZmV3IG1pbnV0ZXMuDQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gVGhhbmtzLg0KPiA+ID4gPiA+
IA0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IE9uIFdlZCwgMjAxOS0wMi0yMCBhdCAwOTo1NiAtMDUw
MCwgT2xnYSBLb3JuaWV2c2thaWEgd3JvdGU6DQo+ID4gPiA+ID4gPiBGcm9tOiBPbGdhIEtvcm5p
ZXZza2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gV2hl
biBzZXJ2ZXIgcmVwbGllcyB3aXRoIGFuIEFDSyB0byBjbGllbnQncyBGSU4vQUNLLCBjbGllbnQN
Cj4gPiA+ID4gPiA+IGVuZHMNCj4gPiA+ID4gPiA+IHVwIHN0dWNrIGluIGEgVENQX0ZJTl9XQUlU
MiBzdGF0ZSBhbmQgY2xpZW50J3MgbW91bnQgaGFuZ3MuDQo+ID4gPiA+ID4gPiBJbnN0ZWFkLCBt
YWtlIHN1cmUgdG8gY2xvc2UgYW5kIHJlc2V0IGNsaWVudCdzIHNvY2tldCBhbmQNCj4gPiA+ID4g
PiA+IHRyYW5zcG9ydA0KPiA+ID4gPiA+ID4gd2hlbiB0cmFuc2l0aW9uZWQgaW50byB0aGF0IHN0
YXRlLg0KPiA+ID4gDQo+ID4gPiBIaSBUcm9uZCwNCj4gPiA+IA0KPiA+ID4gPiBTbywgcGxlYXNl
IGRvIG5vdGUgdGhhdCB3ZSBkbyBub3Qgd2FudCB0byBpZ25vcmUgdGhlIEZJTl9XQUlUMg0KPiA+
ID4gPiBzdGF0ZQ0KPiA+ID4gDQo+ID4gPiBCdXQgd2UgZG8gaWdub3JlIHRoZSBGSU5fV0FJVDIg
c3RhdGUuDQo+ID4gDQo+ID4gV2UgZG8gbm90LiBXZSB3YWl0IGZvciB0aGUgc2VydmVyIHRvIHNl
bmQgYSBGSU4sIHdoaWNoIGlzIHByZWNpc2VseQ0KPiA+IHRoZQ0KPiA+IHJlYXNvbiBmb3Igd2hp
Y2ggRklOX1dBSVQyIGV4aXN0cy4NCj4gPiANCj4gPiA+ID4gYmVjYXVzZSBpdCBpbXBsaWVzIHRo
YXQgdGhlIHNlcnZlciBoYXMgbm90IGNsb3NlZCB0aGUgc29ja2V0IG9uDQo+ID4gPiA+IGl0cw0K
PiA+ID4gPiBzaWRlLg0KPiA+ID4gDQo+ID4gPiBUaGF0J3MgY29ycmVjdC4NCj4gPiA+IA0KPiA+
ID4gPiBUaGF0IGFnYWluIG1lYW5zIHRoYXQgd2UgY2Fubm90IHJlLWVzdGFibGlzaCBhIGNvbm5l
Y3Rpb24gdXNpbmcNCj4gPiA+ID4gdGhlIHNhbWUgc291cmNlIElQK3BvcnQgdG8gdGhlIHNlcnZl
ciwgd2hpY2ggaXMgcHJvYmxlbWF0aWMgZm9yDQo+ID4gPiA+IHByb3RvY29scyBzdWNoIGFzIE5G
U3YzIHdoaWNoIHJlbHkgb24gc3RhbmRhcmQgZHVwbGljYXRlIHJlcGx5DQo+ID4gPiA+IGNhY2hl
DQo+ID4gPiA+IGZvciBjb3JyZWN0IHJlcGxheSBzZW1hbnRpY3MuDQo+ID4gPiANCj4gPiA+IHRo
YXQncyBleGFjdGx5IHdoYXQncyBoYXBwZW5pbmcgdGhhdCBhIGNsaWVudCBpcyB1bmFibGUgdG8N
Cj4gPiA+IGVzdGFibGlzaA0KPiA+ID4gYQ0KPiA+ID4gbmV3IGNvbm5lY3Rpb24gdG8gdGhlIHNl
cnZlci4gV2l0aCB0aGUgcGF0Y2gsIHRoZSBjbGllbnQgZG9lcyBhbg0KPiA+ID4gUlNUDQo+ID4g
PiBhbmQgaXQgcmUtdXNlcyB0aGUgcG9ydCBhbmQgYWxsIGlzIHdlbGwgZm9yIE5GU3YzLg0KPiA+
IA0KPiA+IFJTVCBpcyBub3QgZ3VhcmFudGVlZCB0byBiZSBkZWxpdmVyZWQgdG8gdGhlIHJlY2lw
aWVudC4gVGhhdCdzIHdoeQ0KPiA+IHRoZQ0KPiA+IFRDUCBwcm90b2NvbCBkZWZpbmVzIEZJTjog
aXQgaXMgYSBndWFyYW50ZWVkIHRvIGJlIGRlbGl2ZXJlZA0KPiA+IGJlY2F1c2UgaXQNCj4gPiBp
cyBBQ0tlZC4NCj4gPiANCj4gPiA+ID4gVGhpcyBpcyB3aHkgd2UgZG9uJ3QganVzdCBzZXQgdGhl
IFRDUF9MSU5HRVIyIHNvY2tldCBvcHRpb24gYW5kDQo+ID4gPiA+IGNhbGwNCj4gPiA+ID4gc29j
a19yZWxlYXNlKCkuIFRoZSBjaG9pY2UgdG8gdHJ5IHRvIHdhaXQgaXQgb3V0IGlzIGRlbGliZXJh
dGUNCj4gPiA+ID4gYmVjYXVzZQ0KPiA+ID4gPiB0aGUgYWx0ZXJuYXRpdmUgaXMgdGhhdCB3ZSBl
bmQgdXAgd2l0aCBidXN5LXdhaXRpbmcgcmUtDQo+ID4gPiA+IGNvbm5lY3Rpb24NCj4gPiA+ID4g
YXR0ZW1wdHMuDQo+ID4gPiANCj4gPiA+IFdoeSB3b3VsZCBpdCBidXN5LXdhaXQ/IEluIG15IHRl
c3RpbmcsIFJTVCBoYXBwZW5zIGFuZCBuZXcNCj4gPiA+IGNvbm5lY3Rpb24NCj4gPiA+IGlzIGVz
dGFibGlzaGVkPw0KPiA+IA0KPiA+IE9ubHkgaWYgdGhlIHNlcnZlciBoYXMgZHJvcHBlZCB0aGUg
Y29ubmVjdGlvbiB3aXRob3V0IG5vdGlmeWluZyB0aGUNCj4gPiBjbGllbnQuDQo+IA0KPiBZZXMg
dGhlIHNlcnZlciBkcm9wcGVkIHRoZSBjb25uZWN0aW9uIHdpdGhvdXQgbm90aWZ5aW5nIHRoZSBj
bGllbnQNCj4gKG9yDQo+IHBlcmhhcHMgc29tZXRoaW5nIGluIHRoZSBtaWRkbGUgZGlkIGl0IGFz
IGFuIGF0dGFjaykuIEFnYWluLCBJIHJhaXNlDQo+IHRoaXMgY29uY2VybiBmb3IgdGhlIHNha2Ug
b2YgZGVhbGluZyB3aXRoIHRoaXMgYXMgYW4gYXR0YWNrLiBJIGhhdmUNCj4gbm8NCj4gaW50ZW50
aW9ucyBvZiBjYXRlcmluZyB0byBicm9rZW4gc2VydmVycy4gSWYgdGhpcyBpcyBub3QgYSBwb3Nz
aWJsZQ0KPiBhdHRhY2ssIHRoZW4gd2UgZG9uJ3QgaGF2ZSB0byBkZWFsIHdpdGggaXQuDQoNCkEg
bWFuIGluIHRoZSBtaWRkbGUgbWlnaHQgYmUgYWJsZSB0byBpbnRlcmNlcHQgdGhlIEZJTiBmcm9t
IHRoZSBzZXJ2ZXINCmFuZCBBQ0sgaXQsIGNhdXNpbmcgdGhlIGNvbm5lY3Rpb24gdG8gYmUgY2xv
c2VkIG9uIHRoYXQgc2VydmVyLg0KSG93ZXZlciwgYXMgRGF2ZSBwb2ludGVkIG91dCwgd2h5IHdv
dWxkbid0IHRoZSBrZWVwYWxpdmUgbWVjaGFuaXNtIHRoZW4NCmV2ZW50dWFsbHkga2ljayBpbiBh
bmQgY2xvc2UgdGhlIHNvY2tldCBvbiB0aGUgY2xpZW50IGFzIHdlbGw/DQoNCklmIHRoZSBGSU4g
aXMgbm90IEFDS2VkLCB0aGVuIHRoZSBzZXJ2ZXIgaXMgc3VwcG9zZWQgdG8ga2VlcA0KcmV0cmFu
c21pdHRpbmcgaXQuIFVudGlsIHRoYXQgQUNLIGlzIHJlY2VpdmVkLCBpdCBjYW5ub3QgY2xvc2Ug
dGhlDQpzb2NrZXQgd2l0aG91dCB2aW9sYXRpbmcgdGhlIFRDUCBwcm90b2NvbC4NCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UN
CnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
