Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B917C282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 18:10:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0665D21855
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 18:10:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="X8CavBJP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726002AbfAWSKL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 13:10:11 -0500
Received: from mail-eopbgr750120.outbound.protection.outlook.com ([40.107.75.120]:48818
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725996AbfAWSKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Jan 2019 13:10:11 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nce2vg7uNy35qyfBlpFoZRyC5IyiZVHsI0CyV388+00=;
 b=X8CavBJPTdqbGMdy5kPjxEi1bFDKORiV/dmu9UHxli+UTRv6NkK/TV9uS7F/JwgaWtOAFYqQyX/Zo0x01uk9VMKjvCFAHeW30Wa22N1nwjXG7i7eDl2UEVWhZJrmC/HFaK7IC46UdFDZpniB6DxTUWp5S3KJ1wqcdX8AIROu5l0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2319.namprd13.prod.outlook.com (52.135.94.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1537.16; Wed, 23 Jan 2019 18:10:03 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1558.016; Wed, 23 Jan 2019
 18:10:03 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "lsf-pc@lists.linux-foundation.org" 
        <lsf-pc@lists.linux-foundation.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: [LSF/MM TOPIC] Containers and distributed filesystems
Thread-Topic: [LSF/MM TOPIC] Containers and distributed filesystems
Thread-Index: AQHUs0bc7R3p2lKYh0W36SUNp6bBfw==
Date:   Wed, 23 Jan 2019 18:10:03 +0000
Message-ID: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2319;6:d+mr9m146X/Rd0cWdSpEn+G58EoBdVZ4i9MNhlZNTLkC8ia94zvR3qmgc1Q++xSa/oUxOQBHIUj/otEPBm6+Zkp1mqRM65q3JzANGqS79TEnyH2tyKgjj6k+w2hqwF4ldy3WhsW0+jyvJR3paWuGZebPEP7LQxofl9qjA1gxlMbyvje/++mhix0Ej8Lu2E7pYRUVNnpY2X2/TuUL0m7ICG8upcRY3J1ccaN2HiOgDtC/yySQX2a1+1cGUAUs+GRbxRdtYtA8qoEZYMm/07fygS2pzqXv8Qgj1SclnPEwNl+lM7ERbMFbzdclaBpYDKgLmp8L245m/KvfhcOXhO4qUXg76bHXz6rPFG0f0PgsVKzc7yIk48nBFJ77k0aACsz8TsSFu7NdKXaWYwyxu2zaZleGgOEkgZrX7hAKhLZyZnTBH4J4nZB/XzP/QFNXdjgllSqv4SFBtl03Bg8Qf2czUw==;5:pIrPVvF9CgVvIB1fNJU0bDLtUFO4Yi4jqIGgm4f+jxRbQnvYW9fLmp/xcQCAqDNFy52rSvWMU7r+2G+5pSvzQf2HMEehCJ1KnTGEYTb+D6XtlmzUAeb4nvm+SfgDuOFCvs/dC5KZZDixR3m8aOpaUJ73LxR0hehs6efn06ijbvdA+DdFF4Z9pKwhLmAsJlNiLfu0pioqQkXca6r3jeiZFQ==;7:HeM0ja2jivvnlsWkTVRUOXsHErzdyUcY5GSyWP9DJMkZicS1IaTFet8Ne40gyoNy5p0mEVFXifmTvLose+vTibTtfYMXpE5fEc5OxT0SC4lT7ZIQ4PLv7y+imea8FW+U6LgybAfUssy3yjziGZoqxw==
x-ms-office365-filtering-correlation-id: 24869764-1760-4075-b94c-08d6815dff6b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2319;
x-ms-traffictypediagnostic: SN6PR13MB2319:
x-microsoft-antispam-prvs: <SN6PR13MB2319C61EF11397D1FA2801BFB8990@SN6PR13MB2319.namprd13.prod.outlook.com>
x-forefront-prvs: 0926B0E013
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39840400004)(346002)(376002)(396003)(366004)(136003)(199004)(189003)(2906002)(6436002)(54906003)(36756003)(5640700003)(106356001)(561944003)(105586002)(118296001)(25786009)(53936002)(6116002)(3846002)(486006)(2351001)(478600001)(68736007)(6916009)(86362001)(256004)(4326008)(14454004)(6512007)(316002)(97736004)(6506007)(7736002)(102836004)(305945005)(66066001)(81156014)(71190400001)(8936002)(71200400001)(81166006)(8676002)(2501003)(99286004)(476003)(26005)(6346003)(2616005)(186003)(6486002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2319;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: N46Rfb6u42yxzrGyb1LvHuOEhN+we9VbGHip9aRcEVMpPjj9W6y7hUzOaZhazU8kMjF+hbVIYACEtwtmreD+nbRPeoVP97jKEVJzaD95qtvLpPbHy1B1MCcFYoAxBVJUpTsus9D5xyEE+VwjRN5NXFEIf2BBqW3jY20XNWzvSlEw32jrwoxIP0O2uQvaX2sQBGX2STbspz9ehnHl1wHm+B3RBz4uSpv8Qiwqb3AUKdRl+oWhUxZsji4DVXGmqsujkUk3JDuSASHZJjNgiYeEZN2njHOhtZKOC0VJ6NsKXVu4L9myeaR/1klhNMuviao9JZFB4dit+S6jscqiPsmbbK3qbKB6m8sGTBtrwtF2Qo024Ies96voS95L330I2UA4VXPrHCB9SEQmeqEKyCkp1B9uuNantb/+iAK4XafXoJE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F119462C2C1A5B4EB377232766CA5340@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 24869764-1760-4075-b94c-08d6815dff6b
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jan 2019 18:10:03.5224
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2319
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGksDQoNCkknZCBsaWtlIHRvIHByb3Bvc2UgYW4gTFNGL01NIGRpc2N1c3Npb24gYXJvdW5kIHRo
ZSB0b3BpYyBvZiBjb250YWluZXJzDQphbmQgZGlzdHJpYnV0ZWQgZmlsZXN5c3RlbXMuDQoNClRo
ZSBiYWNrZ3JvdW5kIGlzIHRoYXQgd2UgaGF2ZSBhIG51bWJlciBvZiBkZWNpc2lvbnMgdG8gbWFr
ZSBhcm91bmQNCmRlYWxpbmcgd2l0aCBuYW1lc3BhY2VzIHdoZW4gdGhlIGZpbGVzeXN0ZW0gaXMg
ZGlzdHJpYnV0ZWQuDQoNCk9uIHRoZSBvbmUgaGFuZCwgdGhlcmUgaXMgdGhlIGlzc3VlIG9mIHdo
aWNoIHVzZXIgbmFtZXNwYWNlIHdlIHNob3VsZA0KYmUgdXNpbmcgd2hlbiBwdXR0aW5nIHVpZHMv
Z2lkcyBvbiB0aGUgd2lyZSwgb3Igd2hlbiB0cmFuc2xhdGluZyBpbnRvDQphbHRlcm5hdGl2ZSBp
ZGVudGl0aWVzICh1c2VyL2dyb3VwIG5hbWUsIGNpZnMgU0lEcywuLi4pLiBUaGVyZSBhcmUgdHdv
DQptYWluIGNvbXBldGluZyBwcm9wb3NhbHM6IHRoZSBmaXJzdCBwcm9wb3NhbCBpcyB0byBzZWxl
Y3QgdGhlIHVzZXINCm5hbWVzcGFjZSBvZiB0aGUgcHJvY2VzcyB0aGF0IG1vdW50ZWQgdGhlIGRp
c3RyaWJ1dGVkIGZpbGVzeXN0ZW0uIFRoZQ0Kc2Vjb25kIHByb3Bvc2FsIGlzIHRvIChjb250aW51
ZSB0bykgdXNlIHRoZSB1c2VyIG5hbWVzcGFjZSBwb2ludGVkIHRvDQpieSBpbml0X25zcHJveHku
IEl0IHNlZW1zIHRoYXQgd2hpY2hldmVyIGNob2ljZSB3ZSBtYWtlLCB3ZSBwcm9iYWJseQ0Kd2Fu
dCB0byBlbnN1cmUgdGhhdCBhbGwgdGhlIG1ham9yIGRpc3RyaWJ1dGVkIGZpbGVzeXN0ZW1zIChB
RlMsIENJRlMsDQpORlMpIGhhdmUgY29uc2lzdGVudCBoYW5kbGluZyBvZiB0aGVzZSBzaXR1YXRp
b25zLg0KDQpBbm90aGVyIGlzc3VlIGFyaXNlcyBhcm91bmQgdGhlIHF1ZXN0aW9uIG9mIGlkZW50
aWZ5aW5nIGNvbnRhaW5lcnMgd2hlbg0KdGhleSBhcmUgbWlncmF0ZWQuIEF0IGxlYXN0IHRoZSBO
RlN2NCBjbGllbnQgbmVlZHMgdG8gYmUgYWJsZSB0byBzZW5kIGENCnVuaXF1ZSBpZGVudGlmaWVy
IHRoYXQgaXMgcHJlc2VydmVkIGFjcm9zcyBjb250YWluZXIgbWlncmF0aW9uLiBUaGUNCnV0c19u
YW1lc3BhY2UgaXMgdHlwaWNhbGx5IGluc3VmZmljaWVudCBmb3IgdGhpcyBwdXJwb3NlLCBzaW5j
ZSBtb3N0DQpjb250YWluZXJzIGRvbid0IGJvdGhlciB0byBzZXQgYSB1bmlxdWUgaG9zdG5hbWUu
DQoNCkZpbmFsbHksIHRoZXJlIGlzIGFuIGlzc3VlIHRoYXQgbWF5IGJlIHVuaXF1ZSB0byBORlMg
KGluIHdoaWNoIGNhc2UgSSdkDQpiZSBoYXBweSB0byBzZWUgaXQgYXMgYSBoYWxsd2F5IGRpc2N1
c3Npb24gb3IgYSBCb0Ygc2Vzc2lvbikgYXJvdW5kDQpwcmVzZXJ2aW5nIGZpbGUgc3RhdGUgYWNy
b3NzIGNvbnRhaW5lciBtaWdyYXRpb25zLg0KDQpDaGVlcnMNCiAgVHJvbmQNCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRy
b25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
