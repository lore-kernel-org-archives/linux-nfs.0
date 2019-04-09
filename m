Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56747C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:55:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1F47E2133D
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:55:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="NEi9xX3z"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726471AbfDIQzv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 12:55:51 -0400
Received: from mail-eopbgr740118.outbound.protection.outlook.com ([40.107.74.118]:9872
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726372AbfDIQzv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 12:55:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=E2cUhCm23qRD1aYjvdD1+BJDluQKcgD47q7UsH37E+k=;
 b=NEi9xX3zf+0/B9HCPi9yT2CRnN/YBYrJxd5T3Vbb+YLxAOVDatrRGvRfjhbEZ6r/XFC1oUIsqiOE6Qdt4i3CbB7aAQIhpgVI3CepLfw3ErsLj2MzxCquKGGSdvAEMg0rEB34bcKJDWZGdmBSxU5SzlbU3Ai8trTjLZCOPDFt2ng=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2541.namprd13.prod.outlook.com (52.135.95.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.8; Tue, 9 Apr 2019 16:55:47 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Tue, 9 Apr 2019
 16:55:47 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "daniel@zonque.org" <daniel@zonque.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Topic: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Thread-Index: AQHU7i3XWMBYs7+7DEGG17GL2cVEYaYym9UAgAFpbICAAAiIgA==
Date:   Tue, 9 Apr 2019 16:55:47 +0000
Message-ID: <7bdd83d7c2442d8096612ad3f821af556dd96015.camel@hammerspace.com>
References: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
         <ce6d2388a9214f95cc38de5ec225cba26cf63b0d.camel@hammerspace.com>
         <4f4bb4a9-f752-f9f4-41cd-5c41d6191308@zonque.org>
In-Reply-To: <4f4bb4a9-f752-f9f4-41cd-5c41d6191308@zonque.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5fbf2e87-2761-4deb-a882-08d6bd0c3701
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2541;
x-ms-traffictypediagnostic: SN6PR13MB2541:
x-microsoft-antispam-prvs: <SN6PR13MB25412C1953C9A50ECEA2193EB82D0@SN6PR13MB2541.namprd13.prod.outlook.com>
x-forefront-prvs: 000227DA0C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(136003)(39830400003)(376002)(366004)(189003)(199004)(4326008)(316002)(68736007)(305945005)(25786009)(110136005)(8676002)(5660300002)(256004)(53936002)(6436002)(97736004)(7736002)(6486002)(2906002)(105586002)(6512007)(229853002)(36756003)(66066001)(6246003)(118296001)(476003)(26005)(486006)(71190400001)(53546011)(446003)(2201001)(186003)(14454004)(71200400001)(11346002)(102836004)(8936002)(86362001)(2616005)(478600001)(99286004)(76176011)(81166006)(81156014)(6116002)(6506007)(3846002)(106356001)(2501003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2541;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: f6BovXALnDApYuSH1xLNp0RbUtSXt1F2e+67ZD/FZav+dwQict1sXMLPiQBONHNbKqyKbWhJjOqbh/0MMJl5OoNfE5A0IZwLh3OTmDc8uObq1HvyI1uxjF6reu0nR3ox8IYw3PvWLB9T9qcI35OjRgVIK4/WvfWGewKXJgEmpaT/QzfqNE9mirK/ZJEUC4DPFJLK1RRjbLyORnq2iXk1P97JXWgoSkfkjvIXeynMBD0cCAVjJzTTdwjEibUoNv8uNxNY7CdsSpD3y4O3jnndX0VgMiS0xPDKKlrniPZ9a2oJyWDKO278lMOfzIuZ4ki2OvLIZ8n56lXjUL750n/01f/FYpdZCUPFn5iUcjCqgSq0YvmKG/QYLLv/zR+GxowSJohvsm9V+m3dl3CCj7KdxHFL0aNHpbfNf0YQWvre0jY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <AFE9597EC239D64B979D4C5D921DF074@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5fbf2e87-2761-4deb-a882-08d6bd0c3701
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Apr 2019 16:55:47.7945
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2541
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTA0LTA5IGF0IDE4OjI1ICswMjAwLCBEYW5pZWwgTWFjayB3cm90ZToNCj4g
T24gOC80LzIwMTkgODo1MSBQTSwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIE1vbiwg
MjAxOS0wNC0wOCBhdCAxOTowMSArMDIwMCwgRGFuaWVsIE1hY2sgd3JvdGU6DQo+ID4gPiBIaSwN
Cj4gPiA+IA0KPiA+ID4gSSdtIHNlZWluZyB0aGUgT29wcyBiZWxvdyB3aGVuIHRyeWluZyB0byBi
b290IDUuMS4wLXJjNCBvbiBhbiBBUk0NCj4gPiA+IFBYQTN4eA0KPiA+ID4gcGxhdGZvcm0uIHY1
LjAgZGlkIG5vdCBzaG93IHRoaXMgZWZmZWN0IHdpdGggdGhlIHNhbWUgY21kbGluZS4NCj4gPiA+
IA0KPiA+IFBsZWFzZSBkbyBiaXNlY3QgaWYgdGhhdCBpcyBhdCBhbGwgcHJhY3RpY2FsLiBJJ20g
aGF2aW5nIHRyb3VibGUNCj4gPiBpbnRlcnByZXRpbmcgdGhpcyBPb3BzLg0KPiANCj4gSGVyZSB5
b3UgZ286DQo+IA0KPiAwMDlhODJmNjQzNzQ5MGMyNjI1ODRkNjVhMTQwOTRhODE4YmNiNzQ3IGlz
IHRoZSBmaXJzdCBiYWQgY29tbWl0DQo+IGNvbW1pdCAwMDlhODJmNjQzNzQ5MGMyNjI1ODRkNjVh
MTQwOTRhODE4YmNiNzQ3DQo+IEF1dGhvcjogVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1
c3RAaGFtbWVyc3BhY2UuY29tPg0KPiBEYXRlOiAgIFNhdCBNYXIgOSAxMjowNzoxNyAyMDE5IC0w
NTAwDQo+IA0KPiAgICAgU1VOUlBDOiBNaWNyby1vcHRpbWlzZSB3aGVuIHRoZSB0YXNrIGlzIGtu
b3duIG5vdCB0byBiZSBzbGVlcGluZw0KPiANCj4gICAgIEluIGNhc2VzIHdoZXJlIHdlIGtub3cg
dGhlIHRhc2sgaXMgbm90IHNsZWVwaW5nLCB0cnkgdG8gb3B0aW1pc2UNCj4gICAgIGF3YXkgdGhl
IGluZGlyZWN0IGNhbGwgdG8gdGFzay0+dGtfYWN0aW9uKCkgYnkgcmVwbGFjaW5nIGl0IHdpdGgN
Cj4gICAgIGEgZGlyZWN0IGNhbGwuDQo+ICAgICBPbmx5IGNoYW5nZSB0YWlsIGNhbGxzLCB0byBh
bGxvdyBnY2MgdG8gcGVyZm9ybSB0YWlsIGNhbGwNCj4gICAgIGVsaW1pbmF0aW9uLg0KDQpBaC4u
LiBJdCBsb29rcyBsaWtlIHdlIGV4cGxpY2l0bHkgdHVybiBvZmYgdGFpbCBjYWxsIG9wdGltaXNh
dGlvbiBpbg0Kc29tZSBBUk0gY29uZmlncywgc28gdGhpcyBtaWdodCBiZSBhIHN0YWNrIG92ZXJm
bG93Lg0KDQpEb2VzIHlvdXIgY29uZmlnIGZpbGUgaGF2ZSBUSFVNQjJfQVZPSURfUl9BUk1fVEhN
X0pVTVAxMSBzZXQ/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoN
Cg0K
