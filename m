Return-Path: <SRS0=v8AN=PI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D60C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 18:59:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6EC2220B1F
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 18:59:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gHibZVeh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726903AbeLaS7s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Dec 2018 13:59:48 -0500
Received: from mail-eopbgr720116.outbound.protection.outlook.com ([40.107.72.116]:64032
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726722AbeLaS7s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Dec 2018 13:59:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ju7d2jqyCxcV4C7znGDwHVRzaunSgFVJ5Ctsy7TFOvg=;
 b=gHibZVeh1icsOVGUCUF67peeS/J1S1iM7Dlf+qBVWbGgKr3l+bwXBZd2ZTU3aDR/W+jBHpuFhhmtAu2Y+3NsDq6gmnGmo3sdWGbgdT3sM5hleJ7liXFWd2r0GtOqSrguP9Vo3cUJwaVN/yxGJLk5hxTIWf5zkptE7GqYOup18UI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2431.namprd13.prod.outlook.com (52.135.95.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.4; Mon, 31 Dec 2018 18:59:43 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Mon, 31 Dec 2018
 18:59:43 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Topic: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Index: AQHUTob5qK09WaTXZkeMo/gY+CHqD6WTldAAgAAwIgCAAAW4AIAF/x2AgAAJ4YCAAAQ7gA==
Date:   Mon, 31 Dec 2018 18:59:43 +0000
Message-ID: <44f05a726ddc1c53ea505e033aad7aa8f4a5f204.camel@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
         <20180917130335.112832-2-trond.myklebust@hammerspace.com>
         <20180917130335.112832-3-trond.myklebust@hammerspace.com>
         <20180917130335.112832-4-trond.myklebust@hammerspace.com>
         <20180917130335.112832-5-trond.myklebust@hammerspace.com>
         <20180917130335.112832-6-trond.myklebust@hammerspace.com>
         <20180917130335.112832-7-trond.myklebust@hammerspace.com>
         <20180917130335.112832-8-trond.myklebust@hammerspace.com>
         <20180917130335.112832-9-trond.myklebust@hammerspace.com>
         <20180917130335.112832-10-trond.myklebust@hammerspace.com>
         <20180917130335.112832-11-trond.myklebust@hammerspace.com>
         <20180917130335.112832-12-trond.myklebust@hammerspace.com>
         <20180917130335.112832-13-trond.myklebust@hammerspace.com>
         <20180917130335.112832-14-trond.myklebust@hammerspace.com>
         <20180917130335.112832-15-trond.myklebust@hammerspace.com>
         <20180917130335.112832-16-trond.myklebust@hammerspace.com>
         <20180917130335.112832-17-trond.myklebust@! hammerspace.com>
         <20180917130335.112832-18-trond.myklebust@hammerspace.com>
         <20180917130335.112832-19-trond.myklebust@hammerspace.com>
         <20180917130335.112832-20-trond.myklebust@hammerspace.com>
         <20180917130335.112832-21-trond.myklebust@hammerspace.com>
         <20180917130335.112832-22-trond.myklebust@hammerspace.com>
         <20180917130335.112832-23-trond.myklebust@hammerspace.com>
         <20180917130335.112832-24-trond.myklebust@hammerspace.com>
         <20180917130335.112832-25-trond.myklebust@hammerspace.com>
         <20180917130335.112832-26-trond.myklebust@hammerspace.com>
         <20180917130335.112832-27-trond.myklebust@hammerspace.com>
         <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com>
         <BC34B04D-4AD5-46FB-8DC6-310BF3FBEBD3@hammerspace.com>
         <4FB643C8-4790-42B9-AF38-622E10F6A1B2@oracle.com>
         <4e46f31cc59315533e477cb667f903731598f7f1.camel@hammerspace.com>
         <3BD5C006-55D6-4D1B-9F3D-48FA65CDE09D@oracle.com>
In-Reply-To: <3BD5C006-55D6-4D1B-9F3D-48FA65CDE09D@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2431;6:/sw2ednctzG67dMxr5xmsK8k7juZRIH3bP+mDZTjgW91Y02PVcTyyBKW+ikp5n4BY6IYJPSNVA6tjdNOMb36CKr8/x2MKHtTwca5vb6ZGsCtcMItYB8O8YxgfAGoM21K6oXI31nCYt+7C/ARVZAcZ/avKnBbFViDV9gLXDfqTQC9tExFAZR99wMLBGIjrS6VuS91Ptz42yrsfyvCnMI3qZeoPTj4laCZ45qSfHR/BRmLnd9+ZrvBjxmuQJC1mrvIvrQJsfoWmEFEx6YWnj7yx2jcPax06CMvSwPQFk5Y52X6a8x1O80cVKck7A6bMg5Stq0HGeo6wJXOBeDRlr7lWiychnS+oNVHtqb7fg38o3sq18OGvFjQFWBJjs1RNnRpTnIqWozslQftb1ZETkAfJCpD45Ts9bearlQEYbcf7ph9tOx01d5utOQMLjioS8gIi8qub/m0mUFcHYEON8WSUw==;5:D2lHJgK4f8vDqFSEwYDJuxthuzVzUeIZ/dAQbEsOnL/05eLxLDXY5Z9ftAXJsTpjw+T1xnl4gTq7NM/zJS7aTpCsubPk3eaQO5XVDDL7owK2f8E+QdXIf9CFNtyebxIkpe0xGBrVW9pnQXq6CkmPY91Yk/tovbS6juutKVuVHnKE/opmVd90sOn+OOem12tQ69ZspkSQSTCTMvi8UCiU4A==;7:ghfCa8+XC0uM5I8PQ3Hdiq0YPV8JSa0HW+aO8UoMhE+mg2i1MuwCxSIHkusZyTpdCt8uP7fVEdugZ8iX1q03NbOTXtZnyWeoSNQ5jyzl2hX+GKAESz1rK6KcPIQ1j4+sAsHhmn0Ccy+aDEfHwhpbOw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 9a60b56d-f369-49c2-d3e1-08d66f521fdd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2431;
x-ms-traffictypediagnostic: SN6PR13MB2431:
x-microsoft-antispam-prvs: <SN6PR13MB24310F5B350A5E8F780FE8AAB8B20@SN6PR13MB2431.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(2401047)(8121501046)(10201501046)(3231475)(944501520)(52105112)(3002001)(93006095)(93001095)(6041310)(20161123560045)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2431;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2431;
x-forefront-prvs: 0903DD1D85
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(136003)(39830400003)(376002)(366004)(189003)(199004)(76176011)(6506007)(99286004)(53546011)(36756003)(97736004)(25786009)(8936002)(81166006)(66066001)(4001150100001)(81156014)(8676002)(6486002)(256004)(6436002)(11346002)(446003)(68736007)(229853002)(2616005)(86362001)(71190400001)(71200400001)(5640700003)(186003)(2501003)(26005)(102836004)(14444005)(476003)(486006)(4326008)(2351001)(6512007)(53936002)(5660300001)(7736002)(6916009)(6246003)(305945005)(106356001)(105586002)(14454004)(316002)(3846002)(478600001)(93886005)(118296001)(6116002)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2431;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: lh4jJJ8MnDAAkA4UiDxyNKJiuJ8HCmLhUsjrX7eDRrgI3Jb/PFsVnMVrijW3uiqZz2OXVjX86OQLV4Bx0dj0wV4/fVBU+lnwo5l+IOJ6UtDDB/zyb9kEnYeNJ3WkgU6xtIm49KXXg/v041CDGh72Cclg9aQpYQQJaAIE5hLiSk4jQfI5LwiH9pDFx6OpS952tjDrDz2O1eJToU3L+j/zAfEZj6QC5za1X6dAjOILN7XgAL7OHNrLEmOXpfSGyGSZyclR/SCXdDvWskj+AL9c1Kko8oLTboBrGLjAHRlERv56w/y9j0R+FJ8qNtuRnG4r
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <FC34CC59A398D145B71DD219672464D3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9a60b56d-f369-49c2-d3e1-08d66f521fdd
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Dec 2018 18:59:43.1042
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2431
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTMxIGF0IDEzOjQ0IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMzEsIDIwMTgsIGF0IDE6MDkgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIFRodSwgMjAxOC0xMi0y
NyBhdCAxNzozNCAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIERlYyAyNywg
MjAxOCwgYXQgNToxNCBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gdHJvbmRteUBoYW1t
ZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+IA0KPiA+ID4g
PiA+IE9uIERlYyAyNywgMjAxOCwgYXQgMjA6MjEsIENodWNrIExldmVyIDwNCj4gPiA+ID4gPiBj
aHVjay5sZXZlckBvcmFjbGUuY29tPg0KPiA+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+IA0KPiA+
ID4gPiA+IEhpIFRyb25kLQ0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IEkndmUgY2hhc2VkIGRvd24g
YSBjb3VwbGUgb2YgcmVtYWluaW5nIHJlZ3Jlc3Npb25zIHdpdGggdGhlDQo+ID4gPiA+ID4gdjQu
MjANCj4gPiA+ID4gPiBORlMgY2xpZW50LA0KPiA+ID4gPiA+IGFuZCB0aGV5IHNlZW0gdG8gYmUg
cm9vdGVkIGluIHRoaXMgY29tbWl0Lg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IFdoZW4gdXNpbmcg
c2VjPWtyYjUsIGtyYjVpLCBvciBrcmI1cCBJIGZvdW5kIHRoYXQgbXVsdGktDQo+ID4gPiA+ID4g
dGhyZWFkZWQNCj4gPiA+ID4gPiB3b3JrbG9hZHMNCj4gPiA+ID4gPiB0cmlnZ2VyIGEgbG90IG9m
IHNlcnZlci1zaWRlIGRpc2Nvbm5lY3RzLiBUaGlzIGlzIHdpdGggVENQDQo+ID4gPiA+ID4gYW5k
DQo+ID4gPiA+ID4gUkRNQSB0cmFuc3BvcnRzLg0KPiA+ID4gPiA+IEFuIGluc3RydW1lbnRlZCBz
ZXJ2ZXIgc2hvd3MgdGhhdCB0aGUgY2xpZW50IGlzIHVuZGVyLXJ1bm5pbmcgDQo+ID4gPiA+ID4g
dGhlDQo+ID4gPiA+ID4gR1NTIHNlcXVlbmNlDQo+ID4gPiA+ID4gbnVtYmVyIHdpbmRvdy4gSSBt
b25pdG9yZWQgdGhlIG9yZGVyIGluIHdoaWNoIEdTUyBzZXF1ZW5jZQ0KPiA+ID4gPiA+IG51bWJl
cnMgYXBwZWFyIG9uDQo+ID4gPiA+ID4gdGhlIHdpcmUsIGFuZCBhZnRlciB0aGlzIGNvbW1pdCwg
dGhlIHNlcXVlbmNlIG51bWJlcnMgYXJlDQo+ID4gPiA+ID4gd2lsZGx5DQo+ID4gPiA+ID4gbWlz
b3JkZXJlZC4NCj4gPiA+ID4gPiBJZiBJIHJldmVydCB0aGUgaHVuayBpbiB4cHJ0X3JlcXVlc3Rf
ZW5xdWV1ZV90cmFuc21pdCwgdGhlDQo+ID4gPiA+ID4gcHJvYmxlbSBnb2VzIGF3YXkuDQo+ID4g
PiA+ID4gDQo+ID4gPiA+ID4gSSBhbHNvIGZvdW5kIHRoYXQgcmV2ZXJ0aW5nIHRoYXQgaHVuayBy
ZXN1bHRzIGluIGEgMy00JQ0KPiA+ID4gPiA+IGltcHJvdmVtZW50IGluIGZpbw0KPiA+ID4gPiA+
IElPUFMgcmF0ZXMsIGFzIHdlbGwgYXMgaW1wcm92ZW1lbnQgaW4gYXZlcmFnZSBhbmQgbWF4aW11
bQ0KPiA+ID4gPiA+IGxhdGVuY3kNCj4gPiA+ID4gPiBhcyByZXBvcnRlZA0KPiA+ID4gPiA+IGJ5
IGZpby4NCj4gPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+IEhtbeKApiBQcm92aWRlZCB0aGUg
c2VxdWVuY2UgbnVtYmVycyBzdGlsbCBsaWUgd2l0aGluIHRoZSB3aW5kb3csDQo+ID4gPiA+IHRo
ZW4gd2h5IHdvdWxkIHRoZSBvcmRlciBtYXR0ZXI/DQo+ID4gPiANCj4gPiA+IFRoZSBtaXNvcmRl
cmluZyBpcyBzbyBiYWQgdGhhdCBvbmUgcmVxdWVzdCBpcyBkZWxheWVkIGxvbmcgZW5vdWdoDQo+
ID4gPiB0bw0KPiA+ID4gZmFsbCBvdXRzaWRlIHRoZSB3aW5kb3cuIFRoZSBuZXcg4oCcbmVlZCBy
ZS1lbmNvZGXigJ0gbG9naWMgZG9lcyBub3QNCj4gPiA+IHRyaWdnZXIuDQo+ID4gPiANCj4gPiAN
Cj4gPiBUaGF0J3Mgd2VpcmQuIEkgY2FuJ3Qgc2VlIGFueXRoaW5nIHdyb25nIHdpdGggbmVlZCBy
ZS1lbmNvZGUgYXQNCj4gPiB0aGlzDQo+ID4gcG9pbnQuDQo+IA0KPiBJIGRvbid0IHRoaW5rIHRo
ZXJlIGlzIGFueXRoaW5nIHdyb25nIHdpdGggaXQsIGl0IGxvb2tzIGxpa2UgaXQncw0KPiBub3Qg
Y2FsbGVkIGluIHRoaXMgY2FzZS4NCg0KU28geW91IGFyZSBzYXlpbmcgdGhhdCB0aGUgY2FsbCB0
byBycGNhdXRoX3htaXRfbmVlZF9yZWVuY29kZSgpIGlzDQp0cmlnZ2VyaW5nIHRoZSBFQkFETVNH
LCBidXQgdGhhdCB0aGlzIGZhaWxzIHRvIGNhdXNlIGEgcmUtZW5jb2RlIG9mIHRoZQ0KbWVzc2Fn
ZT8NCg0KPiANCj4gPiBEbyB0aGUgd2luZG93IHNpemVzIGFncmVlIG9uIHRoZSBjbGllbnQgYW5k
IHRoZSBzZXJ2ZXI/DQo+IA0KPiBZZXMsIGJvdGggYXJlIDEyOC4gSSBhbHNvIHRyaWVkIHdpdGgg
NjQgb24gdGhlIGNsaWVudCBzaWRlIGFuZCAxMjgNCj4gb24gdGhlIHNlcnZlciBzaWRlLiBUaGF0
IHJlZHVjZXMgdGhlIGZyZXF1ZW5jeSBvZiBkaXNjb25uZWN0cywgYnV0DQo+IGRvZXMgbm90IGVs
aW1pbmF0ZSB0aGVtLg0KPiANCj4gSSdtIG5vdCBjbGVhciB3aGF0IHByb2JsZW0gdGhlIGxvZ2lj
IGluIHhwcnRfcmVxdWVzdF9lbnF1ZXVlX3RyYW5zbWl0DQo+IGlzIHRyeWluZyB0byBhZGRyZXNz
LiBJdCBzZWVtcyB0byBtZSB0aGF0IHRoZSBpbml0aWFsLCBzaW1wbGUNCj4gaW1wbGVtZW50YXRp
b24gb2YgdGhpcyBmdW5jdGlvbiBpcyBlbnRpcmVseSBhZGVxdWF0ZS4uPw0KDQpJIGFncmVlIHRo
YXQgdGhlIGZhaXIgcXVldWVpbmcgY29kZSBjb3VsZCByZXN1bHQgaW4gYSByZW9yZGVyaW5nIHRo
YXQNCmNvdWxkIHNjcmV3IHVwIHRoZSBSUENTRUNfR1NTIHNlcXVlbmNpbmcuIEhvd2V2ZXIsIHdl
IGRvIGV4cGVjdCB0aGUNCm5lZWQgcmVlbmNvZGUgc3R1ZmYgdG8gY2F0Y2ggdGhhdC4NCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3Bh
Y2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
