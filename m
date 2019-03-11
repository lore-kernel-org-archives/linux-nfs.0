Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27FACC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:12:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CCA79206BA
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:12:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="AeZMFoeI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726546AbfCKPMN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 11:12:13 -0400
Received: from mail-eopbgr690093.outbound.protection.outlook.com ([40.107.69.93]:35446
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726000AbfCKPMN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 11:12:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2HZAUVhDlhKfXs/KqYYY0l/XrVcckFGX5EsO3lUo/R8=;
 b=AeZMFoeItWT1u15DLCC0p4XG5XLq6/AVl4AUXIonYEPX5jyUMryXXPUJDllbpy47Mru4f4XOIjp5/28Xc8gjrtOrsWPce5REZYKzyppgjZ6KEErJS+e8VUJK9IuHbLDQGHSHEJWzO9O8s3E+bx0D6Q4+cAQs668ugk/eDx9uFW8=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2543.namprd13.prod.outlook.com (52.135.95.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.8; Mon, 11 Mar 2019 15:12:06 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1709.011; Mon, 11 Mar 2019
 15:12:06 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "aglo@umich.edu" <aglo@umich.edu>
CC:     "jiufei.xue@linux.alibaba.com" <jiufei.xue@linux.alibaba.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
Thread-Topic: [bug report] task hang while testing xfstests generic/323
Thread-Index: AQHUz03JX9HUIwfLV060fPzVrzJvGKX1yrYAgABwXICAAD3OgIAASFUAgATbqoCAAAhnAIAA30IAgAChFQCAAUJngIAAZ1oAgAaw2YCAAQ8rAIAAC5QA
Date:   Mon, 11 Mar 2019 15:12:06 +0000
Message-ID: <7824abe2b39fef6c5e1cd9cc53732fc91728871c.camel@hammerspace.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
         <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
         <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
         <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
         <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
         <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
         <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
         <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
         <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
         <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
         <20190306160934.GB3066@fieldses.org>
         <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
         <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
In-Reply-To: <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6eb951d8-99db-425b-cd30-08d6a633eced
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2543;
x-ms-traffictypediagnostic: SN6PR13MB2543:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB25439143A13699FE69FFF17EB8480@SN6PR13MB2543.namprd13.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(396003)(136003)(376002)(39830400003)(199004)(189003)(105586002)(476003)(118296001)(6512007)(446003)(6306002)(7736002)(486006)(11346002)(14444005)(305945005)(71190400001)(256004)(71200400001)(68736007)(6486002)(229853002)(2906002)(54906003)(6436002)(25786009)(3846002)(110136005)(6116002)(2616005)(86362001)(4326008)(102836004)(81156014)(5660300002)(36756003)(2501003)(2171002)(6506007)(93886005)(97736004)(186003)(53936002)(316002)(26005)(76176011)(6246003)(14454004)(8676002)(8936002)(478600001)(966005)(106356001)(99286004)(66066001)(81166006)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2543;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Y39yk5Y7f8bYruHqdJDnxal8s+5c/JMQaeC/awA/e1zH2mpNWTWCw4Ru8k1ILOpNZC90R77ZVuqNWGE+qV6ncspUwi9IPaXz18L99CRksPCCLBx11InLnUD/PzkUA2YxJ4gJxtzS9wEm7L6kUcsb53toti0kGzSchbmLoPh593epk+UjGQtFewMpFZK025GstkcsLbjTLKq4i3pKBKoDtGskM4+FTWJl8/gWwYZjXLJo9vznvPITqLluOGgCeib6eIgsLfBrV9LLSzo50Qmod6pPDpvivbJiIms139zmb5Ux37OMLNFQs4D+z3AEiblRw/P6fNI5EG/gs9ZiGvIHB9Cr88tb3ygptcnbLv/DD6FuBeibeZaKTt+AvztboQm/NEhLlSdsNdH+53YRih/kUhjh3qz6jhB0Ym0jJqVpRUA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <5F9AC601C5B0424AA40B029F15FF6CF5@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6eb951d8-99db-425b-cd30-08d6a633eced
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 15:12:06.7193
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2543
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAzLTExIGF0IDE0OjMwICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IEhpIE9sZ2EsDQo+IA0KPiBPbiBTdW4sIDIwMTktMDMtMTAgYXQgMTg6MjAgLTA0MDAsIE9s
Z2EgS29ybmlldnNrYWlhIHdyb3RlOg0KPiA+IFRoZXJlIGFyZSBhIGJ1bmNoIG9mIGNhc2VzIHdo
ZXJlIG11bHRpcGxlIG9wZXJhdGlvbnMgYXJlIHVzaW5nIHRoZQ0KPiA+IHNhbWUgc2VxaWQgYW5k
IHNsb3QuDQo+ID4gDQo+ID4gRXhhbXBsZSBvZiBzdWNoIHdlaXJkbmVzcyBpcyAobmZzLnNlcWlk
ID09IDB4MDAwMDAyZjQpICYmDQo+ID4gKG5mcy5zbG90aWQNCj4gPiA9PSAwKSBhbmQgdGhlIG9u
ZSBsZWFkaW5nIHRvIHRoZSBoYW5nLg0KPiA+IA0KPiA+IEluIGZyYW1lIDQxNTg3MCwgdGhlcmUg
aXMgYW4gT1BFTiB1c2luZyB0aGF0IHNlcWlkIGFuZCBzbG90IGZvciB0aGUNCj4gPiBmaXJzdCB0
aW1lIChidXQgdGhpcyBzbG90IHdpbGwgYmUgcmUtdXNlZCBhIGJ1bmNoIG9mIHRpbWVzIGJlZm9y
ZQ0KPiA+IGl0DQo+ID4gZ2V0cyBhIHJlcGx5IGluIGZyYW1lIDQxNTkwOCB3aXRoIHRoZSBvcGVu
IHN0YXRlaWQgc2VxPTQwKS4gIChhbHNvDQo+ID4gaW4NCj4gPiB0aGlzIHBhY2tldCB0aGVyZSBp
cyBhbiBleGFtcGxlIG9mIHJldXNlIHNsb3Q9MStzZXFpZD0weDAwMDEyOGY3IGJ5DQo+ID4gYm90
aCBURVNUX1NUQVRFSUQgYW5kIE9QRU4gYnV0IGxldCdzIHNldCB0aGF0IGFzaWRlKS4NCj4gPiAN
Cj4gPiBJbiBmcmFtZSA0MTU4NzQgKGluIHRoZSBzYW1lIHBhY2tldCksIGNsaWVudCBzZW5kcyA1
IG9wZW5zIG9uIHRoZQ0KPiA+IFNBTUUNCj4gPiBzZXFpZCBhbmQgc2xvdCAoYWxsIGhhdmUgZGlz
dGluY3QgeGlkcykuIEluIGEgd2F5cyB0aGF0J3MgZW5kIHVwDQo+ID4gYmVpbmcNCj4gPiBhbHJp
Z2h0IHNpbmNlIG9wZW5zIGFyZSBmb3IgdGhlIHNhbWUgZmlsZSBhbmQgdGh1cyByZXBseSBvdXQg
b2YgdGhlDQo+ID4gY2FjaGUgYW5kIHRoZSByZXBseSBpcyBFUlJfREVMQVkuIEJ1dCBpbiBmcmFt
ZSA0MTU4NzYsIGNsaWVudCBzZW5kcw0KPiA+IGFnYWluIHVzZXMgdGhlIHNhbWUgc2VxaWQgYW5k
IHNsb3QgIGFuZCBpbiB0aGlzIGNhc2UgaXQncyB1c2VkIGJ5DQo+ID4gM29wZW5zIGFuZCBhIHRl
c3Rfc3RhdGVpZC4NCg0KVGhpcyBzaG91bGQgcmVzdWx0IGluIGV4YWN0bHkgMSBidW1wIG9mIHRo
ZSBzdGF0ZWlkIHNlcWlkLg0KDQo+ID4gQ2xpZW50IGluIGFsbCB0aGlzIG1lc3MgbmV2ZXIgcHJv
Y2Vzc2VzIHRoZSBvcGVuIHN0YXRlaWQgc2VxPTQwIGFuZA0KPiA+IGtlZXBzIG9uIHJlc2VuZGlu
ZyBDTE9TRSB3aXRoIHNlcT0zNyAoYWxzbyB0byBub3RlIGNsaWVudCAibWlzc2VkIg0KPiA+IHBy
b2Nlc3Npbmcgc2VxaWQ9MzggYW5kIDM5IGFzIHdlbGwuIDM5IHByb2JhYmx5IGJlY2F1c2UgaXQg
d2FzIGENCj4gPiByZXBseQ0KPiA+IG9uIHRoZSBzYW1lIGtpbmQgb2YgIlJldXNlZCIgc2xvdD0x
IGFuZCBzZXE9MHgwMDAxMjhmNy4gSSBoYXZlbid0DQo+ID4gdHJhY2tlZCAzOCBidXQgaSdtIGFz
c3VtaW5nIGl0J3MgdGhlIHNhbWUpLiBJIGRvbid0IGtub3cgaG93IG1hbnkNCj4gPiB0aW1lcyBi
dXQgYWZ0ZXIgNW1pbnMsIEkgc2VlIGEgVEVTVF9TVEFURUlEIHRoYXQgYWdhaW4gdXNlcyB0aGUN
Cj4gPiBzYW1lDQo+ID4gc2VxaWQrc2xvdCAod2hpY2ggZ2V0cyBhIHJlcGx5IGZyb20gdGhlIGNh
Y2hlIG1hdGNoaW5nIE9QRU4pLiBBbHNvDQo+ID4gb3BlbiArIGNsb3NlIChzdGlsbCB3aXRoIHNl
cT0zNykgb3BlbiBpcyByZXBsaWVkIHRvIGJ1dCBhZnRlciB0aGlzDQo+ID4gY2xpZW50IGdvZXMg
aW50byBhIHNvZnQgbG9ja3VwIGxvZ3MgaGF2ZQ0KPiA+ICJuZnM0X3NjaGVkdWxlX3N0YXRlX21h
bmFnZXI6DQo+ID4ga3RocmVhZF9ydWFuOiAtNCIgb3ZlciBhbmQgb3ZlciBhZ2FpbiAuIHRoZW4g
YSBzb2Z0IGxvY2t1cC4NCj4gPiANCj4gPiBMb29raW5nIGJhY2sgb24gc2xvdCAwLiBuZnMuc2Vx
aWQ9MHgwMDAwMDJmMyB3YXMgdXNlZCBpbg0KPiA+IGZyYW1lPTQxNTg2Ng0KPiA+IGJ5IHRoZSBU
RVNUX1NUQVRFSUQuIFRoaXMgaXMgcmVwbGllZCB0byBpbiBmcmFtZSA0MTU4NzcgKHdpdGggYW4N
Cj4gPiBFUlJfREVMQVkpLiBCdXQgYmVmb3JlIHRoZSBjbGllbnQgZ290IGEgcmVwbHksIGl0IHVz
ZWQgdGhlIHNsb3QgYW5kDQo+ID4gdGhlIHNlcSBieSBmcmFtZSA0MTU4NzQuIFRFU1RfU1RBVEVJ
RCBpcyBhIHN5bmNocm9ub3VzIGFuZA0KPiA+IGludGVycnVwdGlibGUgb3BlcmF0aW9uLiBJJ20g
c3VzcGVjdGluZyB0aGF0IHNvbWVob3cgaXQgd2FzDQo+ID4gaW50ZXJydXB0ZWQgYW5kIHRoYXQn
cyB3aG8gdGhlIHNsb3Qgd2FzIGFibGUgdG8gYmUgcmUtdXNlZCBieSB0aGUNCj4gPiBmcmFtZSA0
MTU4NzQuIEJ1dCBob3cgdGhlIHNldmVyYWwgb3BlbnMgd2VyZSBhYmxlIHRvIGdldCB0aGUgc2Ft
ZQ0KPiA+IHNsb3QNCj4gPiBJIGRvbid0IGtub3cuLg0KPiANCj4gSXMgdGhpcyBzdGlsbCB0cnVl
IHdpdGggdGhlIGN1cnJlbnQgbGludXgtbmV4dD8gSSB3b3VsZCBleHBlY3QgdGhpcw0KPiBwYXRj
aCANCj4gaHR0cDovL2dpdC5saW51eC1uZnMub3JnLz9wPXRyb25kbXkvbGludXgtbmZzLmdpdDth
PWNvbW1pdGRpZmY7aD0zNDUzZDU3MDhiMzNlZmU3NmY0MGVjYTFjMGVkNjA5MjMwOTRiOTcxDQo+
IHRvIGNoYW5nZSB0aGUgTGludXggY2xpZW50IGJlaGF2aW91ciBpbiB0aGUgYWJvdmUgcmVnYXJk
Lg0KPiANCg0KDQpOb3RlIGFsc28gdGhhdCB3aGF0IHlvdSBkZXNjcmliZSB3b3VsZCBhcHBlYXIg
dG8gaW5kaWNhdGUgYSBzZXJpb3VzDQpzZXJ2ZXIgYnVnLiBJZiB0aGUgY2xpZW50IGlzIHJldXNp
bmcgYSBzbG90K3NlcWlkLCB0aGVuIHRoZSBjb3JyZWN0DQpzZXJ2ZXIgYmVoYXZpb3VyIGlzIHRv
IGVpdGhlciByZXR1cm4gb25lIG9mIHRoZSBlcnJvcnMgTkZTNEVSUl9ERUxBWSwNCk5GUzRFUlJf
U0VRX0ZBTFNFX1JFVFJZLCBORlM0RVJSX1JFVFJZX1VOQ0FDSEVEX1JFUCwNCk5GUzRFUlJfU0VR
X01JU09SREVSRUQsIG9yIGVsc2UgaXQgbXVzdCByZXBsYXkgdGhlIGV4YWN0IHNhbWUgcmVwbHkN
CnRoYXQgaXQgaGFkIGNhY2hlZCBmb3IgdGhlIG9yaWdpbmFsIHJlcXVlc3QuDQoNCkl0IGlzIHBy
b3RvY29sIHZpb2xhdGlvbiBmb3IgdGhlIHNlcnZlciB0byBleGVjdXRlIG5ldyByZXF1ZXN0cyBv
biBhDQpzbG90K3NlcWlkIGNvbWJpbmF0aW9uIHRoYXQgaGFzIGFscmVhZHkgYmVlbiB1c2VkLiBG
b3IgdGhhdCByZWFzb24sIGl0DQppcyBhbHNvIGltcG9zc2libGUgZm9yIGEgcmVwbGF5IHRvIGNh
dXNlIGZ1cnRoZXIgc3RhdGUgY2hhbmdlcyBvbiB0aGUNCnNlcnZlcjsgYSByZXBsYXkgbWVhbnMg
dGhhdCB0aGUgc2VydmVyIGJlbHRzIG91dCB0aGUgZXhhY3Qgc2FtZSByZXBseQ0KdGhhdCB3YXMg
YXR0ZW1wdGVkIHNlbnQgZWFybGllciB3aXRoIG5vIGNoYW5nZXMgKHdpdGggc3RhdGVpZHMgdGhh
dA0KbWF0Y2ggYml0IGZvciBiaXQgd2hhdCB3b3VsZCBoYXZlIGJlZW4gc2VudCBlYXJsaWVyKS4N
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFt
bWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
