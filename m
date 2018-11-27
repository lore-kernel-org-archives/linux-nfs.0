Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81EEBC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 21:29:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1A83D20989
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 21:29:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="j2da/1kM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A83D20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=netapp.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726299AbeK1I20 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 03:28:26 -0500
Received: from mail-eopbgr730040.outbound.protection.outlook.com ([40.107.73.40]:20000
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726038AbeK1I2Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 03:28:25 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QqEzRJ5E3WEf13b+omcRX3QhNLrYf222y+2vigcfF5A=;
 b=j2da/1kMGFfvknaiof4u+tcVfBbO+5nYO5i40zATaEA998NQliP/5d8jogn2Hx7eHu4/DzjwQwSU187dw9BIOrJk4BttD2eOd1bvgYTRllxES33XlYNi6XwTWf2c78h1kgMCN6889vgRJ/1YdNvbngi+5SFK5R6CpoyKaAITMbw=
Received: from DM5PR06MB3161.namprd06.prod.outlook.com (10.174.240.148) by
 DM5PR06MB2668.namprd06.prod.outlook.com (10.168.199.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1361.15; Tue, 27 Nov 2018 21:29:06 +0000
Received: from DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::d40a:85bd:7b8a:7420]) by DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::d40a:85bd:7b8a:7420%2]) with mapi id 15.20.1361.019; Tue, 27 Nov 2018
 21:29:06 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "thomas.preston@codethink.co.uk" <thomas.preston@codethink.co.uk>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "ts001-upstream@lists.codethink.co.uk" 
        <ts001-upstream@lists.codethink.co.uk>,
        "ben.dooks@codethink.co.uk" <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH 1/1] SUNRPC: allow /proc entries without
 CONFIG_SUNRPC_DEBUG
Thread-Topic: [PATCH 1/1] SUNRPC: allow /proc entries without
 CONFIG_SUNRPC_DEBUG
Thread-Index: AQHUgP3+wOq0LZnRbE2Gt6+cmTOCJ6VkLnaA
Date:   Tue, 27 Nov 2018 21:29:06 +0000
Message-ID: <599fef6feb5a87e5864f5cda35997d46fcfe7e10.camel@netapp.com>
References: <20181120175930.27853-1-thomas.preston@codethink.co.uk>
         <20181120175930.27853-2-thomas.preston@codethink.co.uk>
