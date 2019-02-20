Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8907AC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 16:46:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2BFD72083B
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 16:46:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nQX/Zp3c"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726003AbfBTQqJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 11:46:09 -0500
Received: from mail-eopbgr800137.outbound.protection.outlook.com ([40.107.80.137]:22757
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725798AbfBTQqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 11:46:09 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=d1f86op7wS6NWoYsLFrYq9Ga/P9Tipl+BrcwmL2Pjl0=;
 b=nQX/Zp3cEZUne5nGZfkfdH/lutzzrvpVoAjgglV9Ci4fzvNjMUyaL/i+Xx1BM9Bb9xShLlBAWriJpjevK9mFyW6ta7JtW6iCr7LNzvTELp6CqP7780qIX2hD5FWiwn2rCrcJpGb1+tQNax27Bci1fPYdWIacrrMVzIwtWgZnezI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2478.namprd13.prod.outlook.com (52.135.95.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Wed, 20 Feb 2019 16:45:52 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Wed, 20 Feb 2019
 16:45:52 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>
CC:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Thread-Topic: Need help debugging NFS issues new to 4.20 kernel
Thread-Index: AQHUtBBQLoOJiO8U1kuiVnwIPcpCS6W+1kMAgAGQXx+AES4Tb4ABK8OAgACVO9yAAO6cgIAARnn4gAFZDoCAC4+M14ABMVkAgAZUHTSAAANngIAADVKEgAAFxgA=
Date:   Wed, 20 Feb 2019 16:45:52 +0000
Message-ID: <ef322de97094192e97bc897c5a9f41687720e076.camel@hammerspace.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
         <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
         <ufak1isms71.fsf@epithumia.math.uh.edu>
         <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
         <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
         <87imxwab12.fsf@hippogriff.math.uh.edu>
         <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
         <87d0o3aadg.fsf@hippogriff.math.uh.edu>
         <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
         <ufa4l943i6v.fsf@epithumia.math.uh.edu>
         <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
         <ufapnrmbhyf.fsf@epithumia.math.uh.edu>
         <2ab06cbdc19d7a642e04f1e66abbeaa507b034bc.camel@hammerspace.com>
         <ufalg2abf6n.fsf@epithumia.math.uh.edu>
In-Reply-To: <ufalg2abf6n.fsf@epithumia.math.uh.edu>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0e5ca99e-032f-41e2-6303-08d69752e06d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2478;
x-ms-traffictypediagnostic: SN6PR13MB2478:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDc4OzIzOktIWWR0ZzBXLzg5bWlibzF3RERlQzc5UWdX?=
 =?utf-8?B?ZW1PUUlFTlZTcHlDZUxLb3NLKzc2OHhZb2lsdXhrSTAxOUtJbG5KSmVKMUJ4?=
 =?utf-8?B?Y002VFcvY2hvTzUvcjBoMGp4bENzVFN3WGFKSTNCZVBEYWdwYWVSd25nOVhM?=
 =?utf-8?B?VkxlelpjRXZoZWNwVW4yWTJMa2o2VmFBdGNjdmhpQm9QM0dvRVRzMGxCNVFx?=
 =?utf-8?B?ZDlEK3c4bDhtTGhiS2VjNCt6RmQyQ0JSdHh0OUtxK3ZOaDB2SHpybDlmdlA0?=
 =?utf-8?B?ajNEMi9nbG9lKzB4SlVPblJrNWNIWVZrKzB6RnYvNG41Y09VbTZSUUlYWDg1?=
 =?utf-8?B?V1pHSlYveUEyQ3FjbG5rUmFPVUlBMlVpTjhrSEtNTjNOa1I0cDNGRW5ZblZ4?=
 =?utf-8?B?K2pOaEcvQjI1Q29CeUwvRlRJV2pYUERUNDdmZEpOQ2R4VXRleXNnYVZvTDA2?=
 =?utf-8?B?V2VkcDk1bzVuTVFLdGhjSkVhQUcySUJHMldpQStWdlRZNmFnM0JoOEV4SDFp?=
 =?utf-8?B?TDNOOWpscjd1c3YvR0NoSVdCWSswTG1NbXF5U1h2Um5oK3lSQnJ3cU4xWW9B?=
 =?utf-8?B?V3U2QWlWa3h2czNKZFkxK2FtNGcveGdDVVhPMUN2THd2ZkN6Um4rQmJtLzhl?=
 =?utf-8?B?N0lMbXdJWTRCbk8xY3IxbVBjUW42Y3ZkdDFmd0V3NnplQW5peXBSdThxL3Fq?=
 =?utf-8?B?c0pZcWdWU1VvYmJzSnRVWVZoakVoTlJCR0UxM0xFK3dTWnA2MXEvcHRIVTJo?=
 =?utf-8?B?V1lhSGFWbmxIODFvSE9zMCtDQStYa2VLdSsvN0x3bjJjNDJna0xJc0YzeWR0?=
 =?utf-8?B?T2wyTnZ2VHlabUpXMnYxUmNDRVRBcVc3RFo2R3FNSS9tM080ODR2MGtjemR3?=
 =?utf-8?B?SzV5aXcrUmwrcmlUZXVtOSt6ZDk3WEFMSmZ3enBtWjd2ZHNPTXBKVlNScXdB?=
 =?utf-8?B?bm9kdzg2SU1CWjFoN3hQRVRyZ1VOOGE2ZStscU5TMUxUaDY5bW9zTVFnTUp6?=
 =?utf-8?B?VlVEUUp5R0VMMWJZdm04b2UrZXZZQ0JnUEZCNXV4Vmk2NzFyTVVITGxqYk0r?=
 =?utf-8?B?RFdNdEV2SjFZVHBBSTlicUIzWnJYa01nUTFNWG5OWXBKV3p1QUU2bkRRWUcy?=
 =?utf-8?B?ek9LQlR2OEFUeXhqdWdvcUxleC9haHJhZCtOVEZGd1lmdmN2QndhL3haS0tY?=
 =?utf-8?B?RlVCWHFhZ2NWRmZ6L09NaEsyelpzdHRTRXA2djZoY1dWdENUd2xnZVVVenNh?=
 =?utf-8?B?aWtrOHZuQ24rSHhvUlFSb1BnRHZXVVRGTnF1SUxvaXpGUDVrcGlLZEVwZ3lr?=
 =?utf-8?B?eS96bG1ncjdNYXNmcEhCRG9zUTFNUEhKdm9uY0QzQ3NZekRsUll0c0NTeU5y?=
 =?utf-8?B?YVNIeGxZeElNLzVDNmNCeHFUWmU2OGZ3L2RnODcxM0s3SUZvNW1HRnJ5SzRl?=
 =?utf-8?B?QkpLMXNDQmdjR1E0bUtzRmlCcCtlMUxnOUZHbHdxeHhkQ0EwWnBMV2kxK3l2?=
 =?utf-8?B?NDVubTFmRzZsOG1yTGE5NGpoT1ZHWWhtYyt1WjhJZVAwREptcHp4WEVzNHk5?=
 =?utf-8?B?a3B2NzBnTWtpY1ZYMkh5eTkveGI5RDd1eWcwRkI2TEtsYkhueEw0cWpZVU9F?=
 =?utf-8?B?QjBSaVhWOXJwdjRreVB6Y2hBN1VLZ3o5TDQ1eWVBZVNZam1DS3RrMEd6VnNj?=
 =?utf-8?B?Rnd0ZGdFZjNnZGpQUm1veFlFK2IwS1RHeU5YOVFtRlA2ZEoydDRsNnVEb09T?=
 =?utf-8?B?MkZlbjZ4dkhYMk8rM3c5L0xUcnNFa1NpUjBvK3NtRHp2anZBeWRQazdTVkVm?=
 =?utf-8?B?Tjd1bjV2aFZqZ2ZwTFVFa3VNWURIL0k5UnErMWZXT1ZpdUE9PQ==?=
x-microsoft-antispam-prvs: <SN6PR13MB24789AF7205201CBCA04D2A8B87D0@SN6PR13MB2478.namprd13.prod.outlook.com>
x-forefront-prvs: 0954EE4910
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39830400003)(136003)(376002)(346002)(366004)(199004)(189003)(478600001)(8936002)(102836004)(118296001)(6506007)(8676002)(2501003)(81156014)(81166006)(76176011)(316002)(7736002)(54906003)(6916009)(1730700003)(305945005)(6512007)(6486002)(53936002)(256004)(6436002)(14454004)(86362001)(5640700003)(14444005)(486006)(97736004)(476003)(68736007)(446003)(2616005)(11346002)(105586002)(4744005)(5660300002)(66066001)(71190400001)(71200400001)(4326008)(229853002)(26005)(6116002)(99286004)(2171002)(2906002)(6246003)(3846002)(186003)(25786009)(93886005)(36756003)(2351001)(106356001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2478;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: U1PHHvoSkecFmKsF1LkOBdYXU4/p0NyWJEKrXPSGNe/JdkmHz6dHTTqt0elGs8DQBfDu4y53r2OjayikqWv7GYL9dYNxKYz+buOT8634GBd9FGGOeZuxLqzZXfIfPCCyAjr8M+ywBWwyimb5ivl31FXRLp/MNZZ0m2OEdUNIhZ6HLVX5i7eWGF0mwU7ehjrvWqXJygWFDqbHlY35h/dUAdWC43x08+j5tYMdZS7+IEh6CaOtXLxPWFq2KJLE/uO9YmGeElDILCxXj4fLwVwKk3WoOIXJ0ReFbiANHjxwuyRFaxLSdvGMqm1nMbO3U5Xgrf/kA/5x9grLl3jl5p+JYcWGD0AKXbSjS663ctd+vuFL+Zv5tFSAiD3ExZZXp8OmazHUInz149odWBva2Rxlb/dYRQj/qfm4pql87C0nu+I=
Content-Type: text/plain; charset="utf-8"
Content-ID: <94A4B1B543435940ABB1A59CB54EF8A7@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0e5ca99e-032f-41e2-6303-08d69752e06d
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2019 16:45:52.6470
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2478
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAyLTIwIGF0IDEwOjI1IC0wNjAwLCBKYXNvbiBMIFRpYmJpdHRzIElJSSB3
cm90ZToNCj4gPiA+ID4gPiA+ICJUTSIgPT0gVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QGhhbW1l
cnNwYWNlLmNvbT4gd3JpdGVzOg0KPiANCj4gVE0+IFRoaXMgaXMgbm90IGFuIFJQQyBsYXllciBp
c3N1ZS4gSXQgaXMgYSBTRVFfTUlTT1JERVJFRCBlcnJvciBvbg0KPiBzbG90DQo+IFRNPiAwLiAg
SWYgdGhlIGNsaWVudCBjYW4ndCByZWNvdmVyIHRoZW4gdGhhdCB3aWxsIGhhbmcgeW91ciBORlN2
NC4xDQo+IFRNPiBzZXNzaW9uIGFnYWluc3QgdGhhdCBzZXJ2ZXIuDQo+IA0KPiBUTT4gQXJlIHlv
dSBzdXJlIHRoaXMgaXNuJ3Qgd2hhdCB3YXMgaGFwcGVuaW5nIHByZXZpb3VzbHk/DQo+IA0KPiBJ
J20gc29ycnkgaWYgSSB3YXNuJ3QgY2xlYXIuICBJIGFwcGxpZWQgeW91ciBwYXRjaCBhbmQgaXQg
ZG9lc24ndA0KPiBzZWVtDQo+IHRvIG1ha2UgYW55IGRpZmZlcmVuY2UuICBUaGUgYmVoYXZpb3Ig
YXBwZWFycyB0byBiZSBleGFjdGx5IHdoYXQgd2FzDQo+IGhhcHBlbmluZyBwcmV2aW91c2x5LCB0
aG91Z2ggSSBwb3N0ZWQgdGhlIHRyYWNlIGFnYWluIGp1c3Qgc28gdGhhdA0KPiB0aG9zZQ0KPiB3
aG8ga25vdyBtb3JlIHRoYW4gbWUgY291bGQgdmVyaWZ5IHRoYXQuDQo+IA0KDQpUaGF0J3Mgd2h5
IEkgc2VudCB5b3UgYSBwYXRjaCB0aGF0IGFkZHJlc3NlcyB0aGUgU0VRX01JU09SREVSRUQgaXNz
dWUuDQpBcmUgeW91IHNheWluZyB0aGF0IGZhaWxlZCB0b28/DQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWts
ZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
