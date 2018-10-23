Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0D23C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:09:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6970720665
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:09:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="s83N2hoI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6970720665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728270AbeJXAdp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:33:45 -0400
Received: from mail-bl2nam02on0118.outbound.protection.outlook.com ([104.47.38.118]:6328
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728259AbeJXAdp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Oct 2018 20:33:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NROsU0lCZkCQvxdJd7NXGRu3TMbPc4NLyp18wr8ZJ0A=;
 b=s83N2hoI+V1p1uk7KmFPacukakonjL4IInQN2Q27UVlqBl1ni/9VgKWFN5L8VWMfb1j2qf/jGYwBNeHyl2ThMsMHcvNk2kGD4Hw6I5PWtQlFW6yDP8/cCsiUdUsy3DyEI5hURq7zhPRaBl/mpO1macm/0/sjTHnET+vedKAobsc=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2430.namprd13.prod.outlook.com (52.135.95.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1273.12; Tue, 23 Oct 2018 16:09:40 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1273.014; Tue, 23 Oct 2018
 16:09:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "willy@infradead.org" <willy@infradead.org>,
        "sorenson@redhat.com" <sorenson@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] NFS: change sign of nfs_fh length
Thread-Topic: [PATCH] NFS: change sign of nfs_fh length
Thread-Index: AQHUauX4bhEJTM61gkqya12/tWgrhKUs96mAgAAIIoA=
Date:   Tue, 23 Oct 2018 16:09:39 +0000
Message-ID: <c3ecb78f39487792cf01f868f2ee8521237b3a33.camel@hammerspace.com>
References: <85517ec3-e3d4-1bf3-8eea-cb274face1a7@redhat.com>
         <20181023154031.GF20085@bombadil.infradead.org>
In-Reply-To: <20181023154031.GF20085@bombadil.infradead.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2430;6:UzDAyLVlTG7pgaOOukwqpr8b1xokwPRbaJuTtoi4OPvqnsgBpLQe/7QgLwmPuUsLLt8XRw18J/Ru5Wxhc3NHUSWbZzVw7zk5sOgOroZwCseygXlbZJAXbPuGTPC/PEpxELNI+88xBzTbATAGQE//tUjapXTfxthWl7ZKeKE49O85jfw1+43MqcP4KcasWgkhb3vwD2186KXdJ05UpdKwCQBP35pZyd8ZZ1eIHJE21YoxtSON9BXpRyNYItt48/9mLOkz7VGsT3EA/2uky16WzgpDG+cuzLSbZuArPuwenPR5EOGkIIV9a+9r7tzp0b6SkP1BaQbIW+7Q37sXyzEFMb354iKcmC16L3u6BtxbOBrcQkIQxhLjbjdDKg4BiNy/OvBxZtSGk6/dkdn1ppuWMhaJ4WMoszkF7iJnZSjNU7fzNuRqo5AaTe52wSl3T1s4AjYhgiiY/MyNFyQLWh+lug==;5:0TkYlYA5C+3CW91s37yqAdlTFS/VODXSufPPsXV6DWRFYUCkMUz6GM9bmM/ZvtRTybBgeVekiV1oxo5+lkK0KYgybLkIAuLYuLInCYFXk6GrmNWtu6QW+/2BvmrklZGlfTDHNgHV9etm31rNMbVh1USpgIbY3JDGCc0RIlEamxA=;7:yLq0FXcwOsHNtowLPF18ox5qkStRZODfpk1Pnp4laZAd56Y9H1Pbdob30sheNYqrgdeprtg2t34+c1GWIDH89o13hPIO51fyyILCZWntD7emUxuSsofn06twtpKg7mY+4rwF5aRYKu9z6nO58RRl0g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: a5c87356-5c59-4f7a-a14c-08d63901efcb
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2430;
x-ms-traffictypediagnostic: SN6PR13MB2430:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2430365D55D53E9A96607540B8F50@SN6PR13MB2430.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3002001)(3231355)(944501410)(52105095)(10201501046)(93006095)(93001095)(148016)(149066)(150057)(6041310)(201703131423095)(20161123555045)(201703061421075)(20161123562045)(20161123560045)(20161123558120)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2430;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2430;
x-forefront-prvs: 0834BAF534
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(346002)(136003)(189003)(199004)(14454004)(486006)(2616005)(3846002)(6512007)(6116002)(256004)(476003)(186003)(102836004)(11346002)(86362001)(446003)(6246003)(53936002)(8676002)(2501003)(36756003)(26005)(99286004)(5250100002)(6436002)(118296001)(7736002)(305945005)(2900100001)(6486002)(6506007)(71200400001)(71190400001)(8936002)(97736004)(25786009)(76176011)(4001150100001)(81156014)(81166006)(229853002)(68736007)(5660300001)(508600001)(110136005)(105586002)(54906003)(2906002)(4326008)(66066001)(106356001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2430;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: Fqj/HnSfhqAp6RvAFJQlZMOlIZbvbY9nEEc7P1AmIzCaPp3ISk3RlkE8fKZran5dm7ZtTk6jaAWcOS3hBEpYwVsTX9mBmDyZxee67LbbIKatce+jyEHsSYvU9xaxZxUtauNWWorXvU2yeiHi6+RCXUmUfXFjZt+oAAyM8fdBI0vPRlqyCzf0WjNdkNVSuFZj+UyN4sL6MJEC818uLqp7tWAYUghZJ+Pks4kkWMlXx6vnIN2LpJXPovrx7TWPO+/kJB9uy+6x9Hav6LMI66A2lb4DWQv9wnUfhtiksBC3FP9GNnOIpS26N7h6xHS6Z9j5eDe9DW4Id+Z8FVRjN7dP15ksdjMLJC895Gz+EvZ5YJ4=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <C91A95B7B6DF5E4FAFE236BD5886EE12@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a5c87356-5c59-4f7a-a14c-08d63901efcb
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Oct 2018 16:09:39.8947
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2430
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEwLTIzIGF0IDA4OjQwIC0wNzAwLCBNYXR0aGV3IFdpbGNveCB3cm90ZToN
Cj4gT24gVHVlLCBPY3QgMjMsIDIwMTggYXQgMTA6MzQ6NTdBTSAtMDUwMCwgRnJhbmsgU29yZW5z
b24gd3JvdGU6DQo+ID4gDQo+ID4gVGhlIGZpbGVoYW5kbGUgaGFzIGEgbGVuZ3RoIHdoaWNoIGlz
IGRlZmluZWQgYXMgYSAzMi1iaXQNCj4gPiAidW5zaWduZWQgaW50ZWdlciIuICBDaGFuZ2Ugc2ln
biBvZiB0aGUgbGVuZ3RoIGFwcHJvcHJpYXRlbHkuDQo+ID4gDQo+ID4gU2lnbmVkLW9mZi1ieTog
RnJhbmsgU29yZW5zb24gPHNvcmVuc29uQHJlZGhhdC5jb20+DQo+IA0KPiBJcyB0aGlzIGEgY2xl
YW51cCBvciBkb2VzIGl0IGZpeCBhIHVzZXItdmlzaWJsZSBidWc/DQoNCkl0IGZpeGVzIHRoZSBm
b2xsb3dpbmcgY29tcGFyaXNvbjoNCg0KICAgICAgICAgICAgICAgIGlmIChsZW4gPiBORlM0X0ZI
U0laRSkNCiAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiAtRUlPOw0KDQpidXQgaW4gcHJh
Y3RpY2UsIHRoZSBuZXh0IGxpbmUgc2hvdWxkIGFsd2F5cyBjYXRjaCB0aGUgYnVmZmVyIG92ZXJm
bG93DQp3aGVuIGxlbiBpcyBuZWdhdGl2ZToNCg0KICAgICAgICAgICAgICAgIHAgPSB4ZHJfaW5s
aW5lX2RlY29kZSh4ZHIsIGxlbik7DQogICAgICAgICAgICAgICAgaWYgKHVubGlrZWx5KCFwKSkN
CiAgICAgICAgICAgICAgICAgICAgICAgIGdvdG8gb3V0X292ZXJmbG93Ow0KDQpUaGF0IHNhaWQs
IGl0IGlzIG5pY2UgdG8gYmUgcmVkdW5kYW50LCBzbyBJJ20gaGFwcHkgdG8gdGFrZSB0aGUgcGF0
Y2guDQoNCkZyYW5rLCBpbiAgdGhlIGZ1dHVyZSBjYW4geW91IHBsZWFzZSBDYzogdGhlIG1haW50
YWluZXJzIGRpcmVjdGx5IG9uDQp5b3VyIHBhdGNoZXM/IEkgbWlzc2VkIHRoaXMgb25lIGNvbXBs
ZXRlbHkgYmVjYXVzZSBteSBtYWlsIGZpbHRlcg0KZGlyZWN0ZWQgaXQgdG8gbXkgJ2xpbnV4LWZz
ZGV2ZWwnIGluYm94IHJhdGhlciB0aGFuICdsaW51eC1uZnMnLi4uDQoNClRoYW5rcywNCiAgVHJv
bmQNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