In-Reply-To: <20181120175930.27853-2-thomas.preston@codethink.co.uk>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.2 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [68.40.188.1]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM5PR06MB2668;6:P3W4kwwLCsgQpPXgjAzZi4WhRb7N8EUigcjKIft0W3BbK1y/wU9v20mrJgTNbnn139SR8VaWBd6Wv1H7N++7n9vfn/slBuaq60uQxnTVHBIpMInNdbKpCViK+X/o+204HGL6WGJLRpTuQc4AntC2Pl9liPuEkveV7Hox9tJlouzEQru7DCcoWFGeUYotz7x4f5cOML16kB8R/ab8ov239A6PukXJGCQXTnoLdKwPqksPmL8DezCQB43mD3ER3+r4r//kjkRL40z3DmbDzckqmZ8PveVVK+GFscg18p0fDdA+ianJfA/mi65del6S9oC8+GwhvDuBY/dI28h6K+lc4SwbwlhV/aC/GdLKZhGjLqzjEG0ylAmZqquLuforMm5C9oeFOBjD/kPkarWmSEhrqrXX8xPxsTJMFlUljsZMDMDaPu9arR9ovsRyRxTWMCzxvD4R1nBw8aJ6HYbRXgrW6g==;5:eVAso+iwez+4hOE67xUlfYrwjbYjd3K+3euEerYEsUZjupDwLrnQ1auxgXpAQYddSm3+s8gLbC4HZ0KUxykivwWAbYticdO7qX8kA+TRR3vKIbVcNciDvmlzOOcbjembZDCUSNgwzFxbVaTXCKSNegu6N+i+0kaAJFMXh5zYY+U=;7:VxcmEEeGVQUy50mNOUlvWfHFU27DTIdhovBSFrpj6Eg9Z8ZEjChroGrdSB1/g0A1PDOrAA2f9jwGHcq1kBVYh8NIlZf2fU5UEqJ+BMZ7Nj5kLuFip/Dq0ELefF547kXK48k1BdS1/H7j8yvkVQbdnQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: b133a221-75b9-4623-f386-08d654af5c64
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM5PR06MB2668;
x-ms-traffictypediagnostic: DM5PR06MB2668:
x-microsoft-antispam-prvs: <DM5PR06MB26684A67F9197E97F6BB646FF8D00@DM5PR06MB2668.namprd06.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(8211001083)(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3231443)(944501410)(52105112)(3002001)(10201501046)(6055026)(148016)(149066)(150057)(6041310)(20161123562045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:DM5PR06MB2668;BCL:0;PCL:0;RULEID:;SRVR:DM5PR06MB2668;
x-forefront-prvs: 086943A159
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(39860400002)(376002)(136003)(346002)(366004)(396003)(189003)(199004)(4326008)(2201001)(53936002)(2906002)(6246003)(6436002)(7736002)(11346002)(6486002)(229853002)(476003)(26005)(58126008)(86362001)(54906003)(110136005)(14454004)(186003)(486006)(71200400001)(71190400001)(2616005)(316002)(478600001)(99286004)(66066001)(6512007)(81156014)(6506007)(102836004)(3846002)(76176011)(6116002)(256004)(2501003)(68736007)(72206003)(25786009)(97736004)(4001150100001)(8676002)(36756003)(81166006)(106356001)(305945005)(8936002)(118296001)(446003)(5660300001)(105586002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR06MB2668;H:DM5PR06MB3161.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 9mkv9MKNJ3sjvQ1NlERHsWKwt7CurQObtj+lw6nr9stJmaO9YJSSSS+qz272LIVaevELPLfwneuabZLLXrnWg7UIUSfCkUcwZbhTNvGAvNiR7nbRg2lbO94PeupT9VOyA3XH4I/5gBtHEBs2uB4X/tfxcolfr139AW8mIeHxUKshOBG9NZ49UbEs+iEdEbubEXtWRR3JUHNTrrjA/bwIvCeEX99moGzLgCMy3YPhGJ6Vaz3WYVs5QKSeYLvmrbnSo5QyVRp1z3fwrmvqVuqx2FMxGwLHBbO9lEe6dYewm8CrCXvirzVdNEH9SQgaTo8LzRXgWQTXGvyoGyBbSS4GdlK37hZ492mYl4nHFOB7k4c=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <09B362A4C8DA58409A2D3ABD15573579@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b133a221-75b9-4623-f386-08d654af5c64
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Nov 2018 21:29:06.4202
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR06MB2668
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgVGhvbWFzLA0KDQpPbiBUdWUsIDIwMTgtMTEtMjAgYXQgMTc6NTkgKzAwMDAsIFRob21hcyBQ
cmVzdG9uIHdyb3RlOg0KPiBGcm9tOiBCZW4gRG9va3MgPGJlbi5kb29rc0Bjb2RldGhpbmsuY28u
dWs+DQo+IA0KPiBJZiB3ZSB3YW50IC9wcm9jL3N5cy9zdW5ycGMgdGhlIGN1cnJlbnQga2VybmVs
IGFsc28gZHJhZ3MNCj4gaW4gb3RoZXIgZGVidWcgZmVhdHVyZXMgd2hpY2ggd2UgZG9uJ3QgcmVh
bGx5IHdhbnQuIEFkZCB0aGUNCj4gb3B0aW9uIGZvciB0aGUgZW50cmllcyBieSBhZGRpbmcgQ09O
RklHX1NVTlJQQ19ERUJVRy4NCj4gDQo+IC9wcm9jL3N5cy9zdW5ycGMvbWF4X3Jlc3Zwb3J0DQo+
IC9wcm9jL3N5cy9zdW5ycGMvbWluX3Jlc3Zwb3J0DQo+IC9wcm9jL3N5cy9zdW5ycGMvbmZzZF9k
ZWJ1Zw0KPiAvcHJvYy9zeXMvc3VucnBjL25mc19kZWJ1Zw0KPiAvcHJvYy9zeXMvc3VucnBjL25s
bV9kZWJ1Zw0KPiAvcHJvYy9zeXMvc3VucnBjL3JwY19kZWJ1Zw0KDQpDYW4gd2UgaGlkZSB0aGUg
bmZzZF9kZWJ1ZywgbmZzX2RlYnVnLCBubG1fZGVidWcsIGFuZCBycGNfZGVidWcgZW50cmllcyB1
bmRlcg0KQ09ORklHX1NVTlJQQ19ERUJVRywgYnV0IHN0aWxsIHNob3cgZXZlcnl0aGluZyBlbHNl
Pw0KDQo+IC9wcm9jL3N5cy9zdW5ycGMvdGNwX2Zpbl90aW1lb3V0DQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBCZW4gRG9va3MgPGJlbi5kb29rc0Bjb2RldGhpbmsuY28udWs+DQo+IFNpZ25lZC1vZmYt
Ynk6IFRob21hcyBQcmVzdG9uIDx0aG9tYXMucHJlc3RvbkBjb2RldGhpbmsuY28udWs+DQo+IC0t
LQ0KPiAgbmV0L3N1bnJwYy9LY29uZmlnICAgIHwgNyArKysrKysrDQo+ICBuZXQvc3VucnBjL3hw
cnRzb2NrLmMgfCA2ICsrKy0tLQ0KPiAgMiBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCsp
LCAzIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvS2NvbmZpZyBi
L25ldC9zdW5ycGMvS2NvbmZpZw0KPiBpbmRleCBhYzA5Y2E4MDMyOTYuLjBlMjNhN2E2Y2NlOCAx
MDA2NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy9LY29uZmlnDQo+ICsrKyBiL25ldC9zdW5ycGMvS2Nv
bmZpZw0KPiBAQCAtNDgsNiArNDgsMTMgQEAgY29uZmlnIFNVTlJQQ19ERUJVRw0KPiAgDQo+ICAJ
ICBJZiB1bnN1cmUsIHNheSBZLg0KPiAgDQo+ICtjb25maWcgU1VOUlBDX1BST0MNCj4gKwlib29s
ICJSUEM6IEVuYWJsZSAvcHJvYy9zeXMvc3VucnBjIGVudHJpZXMiDQo+ICsJZGVwZW5kcyBvbiBT
VU5SUEMgJiYgU1lTQ1RMDQo+ICsJaGVscA0KPiArCSAgRW5hYmxlIC9wcm9jIGVudGlyZXMgZm9y
IHR1bmluZyAvcHJvYy9zeXMvc3VucnBjIGluZm9ybWF0aW9uDQo+ICsJICB3aXRob3V0IGVuYWJs
aW5nIGFsbCB0aGUgZGVidWcgZmVhdHVyZXMgZm9yIHRoZSBTVU5SUEMgc3lzdGVtLg0KDQpJIGRv
bid0IHRoaW5rIHdlIG5lZWQgYSBuZXcgS2NvbmZpZyBvcHRpb24gZm9yIHRoaXMsIGRvIHdlPyAg
TGV0J3MganVzdCBzaG93IHRoZQ0KcHJvYyBlbnRyaWVzIHVuY29uZGl0aW9uYWxseS4NCg0KVGhh
bmtzLA0KQW5uYQ0KDQo+ICsNCj4gIGNvbmZpZyBTVU5SUENfWFBSVF9SRE1BDQo+ICAJdHJpc3Rh
dGUgIlJQQy1vdmVyLVJETUEgdHJhbnNwb3J0Ig0KPiAgCWRlcGVuZHMgb24gU1VOUlBDICYmIElO
RklOSUJBTkQgJiYgSU5GSU5JQkFORF9BRERSX1RSQU5TDQo+IGRpZmYgLS1naXQgYS9uZXQvc3Vu
cnBjL3hwcnRzb2NrLmMgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gaW5kZXggYWU3N2M3MWMx
ZjY0Li43MWI2NDQwMmMwNzAgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMveHBydHNvY2suYw0K
PiArKysgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gQEAgLTY4LDcgKzY4LDcgQEAgc3RhdGlj
IHVuc2lnbmVkIGludCB4cHJ0X21heF90Y3Bfc2xvdF90YWJsZV9lbnRyaWVzID0NCj4gUlBDX01B
WF9TTE9UX1RBQkxFOw0KPiAgc3RhdGljIHVuc2lnbmVkIGludCB4cHJ0X21pbl9yZXN2cG9ydCA9
IFJQQ19ERUZfTUlOX1JFU1ZQT1JUOw0KPiAgc3RhdGljIHVuc2lnbmVkIGludCB4cHJ0X21heF9y
ZXN2cG9ydCA9IFJQQ19ERUZfTUFYX1JFU1ZQT1JUOw0KPiAgDQo+IC0jaWYgSVNfRU5BQkxFRChD
T05GSUdfU1VOUlBDX0RFQlVHKQ0KPiArI2lmIElTX0VOQUJMRUQoQ09ORklHX1NVTlJQQ19ERUJV
RykgfHwgSVNfRU5BQkxFRChDT05GSUdfU1VOUlBDX1BST0MpDQo+ICANCj4gICNkZWZpbmUgWFNf
VENQX0xJTkdFUl9UTwkoMTVVICogSFopDQo+ICBzdGF0aWMgdW5zaWduZWQgaW50IHhzX3RjcF9m
aW5fdGltZW91dCBfX3JlYWRfbW9zdGx5ID0gWFNfVENQX0xJTkdFUl9UTzsNCj4gQEAgLTMxMTQs
NyArMzExNCw3IEBAIHN0YXRpYyBzdHJ1Y3QgeHBydF9jbGFzcwl4c19iY190Y3BfdHJhbnNwb3J0
ID0gew0KPiAgICovDQo+ICBpbnQgaW5pdF9zb2NrZXRfeHBydCh2b2lkKQ0KPiAgew0KPiAtI2lm
IElTX0VOQUJMRUQoQ09ORklHX1NVTlJQQ19ERUJVRykNCj4gKyNpZiBJU19FTkFCTEVEKENPTkZJ
R19TVU5SUENfREVCVUcpIHx8IElTX0VOQUJMRUQoQ09ORklHX1NVTlJQQ19QUk9DKQ0KPiAgCWlm
ICghc3VucnBjX3RhYmxlX2hlYWRlcikNCj4gIAkJc3VucnBjX3RhYmxlX2hlYWRlciA9IHJlZ2lz
dGVyX3N5c2N0bF90YWJsZShzdW5ycGNfdGFibGUpOw0KPiAgI2VuZGlmDQo+IEBAIC0zMTMzLDcg
KzMxMzMsNyBAQCBpbnQgaW5pdF9zb2NrZXRfeHBydCh2b2lkKQ0KPiAgICovDQo+ICB2b2lkIGNs
ZWFudXBfc29ja2V0X3hwcnQodm9pZCkNCj4gIHsNCj4gLSNpZiBJU19FTkFCTEVEKENPTkZJR19T
VU5SUENfREVCVUcpDQo+ICsjaWYgSVNfRU5BQkxFRChDT05GSUdfU1VOUlBDX0RFQlVHKSB8fCBJ
U19FTkFCTEVEKENPTkZJR19TVU5SUENfUFJPQykNCj4gIAlpZiAoc3VucnBjX3RhYmxlX2hlYWRl
cikgew0KPiAgCQl1bnJlZ2lzdGVyX3N5c2N0bF90YWJsZShzdW5ycGNfdGFibGVfaGVhZGVyKTsN
Cj4gIAkJc3VucnBjX3RhYmxlX2hlYWRlciA9IE5VTEw7DQo=
