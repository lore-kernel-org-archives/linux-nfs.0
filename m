Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80573C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 13:51:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3F1EA2075C
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 13:51:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="v/7nfmuN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726131AbfBVNv4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 08:51:56 -0500
Received: from mail-eopbgr770094.outbound.protection.outlook.com ([40.107.77.94]:29422
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725942AbfBVNv4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 08:51:56 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=iDmcCN1N/nGoesMc0bEUpnDUoTXObeNmbOpeaw9rC7o=;
 b=v/7nfmuNcqpUe5RoSSL2XorfsrGR/0mYJvuZVYtPgmX1fThOgq+HP7w9NQfZ6oqTzUpK8cileXXFlENhI2svBfyXrjL8R4zsqOh4Zn7E38SxsgrOUKLoTIZPI8preuBapUF1sK6jm+20Dj5T89nfYjfACyzApPNJlz1pPMGmPrI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2350.namprd13.prod.outlook.com (52.135.94.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Fri, 22 Feb 2019 13:51:13 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.018; Fri, 22 Feb 2019
 13:51:13 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "yangerkun@huawei.com" <yangerkun@huawei.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "yi.zhang@huawei.com" <yi.zhang@huawei.com>,
        "houtao1@huawei.com" <houtao1@huawei.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "zhangxiaoxu5@huawei.com" <zhangxiaoxu5@huawei.com>
Subject: Re: [PATCH] nfs: drop acl cache in __nfs3_proc_setacls
Thread-Topic: [PATCH] nfs: drop acl cache in __nfs3_proc_setacls
Thread-Index: AQHUyO1uRYQCw9FNE0WekzWdOezfAaXrcGwAgABpD4A=
Date:   Fri, 22 Feb 2019 13:51:13 +0000
Message-ID: <687cae4ab7fe14be71994a2d07184af5b69e57ff.camel@hammerspace.com>
References: <20190220072925.103352-1-yangerkun@huawei.com>
         <36623ffc-100a-8abc-451d-0c8a911482b5@huawei.com>
In-Reply-To: <36623ffc-100a-8abc-451d-0c8a911482b5@huawei.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fecca0c4-bf44-450d-c73a-08d698cccf14
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2350;
x-ms-traffictypediagnostic: SN6PR13MB2350:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzUwOzIzOlBFSjBDSHpqZG9mQmNQWWh0R3NwR2drdHds?=
 =?utf-8?B?d1M0UWN1dm9iTm9Ed0t1V2lJZDNSNnpWNjFuWWpaRzlNdU44Y09xdkdNZjJm?=
 =?utf-8?B?YWtMSVNicmZXRnV2NVFRL2pjaHNmL0N1WXZZYUxpa216d3cyTk5QMWJoQ3V4?=
 =?utf-8?B?VmIxekN3clg1Vm9LTUtWQWVvSE9ad0RJc3JjVGp3UnBlUDVzM2NkeXAvOFpt?=
 =?utf-8?B?ZXVnMTdNU1JRY3YzREp5YVNZZm1IWTMyQUlBaDhiRm9zdnZyRVlxbkxIUTAw?=
 =?utf-8?B?WUtMdWEyS3dwZmRnZTVNMTNvK1BZdVdwY1oxdGJ2OEtrcnVZNHR3cU51R01j?=
 =?utf-8?B?VlJPdHdGbFhzcGdFemdNcTF1aVFGWEliVmQwMHU3ZmVEdDBGMGZUajI2VXpI?=
 =?utf-8?B?Z01UVHdJeDlpRUk2ZDdrS2VYNUg2UjY4dmkxSkZWQXgxVS90Qm5CV1hnRjVu?=
 =?utf-8?B?eXhMRXpTM2Vlb05iUHp0RXF1bWVmNUF2OXlLSEg2cm4wMDBPYmU3K2hIQjdt?=
 =?utf-8?B?ZTN2UHA1cXNPK2ZDU0tRNmF3SHMwei96c2d4cWFWbnpPZ3Jha2c4amI3c3JF?=
 =?utf-8?B?dTd1eCtlT1MyVkF0RDRTazR6L3pjUURYK0F2aTVWdmdtY055SXZZZUE0NDZO?=
 =?utf-8?B?V0JITU1ZaytHakRHNWZCdUZLNjRiUnFpSzJDcm5HNU53WUQ5T1VMSFFjaVlU?=
 =?utf-8?B?WnJPOFhybHAxbHpNTUYvY1VRU1F6MGNkM3ZCdHA0TkprL2c1VUhGcUw4Z1FW?=
 =?utf-8?B?a29HWjZTUnZBY2FlMXYyb0plS1haRGd5MVkzTjVFbGpUWGsxZFBTeVdJeGdm?=
 =?utf-8?B?eTk1WlFGUldaVFo3WlN5eVJpQ3ZnUlN0dU5NVm5sRzhlbUJWaitJZXR6d3lt?=
 =?utf-8?B?V0xtRC8zU1ZMMVRNNk5BMXFCYW1ZUy90NHR3dFQ0bTV3T3dld3BoTmxUYm00?=
 =?utf-8?B?cVArMDcwQnZjYk1yTTh2YXVSdDYyUmxhWmJiY0RaMHNoWExqVTdiUnVwL1Mr?=
 =?utf-8?B?UGRHbFU1UFVOc1RXRld1RlpXZU1TYmlNSU1BZUlNR0Y5bFVlU2JLQXlzaERH?=
 =?utf-8?B?cGIxZkI3cUJ6U0REZmFGTUQremhpL0tvK2F2RTRiY0NXRUlOeUFyeTN3RlQy?=
 =?utf-8?B?b1NmaXh3eVV2bmtZQWRiM21EL0lpbTc1ZEp2M3RDekxubXJ0VzNHU1AvcWg3?=
 =?utf-8?B?WFNER0ZMSmhVNStxR2VsQ204YnVTY3R1cGhpcHJoR0hpSHMrdENxRHQ3WDV3?=
 =?utf-8?B?YnhWMkEzVTU0WlQ1OFJHcGNwcUxjNEl4MDVDSHBLT2ZnbmRQMzJkUHo4cjk0?=
 =?utf-8?B?ZmRaL0FIaXYvNUg4b0hCS3I0SDM0M3FqaHBXcW1XbVlQbFVCSUh4cm8rSW82?=
 =?utf-8?B?V3ovTDBnSVhsbG1oazF6YWNZYWlzRDdoQ0tSdHI0eXNFcHlOdTJzS253NjFM?=
 =?utf-8?B?UkpnOE1ncGFCd2Zab1YyS2RrMEdCTWp1SUx0cURsMVlQY2QrV2xsTUhKaUE3?=
 =?utf-8?B?OURuaU02dWJqWnQzVzZSK3dEaHZoc3RrOXA4cDhOQ24yNndJSkpyZkJMMUJj?=
 =?utf-8?B?MFpkOXg4eU8yZndYeUJ0ZTRkU0dtQzBTSVo5UmdBSEdoSVNtMUdycCtXVGI1?=
 =?utf-8?B?S0VsUEQrcUtObWdidHhNYUxLYkNUbzZoY3dvT3o3b1RxWnM4T25nd2IzSmNZ?=
 =?utf-8?B?Z0ViakJ4T0pjcGNIRktMM0MzOGJaaFZWcXdBSU1MZWRBcVJZYzZOUStOKytG?=
 =?utf-8?B?ajJtaTcwb09hVzRCSEd0dz09?=
x-microsoft-antispam-prvs: <SN6PR13MB2350E80A20C6D0A8B51660A0B87F0@SN6PR13MB2350.namprd13.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(366004)(346002)(376002)(39830400003)(189003)(199004)(6436002)(446003)(229853002)(99286004)(6246003)(2501003)(53936002)(5660300002)(68736007)(6486002)(6306002)(7736002)(3846002)(110136005)(6506007)(8936002)(4326008)(6116002)(6512007)(76176011)(54906003)(6346003)(66066001)(316002)(14454004)(2906002)(81156014)(86362001)(2616005)(118296001)(105586002)(186003)(26005)(71200400001)(305945005)(81166006)(14444005)(256004)(8676002)(25786009)(11346002)(102836004)(36756003)(97736004)(486006)(478600001)(476003)(106356001)(966005)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2350;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: pt2sKkrS3/WDRW+dFWMDpPsK2RLjC/KWzjsJ9LXN0hTFTKOT34w6NF80mFoiXzC4s9aJlN+Pj7XtNIEhbWf+I7889fjFrHYoN3uOmePhkwBb3k0e+sqgt/uYRtcJ5vuOcuCATQCWraUyMQMJvs2Tk4FZipWW/hV9V07bc/u6hLvAYR+Yh5tpy0wdi10jFjErMGWhh4ngAO7tBR0YMeSOyglG6UqpkVynH+Z9QwC8Gw2NSqeYRjryuCpZpGqe4Dwk/1+0hGu4CXPnBhf8ZywYXVOpSpPvsQkSSBdAWAd0NHWw9/BCsrqui4DvmnrjSDSk3oiuGklU6vzMW1eZjupNafJDl802hg1BXW6R/1I8wDD4KlmPsg7rRJB/7Z/vcP44GN6Gme+xdn0Jkt3VKJtBWleYz2MNV0qUD7Xfen/3Isw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <851926B9D346034FB48ED9C2B2E56D5E@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fecca0c4-bf44-450d-c73a-08d698cccf14
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 13:51:13.3368
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2350
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGksDQoNCk9uIEZyaSwgMjAxOS0wMi0yMiBhdCAxNTozNSArMDgwMCwgeWFuZ2Vya3VuIHdyb3Rl
Og0KPiBQaW5nPw0KPiANCj4geWFuZ2Vya3VuIHdyb3RlIG9uIDIwMTkvMi8yMCAxNToyOToNCj4g
PiBTaW5jZSBzZXJ2ZXIgbWF5IGNhbGwgcG9zaXhfYWNsX3VwZGF0ZV9tb2RlIHdoaWNoIGNhbiBs
ZWFkIGFjbCBiZWVuDQo+ID4gTlVMTC4gU28sanVzdCBkcm9wIGFjbCBjYWNoZSBhZnRlciBycGNf
Y2FsbF9zeW5jLCBhbmQgaWYgYW55b25lDQo+ID4gd2FudCB0bw0KPiA+IHVzZSBhY2wsIHRoZXkg
Y2FuIGdldCB0aGUgY29ycmVjdCBhY2wgYnkgc2VuZCBhIG1zZyB0byBzZXJ2ZXINCj4gPiB0aGVt
c2VsdmVzLg0KPiA+IFRoaXMgY2FuIGZpeCB4ZnN0ZXN0cyBnZW5lcmljLzA5OSBvdmVyIG5mc3Yz
Lg0KPiA+IA0KPiA+IFNpZ25lZC1vZmYtYnk6IHlhbmdlcmt1biA8eWFuZ2Vya3VuQGh1YXdlaS5j
b20+DQo+ID4gLS0tDQo+ID4gICBmcy9uZnMvbmZzM2FjbC5jIHwgNCArKy0tDQo+ID4gICAxIGZp
bGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPiA+IA0KPiA+IGRp
ZmYgLS1naXQgYS9mcy9uZnMvbmZzM2FjbC5jIGIvZnMvbmZzL25mczNhY2wuYw0KPiA+IGluZGV4
IDlmY2UxODUuLjZjMDdlYmMgMTAwNjQ0DQo+ID4gLS0tIGEvZnMvbmZzL25mczNhY2wuYw0KPiA+
ICsrKyBiL2ZzL25mcy9uZnMzYWNsLmMNCj4gPiBAQCAtMjIyLDggKzIyMiw4IEBAIHN0YXRpYyBp
bnQgX19uZnMzX3Byb2Nfc2V0YWNscyhzdHJ1Y3QgaW5vZGUNCj4gPiAqaW5vZGUsIHN0cnVjdCBw
b3NpeF9hY2wgKmFjbCwNCj4gPiAgIAlzd2l0Y2ggKHN0YXR1cykgew0KPiA+ICAgCQljYXNlIDA6
DQo+ID4gICAJCQlzdGF0dXMgPSBuZnNfcmVmcmVzaF9pbm9kZShpbm9kZSwgZmF0dHIpOw0KPiA+
IC0JCQlzZXRfY2FjaGVkX2FjbChpbm9kZSwgQUNMX1RZUEVfQUNDRVNTLCBhY2wpOw0KPiA+IC0J
CQlzZXRfY2FjaGVkX2FjbChpbm9kZSwgQUNMX1RZUEVfREVGQVVMVCwgZGZhY2wpOw0KPiA+ICsJ
CQkvKiBTZXZlciBtYXkgY2FsbCBwb3NpeF9hY2xfdXBkYXRlX21vZGUgKi8NCj4gPiArCQkJZm9y
Z2V0X2FsbF9jYWNoZWRfYWNscyhpbm9kZSk7DQo+ID4gICAJCQlicmVhazsNCj4gPiAgIAkJY2Fz
ZSAtRVBGTk9TVVBQT1JUOg0KPiA+ICAgCQljYXNlIC1FUFJPVE9OT1NVUFBPUlQ6DQo+ID4gDQoN
CkkndmUgYXBwbGllZCB0aGUgZm9sbG93aW5nIHBhdGNoIA0KaHR0cDovL2dpdC5saW51eC1uZnMu
b3JnLz9wPXRyb25kbXkvbGludXgtbmZzLmdpdDthPWNvbW1pdGRpZmY7aD1kZWQ1MmZiZTcwMjBh
NTY5NmIwYjBhMGZkYmYyMzRlMzdiZjE2Zjk0DQppbiBvcmRlciB0byBmaXggdGhpcyBpc3N1ZS4N
Cg0KVGhlIHJlYXNvbiB3aHkgSSBwcmVmZXIgdGhhdCBmaXggaXMgdGhhdCB3ZSdyZSBhbHJlYWR5
IGNhbGxpbmcNCm5mc196YXBfYWNsX2NhY2hlKGlub2RlKSBpbW1lZGlhdGVseSBiZWZvcmUgdGhp
cyBzd2l0Y2ggc3RhdGVtZW50LCBzbw0KdGhlIGNhbGwgdG8gJ2ZvcmdldF9hbGxfY2FjaGVkX2Fj
bHMoKScgYXBwZWFycyByZWR1bmRhbnQuDQoNClRoYW5rcyENCiAgVHJvbmQgDQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
