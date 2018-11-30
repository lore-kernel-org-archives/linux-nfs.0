Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E694DC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 19:31:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8CF0620868
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 19:31:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XbNplrRl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CF0620868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725867AbeLAGmK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 01:42:10 -0500
Received: from mail-eopbgr690116.outbound.protection.outlook.com ([40.107.69.116]:43382
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725790AbeLAGmK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 01:42:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Tenrj9FjKwemfM7UfISpJnoqfhPl0lmfioEk3NFCnl0=;
 b=XbNplrRlwnWQSy/4ajf4wMK+K41qZzSpdxERLc4v0pjPaKzCi8yQ9mqriWx8nifIRyoCbR5d6LxfPTuNymksoM29ENOyNBlfO995JD+DX/+HhPh7j0a0tEGUhk+pDORigsaT1VD7BtMKZDf1rPmOsn3Su/3TlGfeSGIdSkK1Lr8=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2318.namprd13.prod.outlook.com (52.135.94.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.9; Fri, 30 Nov 2018 19:31:45 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 19:31:45 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "cristian.marussi@arm.com" <cristian.marussi@arm.com>
CC:     "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Thread-Topic: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Thread-Index: AQHUTocCwahWu1c0eEqSYU1l+AHxY6VHnxwAgB/3VYCAAAefAIABVbYAgAA10AA=
Date:   Fri, 30 Nov 2018 19:31:44 +0000
Message-ID: <92a750b72255c6a91fd5606668f26b2d492ec43f.camel@hammerspace.com>
References: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
         <20180917130335.112832-33-trond.myklebust@hammerspace.com>
         <20180917130335.112832-34-trond.myklebust@hammerspace.com>
         <20180917130335.112832-35-trond.myklebust@hammerspace.com>
         <20180917130335.112832-36-trond.myklebust@hammerspace.com>
         <20180917130335.112832-37-trond.myklebust@hammerspace.com>
         <20180917130335.112832-38-trond.myklebust@hammerspace.com>
         <20180917130335.112832-39-trond.myklebust@hammerspace.com>
         <20180917130335.112832-40-trond.myklebust@hammerspace.com>
         <20180917130335.112832-41-trond.myklebust@hammerspace.com>
         <20181109111930.idve77thgcnsg5u3@localhost>
         <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
         <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
         <a23d0c18-1030-82f3-a046-41497dc7725b@arm.com>
In-Reply-To: <a23d0c18-1030-82f3-a046-41497dc7725b@arm.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2318;6:CG9x6RHbV4SbqB72q2QFLBaIYBKRdJC8nd5CHpqazsa2efpvst/Z31wl3FBTYNGEBOn1GTOc6nQSR+MXfwsqlzXlV5HyG3zto2akKt6ZiNa4wx+WBuypP5MiWC920ki4Y6/K64kDhOZi1fN4pUi9J9Gliwb8h8fhYjjCz0WG6KkIeWGx7fOuRfZkBc9sHltZnNON1NpdCCKIcx/Howq2mwLFMCPsn/EnmZUnkA7tHOhZnu3qxIgRrsQJltwSXsOvl/0T8YHcKfUu7eJZhllFyvym9asbpq729UCWkDQMk7X36PPFbcdNMZtmGn7eSKamtSB1A5R/GepcOKrpOyoBiuxIjOqt2nbSUZhKdXyoxEIsRfffmWa/FNjVna+bwgJgiBLg2MyUad6tOjszFUN6j0yDZ1ccF2ZARFXD/u18GahaOKH+6OqW+ENMMSEtHqXGN3Gw3EhW4n5/+ZaYpUiOVA==;5:wXzf7dlySryoFoczJAcBICmzlWRAppvC5f7neyJX76zCnM0rJ5xoo+45kdGvP2uR05/CPBMrBNYO53GgCHr037QrYRRB7uGwhHNBxIzuBr8l4sO6MhIGL0phJCGUt9kyOk/Sz2snwmkbNt4AXgl0qxiV1f1HyMEgBIPz/s+ltXQ=;7:cOXriv0JVPKxy6+DTwBOdJFa87Y/DndH5CyZOXVhJsk91m+MGpTmVzwE+Gu/9d8MulTxuoQh6WAGcGRnUzFz9q3TNKZcWFhIau+jiwy3vMPO5Gd4/8+t3gP2tQyge9DtT+yiIerOd+fBc12YPMvc5Q==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 9c99eaa1-9073-45ce-f16f-08d656fa76a0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2318;
x-ms-traffictypediagnostic: SN6PR13MB2318:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2318938512CDD32AC6696842B8D30@SN6PR13MB2318.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3231453)(999002)(944501468)(52105112)(93006095)(93001095)(10201501046)(3002001)(148016)(149066)(150057)(6041310)(20161123560045)(20161123562045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2318;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2318;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(39830400003)(136003)(396003)(189003)(199004)(305945005)(6116002)(3846002)(186003)(316002)(54906003)(53936002)(106356001)(68736007)(66066001)(229853002)(36756003)(97736004)(5640700003)(2501003)(4001150100001)(6512007)(2906002)(6246003)(86362001)(256004)(71190400001)(71200400001)(14444005)(14454004)(93886005)(2616005)(476003)(486006)(25786009)(11346002)(4326008)(105586002)(478600001)(99286004)(76176011)(6436002)(446003)(6916009)(2351001)(5660300001)(8676002)(81156014)(81166006)(26005)(53546011)(6486002)(102836004)(118296001)(7736002)(8936002)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2318;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: gyXMk9gX7LJOMS7bVK8AYJJGaT6+7UFEtdyi1L+jkhErZPqXbteUjRAIg/6DAJpLC7MHT8waLLBQVA1D2Aj9fKLRb1FldPgljClgjmImCEeOA0TyMR48cGP1J44yFBO43j+nAVdV27645pjB9qe4J+GOszy2t1EHPaK0N7ChCpvxg1vfrEMYnoZfncntqhEZxSS0GNebRWRyIjCfxWcfQNkKMkpZ531yXzN0nwwtRbTE54DNsg8H1eSsR0xyZStVXvHRHKxoqOCsdtTJLlluFc6k/cLCGmF7BhdVeSrbrNVihneWViDapBpXVhWruwNiIrf3xeM3FmiVlhPY4n2KlZOGJFZq5f59YI/w9eUrlpo=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5CB6C1B6B03BE54092D89CA71FCEDD72@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9c99eaa1-9073-45ce-f16f-08d656fa76a0
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 19:31:45.0184
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2318
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE2OjE5ICswMDAwLCBDcmlzdGlhbiBNYXJ1c3NpIHdyb3Rl
Og0KPiBIaQ0KPiANCj4gT24gMjkvMTEvMjAxOCAxOTo1NiwgVHJvbmQgTXlrbGVidXN0IHdyb3Rl
Og0KPiA+IE9uIFRodSwgMjAxOC0xMS0yOSBhdCAxOToyOCArMDAwMCwgQ3Jpc3RpYW4gTWFydXNz
aSB3cm90ZToNCj4gPiA+IEhpIFRyb25kLCBDYXRhbGluDQo+IFtzbmlwXQ0KPiA+IFF1ZXN0aW9u
IHRvIHlvdSBib3RoOiB3aGVuIHRoaXMgaGFwcGVucywgZG9lcyAvcHJvYy8qL3N0YWNrIHNob3cN
Cj4gPiBhbnkgb2YNCj4gPiB0aGUgcHJvY2Vzc2VzIGhhbmdpbmcgaW4gdGhlIHNvY2tldCBvciBz
dW5ycGMgY29kZT8gSWYgc28sIGNhbiB5b3UNCj4gPiBwbGVhc2Ugc2VuZCBtZSBleGFtcGxlcyBv
ZiB0aG9zZSBzdGFjayB0cmFjZXMgKGkuZS4gdGhlIGNvbnRlbnRzIG9mDQo+ID4gL3Byb2MvPHBp
ZD4vc3RhY2sgZm9yIHRoZSBwcm9jZXNzZXMgdGhhdCBhcmUgaGFuZ2luZykNCj4gDQo+ICh1c2lu
ZyBhIHJldmVyc2Ugc2hlbGwgc2luY2Ugc3RhcnRpbmcgc3NoIGNhdXNlcyBhIGxvdCBvZiBwYWlu
IGFuZA0KPiB0cmFmZmljKQ0KPiANCj4gTG9va2luZyBhdCBORlMgdHJhZmZpYyBob2xlcygzMC00
MCBzZWNzKSB0byBkZXRlY3QgQ2xpZW50IHNpZGUNCj4gdmFyaW91cyBIQU5HUw0KPiAtLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tDQo+IC0tLS0tLS0tLQ0KPiANCj4gcm9vdEBzcXd0LXVidW50dTovb3B0L2xrcC10ZXN0cyMg
bmMgLWxrIC1lIC9iaW4vYmFzaCAtcyAxOTIuMTY4LjAuMQ0KPiAtcCAxMjM1ICYNCj4gcm9vdEBz
cXd0LXVidW50dTovb3B0L2xrcC10ZXN0cyMgbGtwIHJ1biAuL2RiZW5jaC0xMDAlLnlhbWwNCj4g
DQo+ICQgbmMgMTkyLjE2OC4wLjEgMTIzNQ0KPiANCj4gY2F0IC9wcm9jLzI4MzMvY21kbGluZQ0K
PiBydWJ5L29wdC9sa3AtdGVzdHMvYmluL3J1bi1sb2NhbC4vZGJlbmNoLTEwMCUueWFtbA0KPiAN
Cj4gSEFORyBDTE9TRQ0KPiAtLS0tLS0tLS0tDQo+IGNhdCAvcHJvYy8yODMzL3N0YWNrDQo+IFs8
MD5dIF9fc3dpdGNoX3RvKzB4NmMvMHg5MA0KPiBbPDA+XSBycGNfd2FpdF9iaXRfa2lsbGFibGUr
MHgyYy8weGIwDQo+IFs8MD5dIF9fcnBjX3dhaXRfZm9yX2NvbXBsZXRpb25fdGFzaysweDNjLzB4
NDgNCj4gWzwwPl0gbmZzNF9kb19jbG9zZSsweDFlYy8weDJiMA0KPiBbPDA+XSBfX25mczRfY2xv
c2UrMHgxMzAvMHgxOTgNCj4gWzwwPl0gbmZzNF9jbG9zZV9zeW5jKzB4MzQvMHg0MA0KPiBbPDA+
XSBuZnM0X2Nsb3NlX2NvbnRleHQrMHg0MC8weDUwDQo+IFs8MD5dIF9fcHV0X25mc19vcGVuX2Nv
bnRleHQrMHhhYy8weDExOA0KPiBbPDA+XSBuZnNfZmlsZV9jbGVhcl9vcGVuX2NvbnRleHQrMHgz
OC8weDU4DQo+IFs8MD5dIG5mc19maWxlX3JlbGVhc2UrMHg3Yy8weDkwDQo+IFs8MD5dIF9fZnB1
dCsweDk0LzB4MWMwDQo+IFs8MD5dIF9fX19mcHV0KzB4MjAvMHgzMA0KPiBbPDA+XSB0YXNrX3dv
cmtfcnVuKzB4OTgvMHhiOA0KPiBbPDA+XSBkb19ub3RpZnlfcmVzdW1lKzB4MmQwLzB4MzE4DQo+
IFs8MD5dIHdvcmtfcGVuZGluZysweDgvMHgxMA0KPiBbPDA+XSAweGZmZmZmZmZmZmZmZmZmZmYN
Cj4gDQo+IEhBTkcgUkVBRA0KPiAtLS0tLS0tLS0NCj4gY2F0IC9wcm9jLzI4MzMvc3RhY2sNCj4g
WzwwPl0gX19zd2l0Y2hfdG8rMHg2Yy8weDkwDQo+IFs8MD5dIGlvX3NjaGVkdWxlKzB4MjAvMHg0
MA0KPiBbPDA+XSB3YWl0X29uX3BhZ2VfYml0X2tpbGxhYmxlKzB4MTY0LzB4MjYwDQo+IFs8MD5d
IGdlbmVyaWNfZmlsZV9yZWFkX2l0ZXIrMHgxYzQvMHg4MjANCj4gWzwwPl0gbmZzX2ZpbGVfcmVh
ZCsweGE0LzB4MTA4DQo+IFs8MD5dIF9fdmZzX3JlYWQrMHgxMjAvMHgxNzANCj4gWzwwPl0gdmZz
X3JlYWQrMHg5NC8weDE1MA0KPiBbPDA+XSBrc3lzX3JlYWQrMHg2Yy8weGQ4DQo+IFs8MD5dIF9f
YXJtNjRfc3lzX3JlYWQrMHgyNC8weDMwDQo+IFs8MD5dIGVsMF9zdmNfaGFuZGxlcisweDdjLzB4
MTE4DQo+IFs8MD5dIGVsMF9zdmMrMHg4LzB4Yw0KPiBbPDA+XSAweGZmZmZmZmZmZmZmZmZmZmYN
Cj4gDQo+IA0KPiBIQU5HIFNUQVQNCj4gLS0tLS0tLS0tDQo+IGNhdCAvcHJvYy8yODMzL3N0YWNr
DQo+IFs8MD5dIF9fc3dpdGNoX3RvKzB4NmMvMHg5MA0KPiBbPDA+XSBycGNfd2FpdF9iaXRfa2ls
bGFibGUrMHgyYy8weGIwDQo+IFs8MD5dIF9fcnBjX2V4ZWN1dGUrMHgxY2MvMHg1MjgNCj4gWzww
Pl0gcnBjX2V4ZWN1dGUrMHhlNC8weDFiMA0KPiBbPDA+XSBycGNfcnVuX3Rhc2srMHgxMzAvMHgx
NjgNCj4gWzwwPl0gbmZzNF9jYWxsX3N5bmNfc2VxdWVuY2UrMHg4MC8weGM4DQo+IFs8MD5dIF9u
ZnM0X3Byb2NfZ2V0YXR0cisweGM4LzB4ZjgNCj4gWzwwPl0gbmZzNF9wcm9jX2dldGF0dHIrMHg4
OC8weDFkOA0KPiBbPDA+XSBfX25mc19yZXZhbGlkYXRlX2lub2RlKzB4MWY4LzB4NDY4DQo+IFs8
MD5dIG5mc19nZXRhdHRyKzB4MTRjLzB4NDIwDQo+IFs8MD5dIHZmc19nZXRhdHRyX25vc2VjKzB4
N2MvMHg5OA0KPiBbPDA+XSB2ZnNfZ2V0YXR0cisweDQ4LzB4NTgNCj4gWzwwPl0gdmZzX3N0YXR4
KzB4YjQvMHgxMTgNCj4gWzwwPl0gX19zZV9zeXNfbmV3ZnN0YXRhdCsweDU4LzB4OTgNCj4gWzww
Pl0gX19hcm02NF9zeXNfbmV3ZnN0YXRhdCsweDI0LzB4MzANCj4gWzwwPl0gZWwwX3N2Y19oYW5k
bGVyKzB4N2MvMHgxMTgNCj4gWzwwPl0gZWwwX3N2YysweDgvMHhjDQo+IFs8MD5dIDB4ZmZmZmZm
ZmZmZmZmZmZmZg0KPiANCj4gLi4uLg0KDQpJcyB0aGVyZSBhbnl0aGluZyBlbHNlIGJsb2NrZWQg
aW4gdGhlIFJQQyBsYXllcj8gVGhlIGFib3ZlIGFyZSBhbGwNCnN0YW5kYXJkIHRhc2tzIHdhaXRp
bmcgZm9yIHRoZSBycGNpb2QveHBydGlvZCB3b3JrcXVldWVzIHRvIGNvbXBsZXRlDQp0aGUgY2Fs
bHMgdG8gdGhlIHNlcnZlci4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5j
b20NCg0KDQo=
