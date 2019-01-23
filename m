Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B106FC282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 20:50:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 42E9021872
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 20:50:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nJRazpw0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726346AbfAWUuq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 15:50:46 -0500
Received: from mail-eopbgr700101.outbound.protection.outlook.com ([40.107.70.101]:13636
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726243AbfAWUuq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Jan 2019 15:50:46 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=TgPpMyWyNB+nLs3+VTZNF7OIdxt11+9yGMZ2AVpyXrk=;
 b=nJRazpw02lz0bW8UMYQsdkeO1h4IQwL6dqShMarjjUJ9ddTUBBJ+sqkjCYAZ7TtkS2KATEXqXK6sgfXoPOM/U7ZiBxKSELSk3FiD5VsUvtDmzQ6+cRgCMTUR/9eZ6tNZti6GTuy7QfpMRc4NMEH9f+9mnoAlEVYA8Hk+CPh8A44=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2462.namprd13.prod.outlook.com (52.135.95.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.9; Wed, 23 Jan 2019 20:50:42 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1558.016; Wed, 23 Jan 2019
 20:50:42 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "James.Bottomley@HansenPartnership.com" 
        <James.Bottomley@HansenPartnership.com>,
        "lsf-pc@lists.linux-foundation.org" 
        <lsf-pc@lists.linux-foundation.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] Containers and distributed filesystems
Thread-Topic: [LSF/MM TOPIC] Containers and distributed filesystems
Thread-Index: AQHUs0bc7R3p2lKYh0W36SUNp6bBf6W9OyyAgAAY3oA=
Date:   Wed, 23 Jan 2019 20:50:41 +0000
Message-ID: <28ba1a0012e84a789d2f402d292935e98266212b.camel@hammerspace.com>
References: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
         <1548271299.2949.41.camel@HansenPartnership.com>
In-Reply-To: <1548271299.2949.41.camel@HansenPartnership.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2462;6:/EUxtSWJba9/9XBX48wVxRDcxBi6jkdYW4TB/ntutzBBQBTx7U+pylG3K1CjxolKgCZHFZc9/OcqKAEvArl2c5yfsRzbMfPONrhXace3btj5m73FdlTaigoFXZOJ8GwssLZB9mSxQEhM5bJdmWt0M5GK8mtGypEtDJhEyIDt3jy65pR5htBkoof7wLzc5XE0++upNiUG7Ao0YNMZzeJdrlk8aBP6e086GQ6JgBuZkPADiVd8bXW2Eko1CwgvytWI6D9GNFiigmM2hFKpq6Nt8Xue+uZ/5wrZid2gkdAQUZjHnhCJP+JT74N5XuVcaIZFYZzYBTj/NMstx6Mq8f4K99X56fZncPM3g6uQE5sk8fe9xlTW2Mcks4LtoAgvzQqTKbsrrCj8HLZxhnno+7AjCUkRb/UMurwexh1dg/nBJZK1Y3Jc6X4H3D7M5kSL5vnW/4I310VI3gmJ1T4aq/5PTA==;5:APB4Nv3+auNfCoHJ7jjqbPzbf4HuNpbvQdHrwOaIOJu9SgEssFZQpPnUt+7JIRYjpHWDyVdoUG9l4DIEvJ1EL0jFYXoKq1sJ1j3v+qt2LOJ8MfGK1IQxWA/+UiL5QkgdraPrGLGx1K/xfWNSZcuRYmd9VzRzNUvbyK4ua+b3Y0NTEPZEKKhEtyAK+9r7561mBxpycunfSXXuKAHCbtLgHg==;7:3Hwfc5PBcbJPeBbmZYpGY7MhacpKDdQcTK+0x7L4OQgPfOTUnjYEGOScKnxL/TviLXwAYDANfRfM1KfGe9YPUpj3J8D0/P1UsLZNkdJ9oy9clce6waBF1q3uslMTmTkMHGBY4fB4LK34NXB5T10NrA==
x-ms-office365-filtering-correlation-id: ddbf193c-7870-42db-81db-08d68174708f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2462;
x-ms-traffictypediagnostic: SN6PR13MB2462:
x-microsoft-antispam-prvs: <SN6PR13MB2462DA960E8BA3DD4A0B6987B8990@SN6PR13MB2462.namprd13.prod.outlook.com>
x-forefront-prvs: 0926B0E013
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(376002)(346002)(366004)(136003)(39830400003)(189003)(199004)(52314003)(99286004)(4326008)(25786009)(486006)(478600001)(6506007)(76176011)(102836004)(966005)(14454004)(97736004)(71200400001)(71190400001)(6246003)(316002)(105586002)(14444005)(110136005)(54906003)(106356001)(118296001)(256004)(6512007)(36756003)(229853002)(53936002)(2616005)(476003)(446003)(2501003)(2906002)(186003)(26005)(11346002)(6306002)(8936002)(6436002)(8676002)(81166006)(81156014)(6486002)(3846002)(6116002)(305945005)(86362001)(68736007)(66066001)(7736002)(561944003)(60764002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2462;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: u9jW9pgzVohnvcK90Nu4i9OvU+iP6Nfq/B2RwxZtmPzDABuqs82TYnQ4Wexnj9n90KA6VphSRuDGIs1PtWm1jJBtw4hNT+tmiDHSJoj9kMMrQ1ugVg5sNGKlaEtZAvkKUdRXu/64GlWYKYyO6JYxzfqhiKXwXpQixPhyv/Gesa7yAsAvHQu3ZhfvTXz5B6cHF/wsWN9JVfTnFJCxnT8AGSJVIDudbZM3SlvW0FM599u5TAZh02BoZvzDqFQYOAfkwXl0t9vN+UeJHnLUe14vP/sTpdU2c/UWDsx7sa31OSGeiO1xabGFzCY4j80aXqAl4VIcopMVEMOfUbcPTYmVt3+E/lxuUzw03SjcAemCXoNT1L1yICQPTlN8WnxNW31wdXAWnVhTpsewzfwxbL07ecBsBe2BM1878VErELSSkgo=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <7896A226BCC0D3489C86C0D7464AC1CF@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ddbf193c-7870-42db-81db-08d68174708f
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jan 2019 20:50:42.3195
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2462
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAxLTIzIGF0IDExOjIxIC0wODAwLCBKYW1lcyBCb3R0b21sZXkgd3JvdGU6
DQo+IE9uIFdlZCwgMjAxOS0wMS0yMyBhdCAxODoxMCArMDAwMCwgVHJvbmQgTXlrbGVidXN0IHdy
b3RlOg0KPiA+IEhpLA0KPiA+IA0KPiA+IEknZCBsaWtlIHRvIHByb3Bvc2UgYW4gTFNGL01NIGRp
c2N1c3Npb24gYXJvdW5kIHRoZSB0b3BpYyBvZg0KPiA+IGNvbnRhaW5lcnMgYW5kIGRpc3RyaWJ1
dGVkIGZpbGVzeXN0ZW1zLg0KPiA+IA0KPiA+IFRoZSBiYWNrZ3JvdW5kIGlzIHRoYXQgd2UgaGF2
ZSBhIG51bWJlciBvZiBkZWNpc2lvbnMgdG8gbWFrZSBhcm91bmQNCj4gPiBkZWFsaW5nIHdpdGgg
bmFtZXNwYWNlcyB3aGVuIHRoZSBmaWxlc3lzdGVtIGlzIGRpc3RyaWJ1dGVkLg0KPiA+IA0KPiA+
IE9uIHRoZSBvbmUgaGFuZCwgdGhlcmUgaXMgdGhlIGlzc3VlIG9mIHdoaWNoIHVzZXIgbmFtZXNw
YWNlIHdlDQo+ID4gc2hvdWxkDQo+ID4gYmUgdXNpbmcgd2hlbiBwdXR0aW5nIHVpZHMvZ2lkcyBv
biB0aGUgd2lyZSwgb3Igd2hlbiB0cmFuc2xhdGluZw0KPiA+IGludG8NCj4gPiBhbHRlcm5hdGl2
ZSBpZGVudGl0aWVzICh1c2VyL2dyb3VwIG5hbWUsIGNpZnMgU0lEcywuLi4pLiBUaGVyZSBhcmUN
Cj4gPiB0d28gbWFpbiBjb21wZXRpbmcgcHJvcG9zYWxzOiB0aGUgZmlyc3QgcHJvcG9zYWwgaXMg
dG8gc2VsZWN0IHRoZQ0KPiA+IHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzIHRoYXQgbW91
bnRlZCB0aGUgZGlzdHJpYnV0ZWQNCj4gPiBmaWxlc3lzdGVtLiBUaGUgc2Vjb25kIHByb3Bvc2Fs
IGlzIHRvIChjb250aW51ZSB0bykgdXNlIHRoZSB1c2VyDQo+ID4gbmFtZXNwYWNlIHBvaW50ZWQg
dG8gYnkgaW5pdF9uc3Byb3h5LiBJdCBzZWVtcyB0aGF0IHdoaWNoZXZlcg0KPiA+IGNob2ljZQ0K
PiA+IHdlIG1ha2UsIHdlIHByb2JhYmx5IHdhbnQgdG8gZW5zdXJlIHRoYXQgYWxsIHRoZSBtYWpv
ciBkaXN0cmlidXRlZA0KPiA+IGZpbGVzeXN0ZW1zIChBRlMsIENJRlMsIE5GUykgaGF2ZSBjb25z
aXN0ZW50IGhhbmRsaW5nIG9mIHRoZXNlDQo+ID4gc2l0dWF0aW9ucy4NCj4gDQo+IEkgZG9uJ3Qg
dGhpbmsgdGhlcmUncyBtdWNoIGRpc2FncmVlbWVudCBhbW9uZyBjb250YWluZXIgcGVvcGxlOiBt
b3N0DQo+IHdvdWxkIGFncmVlIHRoZSB1aWRzIG9uIHRoZSB3aXJlIHNob3VsZCBtYXRjaCB0aGUg
dWlkcyBpbiB0aGUNCj4gY29udGFpbmVyLiAgSWYgeW91J3JlIHJ1bm5pbmcgeW91ciByZW1vdGUg
ZnMgdmlhIGZ1c2UgaW4gYW4NCj4gdW5wcml2aWxlZ2VkIGNvbnRhaW5lciwgeW91IGhhdmUgbm8g
YWNjZXNzIHRvIHRoZSBrdWlkL2tnaWQgYW55d2F5LA0KPiBzbw0KPiBpdCdzIHRoZSB3YXkgeW91
IGhhdmUgdG8gcnVuLg0KPiANCj4gSSB0aGluayB0aGUgbGF0dGVyIGNvbWVzIGFib3V0IGJlY2F1
c2UgbW9zdCBvZiB0aGUgY29udGFpbmVyDQo+IGltcGxlbWVudGF0aW9ucyBzdGlsbCBoYXZlIGRp
ZmZpY3VsdHkgY29uc3VtaW5nIHRoZSB1c2VyIG5hbWVzcGFjZSwNCj4gc28NCj4gbW9zdCBydW4g
d2l0aG91dCBpdCAod2hlcmUga3VpZCA9IHVpZCkgb3IgbWlzLWltcGxlbWVudCBpdCwgd2hpY2gg
aXMNCj4gd2hlcmUgeW91IG1pZ2h0IGdldCB0aGUgbWlzbWF0Y2guICBJcyB0aGVyZSBhbiBhY3R1
YWwgdXNlIGNhc2Ugd2hlcmUNCj4geW91J2Qgd2FudCB0byBzZWUgdGhlIGt1aWQgYXQgdGhlIHJl
bW90ZSBlbmQsIGJlYXJpbmcgaW4gbWluZCB0aGF0DQo+IHdoZW4NCj4gdXNlciBuYW1lc3BhY2Vz
IGFyZSBwcm9wZXJseSBzZXQgdXAga3VpZCBpcyBvZnRlbiB0aGUgcHJvZHVjdCBvZg0KPiBpbnRl
cm5hbCBzdWJ1aWQgbWFwcGluZy4NCg0KV291bGRuJ3QgdGhlIGFib3ZlIGJhc2ljYWxseSBhbGxv
dyB5b3UgdG8gc3Bvb2Ygcm9vdCBvbiBhbnkgZXhpc3RpbmcNCm1vdW50ZWQgTkZTIGNsaWVudCB1
c2luZyB0aGUgdW5wcml2aWxlZ2VkIGNvbW1hbmQgJ3Vuc2hhcmUgLVUgLXInPw0KDQpFcmljIEJp
ZWRlcm1hbiB3YXMgdGhlIG9uZSBwcm9wb3NpbmcgdGhlICdtYXRjaCB0aGUgbmFtZXNwYWNlIG9m
IHRoZQ0KcHJvY2VzcyB0aGF0IG1vdW50ZWQgdGhlIGZpbGVzeXN0ZW0nIGFwcHJvYWNoLiBNeSBt
YWluIHF1ZXN0aW9ucyBhYm91dA0KdGhhdCBhcHByb2FjaCB3b3VsZCBiZToNCjEpIEFyZSB3ZSBn
dWFyYW50ZWVkIHRvIGFsd2F5cyBoYXZlIGEgbWFwcGluZyBiZXR3ZWVuIGFuIGFyYml0cmFyeQ0K
dWlkL2dpZCBmcm9tIHRoZSB1c2VyIG5hbWVzcGFjZSBpbiB0aGUgY29udGFpbmVyLCB0byB0aGUg
dXNlciBuYW1lc3BhY2UNCm9mIHRoZSBwYXJlbnQgb3JjaGVzdHJhdG9yIHByb2Nlc3MgdGhhdCBz
ZXQgdXAgdGhlIG1vdW50Pw0KMikgSG93IGRvIHdlIHJlY29uY2lsZSB0aGF0IGFwcHJvYWNoIHdp
dGggdGhlIHJlcXVpcmVtZW50IHRoYXQgTkZTdjQgYmUNCmFibGUgdG8gY29udmVydCB1aWRzL2dp
ZHMgaW50byBzdHJpbmdpZmllZCB1c2VyL2dyb3VwIG5hbWVzICh3aGljaCBpcw0KdXN1YWxseSBz
b2x2ZWQgdXNpbmcgYW4gdXBjYWxsIG1lY2hhbmlzbSk/DQoNCg0KPiA+IEFub3RoZXIgaXNzdWUg
YXJpc2VzIGFyb3VuZCB0aGUgcXVlc3Rpb24gb2YgaWRlbnRpZnlpbmcgY29udGFpbmVycw0KPiA+
IHdoZW4gdGhleSBhcmUgbWlncmF0ZWQuIEF0IGxlYXN0IHRoZSBORlN2NCBjbGllbnQgbmVlZHMg
dG8gYmUgYWJsZQ0KPiA+IHRvDQo+ID4gc2VuZCBhIHVuaXF1ZSBpZGVudGlmaWVyIHRoYXQgaXMg
cHJlc2VydmVkIGFjcm9zcyBjb250YWluZXINCj4gPiBtaWdyYXRpb24uIFRoZSB1dHNfbmFtZXNw
YWNlIGlzIHR5cGljYWxseSBpbnN1ZmZpY2llbnQgZm9yIHRoaXMNCj4gPiBwdXJwb3NlLCBzaW5j
ZSBtb3N0IGNvbnRhaW5lcnMgZG9uJ3QgYm90aGVyIHRvIHNldCBhIHVuaXF1ZQ0KPiA+IGhvc3Ru
YW1lLg0KPiANCj4gV2UgZGlkIGhhdmUgYSBkaXNjdXNzaW9uIGluIHBsdW1iZXJzIGFib3V0IHRo
ZSBjb250YWluZXIgSUQsIGJ1dCBJJ20NCj4gbm90IHN1cmUgaXQgcmVhY2hlZCBhIHVzZWZ1bCBj
b25jbHVzaW9uIGZvciB5b3UgKHZpZGVvLCBJJ20gYWZyYWlkKToNCj4gDQo+IGh0dHBzOi8vbGlu
dXhwbHVtYmVyc2NvbmYub3JnL2V2ZW50LzIvY29udHJpYnV0aW9ucy8yMTUvDQoNCkkgaGF2ZSBh
IGNvbmNyZXRlIHByb3Bvc2FsIGZvciBob3cgd2UgY2FuIGRvIHRoaXMgdXNpbmcgJ3VkZXYnLCBh
bmQgSSdtDQpsb29raW5nIGZvciBhIGZvcnVtIGluIHdoaWNoIHRvIGRpc2N1c3MgaXQuDQoNCj4g
PiBGaW5hbGx5LCB0aGVyZSBpcyBhbiBpc3N1ZSB0aGF0IG1heSBiZSB1bmlxdWUgdG8gTkZTIChp
biB3aGljaCBjYXNlDQo+ID4gSSdkIGJlIGhhcHB5IHRvIHNlZSBpdCBhcyBhIGhhbGx3YXkgZGlz
Y3Vzc2lvbiBvciBhIEJvRiBzZXNzaW9uKQ0KPiA+IGFyb3VuZCBwcmVzZXJ2aW5nIGZpbGUgc3Rh
dGUgYWNyb3NzIGNvbnRhaW5lciBtaWdyYXRpb25zLg0KPiANCj4gSWYgYnkgZmlsZSBzdGF0ZSwg
eW91IG1lYW4gdGhlIGludGVybmFsIGtlcm5lbCBzdHJ1Y3QgZmlsZSBzdGF0ZSwNCj4gZG9lc24n
dCBDUklVIGFscmVhZHkgZG8gdGhhdD8gb3IgZG8geW91IG1lYW4gc29tZSBvdGhlciBzdGF0ZT8N
Cg0KSSB0aG91Z2h0IENSSVUgd2FzIHVuYWJsZSB0byBkZWFsIHdpdGggZmlsZSBsb2NraW5nIHN0
YXRlPw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
LCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
