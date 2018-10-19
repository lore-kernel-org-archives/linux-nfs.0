Return-Path: <SRS0=a6gn=M7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90850ECDE3D
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 16:15:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4259420838
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 16:15:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ryK6T392"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4259420838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727846AbeJTAWW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Oct 2018 20:22:22 -0400
Received: from mail-eopbgr720136.outbound.protection.outlook.com ([40.107.72.136]:9058
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727554AbeJTAWV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 20:22:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ylKqBBPgeDZWWbfGV/LjhcIKbO5e0QvnlPJFyIVmqhI=;
 b=ryK6T392bE/enaaraat/a0Mh89eZfzD1vpq8jIrQLLP/Z9tTUkifuknycCkXwdPG+6NJF5Fo5CUQ+Z5jjLBaypcE/WhiVAiv1ZOaREH3m0c1/QXNqiwZ/mKB7snVDmsAcYQoztvcEKH8yaMMgK4jD04p+kSh5Yn2zUlDIWdsO/k=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2496.namprd13.prod.outlook.com (52.135.95.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1273.12; Fri, 19 Oct 2018 16:14:52 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1273.012; Fri, 19 Oct 2018
 16:14:52 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Thread-Topic: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Thread-Index: AQHUZ8CKbikPa2MOmk2qzQjpj2pWpKUmvjcA
Date:   Fri, 19 Oct 2018 16:14:52 +0000
Message-ID: <ae9364411979f663117def86a1c7df5319b376d1.camel@hammerspace.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
         <20181019152932.32462-3-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152932.32462-3-olga.kornievskaia@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2496;6:9GfbBpyuleSXBXylI48lZw2UPOElgvMKojqWj+cJiEhMI/jyLjxSqZ4fNqaQ82rju5tIB5XRxgXhNloAMLS3E8vekSk6SSIEYTP2pmM9L09vpi5igXc6n6wK5CpJk7LDWv7jNF9LyM1iSsyf9as3okqPQ3idtjGzU8YowHVtzD3xP1TBA9aYIgIzr7W+hTZUt+HQed5f8GJbKueaRGAMsfriFX07hv6L3QlLr4VXwMPJJxiK+VpjV9ZxUVjyz6khopq+flktMDvgM6fnUawYfA3zph6v0mtjI6KyxTc/kpOv6xZe9IJhI6zpwR66UD+KFDgnoXRgS/mJYx/ll/OFbJCBRcp4hLkgAQxii++0CCpGseX701zL3fB11yIoG6tcsGWl1ZhP6KH9gvh0ZKEq8K2nxDx8mbpG+LY5qjDge7EmUAkgIULGyW62vk9laelisCaiFme4SCRmTtK8/OarLQ==;5:Mm12DE4KZNqc2yXslGp0roc5R2LFYc4fzpC5oE3cvcfVU+tHd+1OdeoKqCmXuRSxNeG6D37gd6pt4VLbriEjqs9sCiSuRIh20/kQD87LyILPH/unulLIolvxyal1TcIx2FfH+zATNAdpYz1HmCGQTmci0aRR0yUmSnBcACLgi4A=;7:yFBGM173Ejl9JjAiDBPIcxAEnCEx1bg+JM88fessTASojfRlIDM4mJPJQT2sOnwuONFuqAPE27Rc4ZUXR43H0TWeHE8vsz2htSF7zadpDk5NHww9886uxqJD0XG7a8ZLXCVvStxXae3Tj3RvR7mPdA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: c9e08611-5264-4aa0-f3ad-08d635de0069
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2496;
x-ms-traffictypediagnostic: SN6PR13MB2496:
x-microsoft-antispam-prvs: <SN6PR13MB2496152785158293FA71210FB8F90@SN6PR13MB2496.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(158342451672863);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(3231355)(944501410)(52105095)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123564045)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2496;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2496;
x-forefront-prvs: 0830866D19
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(366004)(376002)(39830400003)(396003)(189003)(199004)(5250100002)(2501003)(3846002)(71200400001)(71190400001)(11346002)(486006)(2616005)(6506007)(106356001)(102836004)(476003)(4001150100001)(97736004)(8936002)(105586002)(5660300001)(316002)(68736007)(25786009)(86362001)(478600001)(110136005)(76176011)(6436002)(186003)(53936002)(118296001)(36756003)(6486002)(54906003)(6512007)(4326008)(26005)(99286004)(8676002)(81166006)(6246003)(81156014)(39060400002)(66066001)(2900100001)(256004)(305945005)(7736002)(446003)(6116002)(14454004)(2906002)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2496;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 3u8N21yGAFAQXjI+3AtrjO3PW+TLu8FoYn66ah30KGlxjLhci1IjtR2SD2QxN9XUd5LoxVyYeZLJZHGgnRqaHKJ6CaPNvTlfoOkwpIcw3j5kH9VQFza7v949A1ioOIsMacnpkhZlJ2exakgNkkKATbNBwLqKjVljAmwDtA5Yi9/qrM4pJDzO8TVASDi3somLpTsHJhxe8q4AsBrBCboAV5mAjGHkG5/K9+Qts0bN7EF2XwzGgx6hMCJOsw82nIXsL+3v//VOmb4jjw1WFll4HUEPmRvzydneCseaameJjEdAUgCVA0d8U1WYHPF+OOPfwhyfREbFWemaXM6y89MgeI69lMfJ/dv0cz5XmrgQYkI=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5FE82B81F29B12439F7C172F15008557@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c9e08611-5264-4aa0-f3ad-08d635de0069
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Oct 2018 16:14:52.4365
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2496
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
Message-ID: <20181019161452.mBfqzeDx8kfikB5G6o21UhG0m_OeFz8zKkxW6SU9-ks@z>

T24gRnJpLCAyMDE4LTEwLTE5IGF0IDExOjI5IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+DQo+IA0KPiBB
bGxvdyBjb3B5X2ZpbGVfcmFuZ2UgdG8gY29weSBiZXR3ZWVuIGRpZmZlcmVudCBzdXBlcmJsb2Nr
cyBidXQgb25seQ0KPiBvZiB0aGUgc2FtZSBmaWxlIHN5c3RlbSB0eXBlcy4gVGhpcyBmZWF0dXJl
IHdhcyBvZiBpbnRlcmVzdCB0byBDSUZTDQo+IGFzIHdlbGwgYXMgTkZTLg0KPiANCj4gVGhpcyBm
ZWF0dXJlIGlzIG5lZWRlZCBieSBORlN2NC4yIHRvIHBlcmZvcm0gZmlsZSBjb3B5IG9wZXJhdGlv
biBvbg0KPiB0aGUgc2FtZSBzZXJ2ZXIgb3IgZmlsZSBjb3B5IGJldHdlZW4gZGlmZmVyZW50IE5G
U3Y0LjIgc2VydmVycy4NCj4gDQo+IElmIGEgZmlsZSBzeXN0ZW0ncyBmaWxlb3BlcmF0aW9ucyBj
b3B5X2ZpbGVfcmFuZ2Ugb3BlcmF0aW9uIHByb2hpYml0cw0KPiBjcm9zcy1kZXZpY2UgY29waWVz
LCBmYWxsIGJhY2sgdG8gZG9fc3BsaWNlX2RpcmVjdC4gVGhpcyB3b3VsZCBiZQ0KPiBuZWVkZWQg
Zm9yIHRoZSBORlMgKGRlc3RpbmF0aW9uKSBzZXJ2ZXIgc2lkZSBpbXBsZW1lbnRhdGlvbiBvZiB0
aGUNCj4gZmlsZSBjb3B5IGFuZCBjdXJyZW50bHkgZm9yIENJRlMuDQo+IA0KPiBCZXNpZGVzIE5G
UywgdGhlcmUgaXMgb25seSAxIGltcGxlbWVudG9yIG9mIHRoZSBjb3B5X2ZpbGVfcmFuZ2UgRlMN
Cj4gb3BlcmF0aW9uIC0tIENJRlMuIENJRlMgYXNzdW1lcyBpbmNvbWluZyBmaWxlIGRlc2NyaXB0
b3JzIGFyZSBib3RoDQo+IENJRlMgYnV0IGl0IHdpbGwgY2hlY2sgaWYgdGhleSBhcmUgY29taW5n
IGZyb20gZGlmZmVyZW50IHNlcnZlcnMgYW5kDQo+IHJldHVybiBlcnJvciBjb2RlIHRvIGZhbGwg
YmFjayB0byBkb19zcGxpY2VfZGlyZWN0Lg0KPiANCj4gTkZTIHdpbGwgYWxsb3cgZm9yIGNvcGll
cyBiZXR3ZWVuIGRpZmZlcmVudCBORlMgc2VydmVycy4NCj4gDQo+IEFkZGluZyB0byB0aGUgdmZz
LnR4dCBkb2N1bWVudGF0aW9uIHRvIGV4cGxpY2l0bHkgd2FybiBhYm91dCBhbGxvd2luZw0KPiBm
b3IgZGlmZmVyZW50IHN1cGVyYmxvY2tzIG9mIHRoZSBzYW1lIGZpbGUgdHlwZSB0byBiZSBwYXNz
ZWQgaW50byB0aGUNCj4gY29weV9maWxlX3JhbmdlIGZvciB0aGUgZnV0dXJlIHVzZXJzIG9mIGNv
cHlfZmlsZV9yYW5nZSBtZXRob2QuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBPbGdhIEtvcm5pZXZz
a2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4gLS0tDQo+ICBEb2N1bWVudGF0aW9uL2ZpbGVzeXN0
ZW1zL3Zmcy50eHQgfCAgNCArKystDQo+ICBmcy9yZWFkX3dyaXRlLmMgICAgICAgICAgICAgICAg
ICAgfCAxMyArKysrKystLS0tLS0tDQo+ICAyIGZpbGVzIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygr
KSwgOCBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9Eb2N1bWVudGF0aW9uL2ZpbGVz
eXN0ZW1zL3Zmcy50eHQNCj4gYi9Eb2N1bWVudGF0aW9uL2ZpbGVzeXN0ZW1zL3Zmcy50eHQNCj4g
aW5kZXggYTZjNmE4YS4uNWU1MjBkZSAxMDA2NDQNCj4gLS0tIGEvRG9jdW1lbnRhdGlvbi9maWxl
c3lzdGVtcy92ZnMudHh0DQo+ICsrKyBiL0RvY3VtZW50YXRpb24vZmlsZXN5c3RlbXMvdmZzLnR4
dA0KPiBAQCAtOTU4LDcgKzk1OCw5IEBAIG90aGVyd2lzZSBub3RlZC4NCj4gIA0KPiAgICBmYWxs
b2NhdGU6IGNhbGxlZCBieSB0aGUgVkZTIHRvIHByZWFsbG9jYXRlIGJsb2NrcyBvciBwdW5jaCBh
DQo+IGhvbGUuDQo+ICANCj4gLSAgY29weV9maWxlX3JhbmdlOiBjYWxsZWQgYnkgdGhlIGNvcHlf
ZmlsZV9yYW5nZSgyKSBzeXN0ZW0gY2FsbC4NCj4gKyAgY29weV9maWxlX3JhbmdlOiBjYWxsZWQg
YnkgY29weV9maWxlX3JhbmdlKDIpIHN5c3RlbSBjYWxsLiBUaGlzDQo+IG1ldGhvZA0KPiArCQkg
ICB3b3JrcyBvbiB0d28gZmlsZSBkZXNjcmlwdG9ycyB0aGF0IG1pZ2h0IHJlc2lkZSBvbg0KPiAr
CQkgICBkaWZmZXJlbnQgc3VwZXJibG9ja3Mgb2YgdGhlIHNhbWUgdHlwZSBvZiBmaWxlDQo+IHN5
c3RlbS4NCj4gIA0KPiAgICBjbG9uZV9maWxlX3JhbmdlOiBjYWxsZWQgYnkgdGhlIGlvY3RsKDIp
IHN5c3RlbSBjYWxsIGZvcg0KPiBGSUNMT05FUkFOR0UgYW5kDQo+ICAJRklDTE9ORSBjb21tYW5k
cy4NCj4gZGlmZiAtLWdpdCBhL2ZzL3JlYWRfd3JpdGUuYyBiL2ZzL3JlYWRfd3JpdGUuYw0KPiBp
bmRleCBjNjA3OTBmLi40NzRlNzQwIDEwMDY0NA0KPiAtLS0gYS9mcy9yZWFkX3dyaXRlLmMNCj4g
KysrIGIvZnMvcmVhZF93cml0ZS5jDQo+IEBAIC0xNTc4LDEwICsxNTc4LDYgQEAgc3NpemVfdCB2
ZnNfY29weV9maWxlX3JhbmdlKHN0cnVjdCBmaWxlDQo+ICpmaWxlX2luLCBsb2ZmX3QgcG9zX2lu
LA0KPiAgCSAgICAoZmlsZV9vdXQtPmZfZmxhZ3MgJiBPX0FQUEVORCkpDQo+ICAJCXJldHVybiAt
RUJBREY7DQo+ICANCj4gLQkvKiB0aGlzIGNvdWxkIGJlIHJlbGF4ZWQgb25jZSBhIG1ldGhvZCBz
dXBwb3J0cyBjcm9zcy1mcyBjb3BpZXMNCj4gKi8NCj4gLQlpZiAoaW5vZGVfaW4tPmlfc2IgIT0g
aW5vZGVfb3V0LT5pX3NiKQ0KPiAtCQlyZXR1cm4gLUVYREVWOw0KPiAtDQo+ICAJaWYgKGxlbiA9
PSAwKQ0KPiAgCQlyZXR1cm4gMDsNCj4gIA0KPiBAQCAtMTU5MSw3ICsxNTg3LDggQEAgc3NpemVf
dCB2ZnNfY29weV9maWxlX3JhbmdlKHN0cnVjdCBmaWxlDQo+ICpmaWxlX2luLCBsb2ZmX3QgcG9z
X2luLA0KPiAgCSAqIFRyeSBjbG9uaW5nIGZpcnN0LCB0aGlzIGlzIHN1cHBvcnRlZCBieSBtb3Jl
IGZpbGUgc3lzdGVtcywNCj4gYW5kDQo+ICAJICogbW9yZSBlZmZpY2llbnQgaWYgYm90aCBjbG9u
ZSBhbmQgY29weSBhcmUgc3VwcG9ydGVkIChlLmcuDQo+IE5GUykuDQo+ICAJICovDQo+IC0JaWYg
KGZpbGVfaW4tPmZfb3AtPmNsb25lX2ZpbGVfcmFuZ2UpIHsNCj4gKwlpZiAoaW5vZGVfaW4tPmlf
c2IgPT0gaW5vZGVfb3V0LT5pX3NiICYmDQo+ICsJCQlmaWxlX2luLT5mX29wLT5jbG9uZV9maWxl
X3JhbmdlKSB7DQo+ICAJCXJldCA9IGZpbGVfaW4tPmZfb3AtPmNsb25lX2ZpbGVfcmFuZ2UoZmls
ZV9pbiwgcG9zX2luLA0KPiAgCQkJCWZpbGVfb3V0LCBwb3Nfb3V0LCBsZW4pOw0KPiAgCQlpZiAo
cmV0ID09IDApIHsNCj4gQEAgLTE2MDAsMTAgKzE1OTcsMTIgQEAgc3NpemVfdCB2ZnNfY29weV9m
aWxlX3JhbmdlKHN0cnVjdCBmaWxlDQo+ICpmaWxlX2luLCBsb2ZmX3QgcG9zX2luLA0KPiAgCQl9
DQo+ICAJfQ0KPiAgDQo+IC0JaWYgKGZpbGVfb3V0LT5mX29wLT5jb3B5X2ZpbGVfcmFuZ2UpIHsN
Cj4gKwlpZiAoZmlsZV9vdXQtPmZfb3AtPmNvcHlfZmlsZV9yYW5nZSAmJg0KPiArCQkJKGZpbGVf
aW4tPmZfb3AtPmNvcHlfZmlsZV9yYW5nZSA9PQ0KPiArCQkJCWZpbGVfb3V0LT5mX29wLT5jb3B5
X2ZpbGVfcmFuZ2UpKSB7DQo+ICAJCXJldCA9IGZpbGVfb3V0LT5mX29wLT5jb3B5X2ZpbGVfcmFu
Z2UoZmlsZV9pbiwgcG9zX2luLA0KPiBmaWxlX291dCwNCj4gIAkJCQkJCSAgICAgIHBvc19vdXQs
IGxlbiwNCj4gZmxhZ3MpOw0KPiAtCQlpZiAocmV0ICE9IC1FT1BOT1RTVVBQKQ0KPiArCQlpZiAo
cmV0ICE9IC1FT1BOT1RTVVBQICYmIHJldCAhPSAtRVhERVYpDQo+ICAJCQlnb3RvIGRvbmU7DQo+
ICAJfQ0KPiAgDQoNCkRpdHRvLiAgVGhpcyBhbHNvIG5lZWRzIGFuIEFDSyBmcm9tIHRoZSBWRlMg
bWFpbnRhaW5lcnMuDQoNCkNjOiBBbCBhbmQgbGludXgtZnNkZXZlbA0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15
a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
