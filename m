Return-Path: <SRS0=YXm+=OP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F656C04EB8
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 21:56:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3BE3820838
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Dec 2018 21:56:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BE3820838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725945AbeLFV4j (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 6 Dec 2018 16:56:39 -0500
Received: from mail-eopbgr700138.outbound.protection.outlook.com ([40.107.70.138]:43323
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725936AbeLFV4j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Dec 2018 16:56:39 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/4qn6TFUKarmi00sCjxrKagSX+4qfSkoUAvUdkB/i+k=;
 b=eQabtk/ZeQz5YVcJtosdldT3UsCeSy4q8rjqW4uozmKmazkWm+1Nrv/bXHZGFvVvz+NyyqqtMTPqDLLGAFnyFGdTCc1OyyV76Dxc9QT90T9aYiRT5XRzaqDVmLeIrwi2ZwzxK5BkcEQG/plz+PboaUo/4lAPATeTeUqxA869SyU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2447.namprd13.prod.outlook.com (52.135.95.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1425.8; Thu, 6 Dec 2018 21:55:55 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.020; Thu, 6 Dec 2018
 21:55:55 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client changes
Thread-Topic: [GIT PULL] Please pull NFS client changes
Thread-Index: AQHUja522yXVhS/4XU2bS6iU9ZFqgQ==
Date:   Thu, 6 Dec 2018 21:55:54 +0000
Message-ID: <af690bb605f8366f8b437ca0171edef42fc63e83.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2447;6:4U+2I4g8vkb6p6LH+9YplefEmVP0PS3DJx7bTTJ4aORGZhzVZ9L0rwuDDhRW0IZxS4gacv9g+2pbnRfMC3s4mC10sx1ITp7NlA0gmFNdQBeYOtcEM6poAZPs6dHSR+Dh6BqWb6XmUO2I/VieYUTfwe6l28YU1nb12J7xpusvCZDa516U6UQxL05sPEpRb3jeQj3EiNQgxsdgr6Pr+fgxqmWi6UzshUb3VOEkmnt5AzEVHM7sWinEApaTzlE1GAMHMxkW/RMvSCsY17L5OChBz/jignN69sa/p19AlkRDGyJaF4nIVmN59unT0IjkKMXuP8oo5H5qiAGwJANb98l0j/BFAEscX+wH5vQ/i/5fnCajWUw8w6ATvR16YiKwbeGlbUgdO7FPW8LFepvneB+uGjgMbG8erBQoCi7Rvn0HL6jS7pFkNhj08LaJv16k6zubxFhfdb+nC3g2cUFcYZZ0QQ==;5:/IC0TplLh0XEcmlAu4pvfUOe9IHy2MplfTVKQRolitZ5J7wtEFDxOTrrPuq9IDlGEezSVWB5oMuiVnms9Ffon1VHH3oxPA6wrWacD7l981PuFtQObFrVfplt7MCoOrTBZzIRDiTU9GQHt57QD34gO1tRodETExdWx1UAo2jg0AE=;7:rIqJQampwcppK1QmLKZWeRCfa/SLmwWwdNPc6isffKx0UkvXrpD5Boe1Pz8mPxqmR92yr/ncORxQCKyy1M1X6Gw9jkWQ9ZV+GuMKYpNXuxy+pHm8ZyFizJ3h4WDwxQYEFYm3iAdtAotvdoBX6X6q8A==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: a7b99c39-6a01-4372-ea6a-08d65bc59909
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2447;
x-ms-traffictypediagnostic: SN6PR13MB2447:
x-microsoft-antispam-prvs: <SN6PR13MB2447074A962A3617E1C99EB7B8A90@SN6PR13MB2447.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(10201501046)(3002001)(93006095)(93001095)(3231455)(999002)(944501520)(52105112)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123562045)(20161123560045)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2447;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2447;
x-forefront-prvs: 087894CD3C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(376002)(39830400003)(136003)(189003)(199004)(14454004)(5660300001)(102836004)(6512007)(6916009)(81156014)(186003)(26005)(36756003)(81166006)(476003)(14444005)(256004)(2616005)(99286004)(486006)(6506007)(2351001)(4326008)(53936002)(68736007)(118296001)(66066001)(1730700003)(54906003)(105586002)(2906002)(6486002)(2501003)(7736002)(305945005)(316002)(3846002)(6116002)(575784001)(86362001)(106356001)(97736004)(5640700003)(8936002)(6436002)(8676002)(71200400001)(25786009)(71190400001)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2447;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: vsrIW/6pXpQ9U5T98nRgirByfpBp45sn7KXNn+FOfJeC3lPMu9jaX5/zR9+5hALZzOj2aoYBnHpubMi75j044Uili0aUFIXlO+kUeFXTh1qFHoXih54vMcPh7/8ybF/t0+WAp+o3tGpzcRTUOJvEgqHPQWbR4SgwZpGZd3RhbnLaAjn2y1hJruCq2io1BVrfs6wM5Fl32q3UVT7zorIivWT/cUE1yl2SZT3HdGiU5sn9/W0DbLgUexWaHGohkmUaeeD8GGqBFEJCfIX1ZSsiY4D7twWXT/BeiOMWq8K/pkjy9YCWp2JB4iaKKm3b+u9WmqZaRyxtbX99kqJi4DdkG3354Zjp40lcMZ1602ADWB0=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <CC04B8E3A2938345967B477E7B26B6D4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a7b99c39-6a01-4372-ea6a-08d65bc59909
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Dec 2018 21:55:55.1641
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2447
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNCkFwb2xvZ2llcyBmb3IgdGhlIHJlbGF0aXZlbHkgaGlnaCB2b2x1bWUgdGhp
cyBsYXRlIGluIC1yYy4gVGhpcyBpcyBtYWlubHkNCmZhbGxvdXQgZnJvbSB0aGUgdXBkYXRlcyB0
byB0aGUgU1VOUlBDIGNvZGUgdGhhdCBpcyBiZWluZyB0cmlnZ2VyZWQgZnJvbQ0KbGVzcyBjb21t
b24gY29tYmluYXRpb25zIG9mIE5GUyBtb3VudCBvcHRpb25zLg0KDQpDaGVlcnMNCiAgVHJvbmQN
Cg0KVGhlIGZvbGxvd2luZyBjaGFuZ2VzIHNpbmNlIGNvbW1pdCA0Yjc4MzE3Njc5YzRmMzc4MmEz
Y2ZmMGRkYjI2OWMxZmNmZGU3NjIxOg0KDQogIE1lcmdlIGJyYW5jaCAneDg2LXB0aS1mb3ItbGlu
dXMnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90aXAv
dGlwICgyMDE4LTEyLTAxIDEyOjM1OjQ4IC0wODAwKQ0KDQphcmUgYXZhaWxhYmxlIGluIHRoZSBH
aXQgcmVwb3NpdG9yeSBhdDoNCg0KICBnaXQ6Ly9naXQubGludXgtbmZzLm9yZy9wcm9qZWN0cy90
cm9uZG15L2xpbnV4LW5mcy5naXQgdGFncy9uZnMtZm9yLTQuMjAtNQ0KDQpmb3IgeW91IHRvIGZl
dGNoIGNoYW5nZXMgdXAgdG8gNzk0NjI4NTdlYjU0N2U1ZDE3ZmM4NDQ1Yjk3Njg2MTVlMDJkYzFj
ZjoNCg0KICBTVU5SUEM6IERvbid0IGZvcmNlIGEgcmVkdW5kYW50IGRpc2Nvbm5lY3Rpb24gaW4g
eHNfcmVhZF9zdHJlYW0oKSAoMjAxOC0xMi0wNSAwNzoxMToxMiAtMDUwMCkNCg0KLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0K
TkZTIGNsaWVudCBidWdmaXhlcyBmb3IgTGludXggNC4yMA0KDQpIaWdobGlnaHRzIGluY2x1ZGU6
DQoNClN0YWJsZSBmaXhlczoNCiAtIEZpeCBhIHBhZ2UgbGVhayB3aGVuIHVzaW5nIFJQQ1NFQ19H
U1Mva3JiNXAgdG8gZW5jcnlwdCBkYXRhLg0KDQpCdWdmaXhlczoNCiAtIEZpeCBhIHJlZ3Jlc3Np
b24gdGhhdCBjYXVzZXMgdGhlIFJQQyByZWNlaXZlIGNvZGUgdG8gaGFuZw0KIC0gRml4IGNhbGxf
Y29ubmVjdF9zdGF0dXMoKSBzbyB0aGF0IGl0IGhhbmRsZXMgdGFza3MgdGhhdCBnb3QgdHJhbnNt
aXR0ZWQNCiAgIHdoaWxlIHF1ZXVlZCB3YWl0aW5nIGZvciB0aGUgc29ja2V0IGxvY2suDQogLSBG
aXggYSBtZW1vcnkgbGVhayBpbiBjYWxsX2VuY29kZSgpDQogLSBGaXggc2V2ZXJhbCBvdGhlciBj
b25uZWN0IHJhY2VzLg0KIC0gRml4IHJlY2VpdmUgY29kZSBlcnJvciBoYW5kbGluZy4NCiAtIFVz
ZSB0aGUgZGlzY2FyZCBpdGVyYXRvciByYXRoZXIgdGhhbiBNU0dfVFJVTkMgZm9yIGNvbXBhdGli
aWxpdHkgd2l0aA0KICAgQUZfVU5JWC9BRl9MT0NBTCBzb2NrZXRzLg0KIC0gbmZzOiBkb24ndCBk
aXJ0eSBrZXJuZWwgcGFnZXMgcmVhZCBieSBkaXJlY3QtaW8NCiAtIHBuZnMvRmxleGZpbGVzIGZp
eCB0byBlbmZvcmNlIHBlci1taXJyb3Igc3RhdGVpZCBvbmx5IGZvciBORlN2NCBkYXRhDQogICBz
ZXJ2ZXJzDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0NCkNodWNrIExldmVyICgxKToNCiAgICAgIFNVTlJQQzogRml4IGxl
YWsgb2Yga3JiNXAgZW5jb2RlIHBhZ2VzDQoNCkRhdmUgS2xlaWthbXAgKDEpOg0KICAgICAgbmZz
OiBkb24ndCBkaXJ0eSBrZXJuZWwgcGFnZXMgcmVhZCBieSBkaXJlY3QtaW8NCg0KVGlncmFuIE1r
cnRjaHlhbiAoMSk6DQogICAgICBmbGV4ZmlsZXM6IGVuZm9yY2UgcGVyLW1pcnJvciBzdGF0ZWlk
IG9ubHkgZm9yIHY0IERTZXMNCg0KVHJvbmQgTXlrbGVidXN0ICg5KToNCiAgICAgIFNVTlJQQzog
Y2FsbF9jb25uZWN0X3N0YXR1cygpIG11c3QgaGFuZGxlIHRhc2tzIHRoYXQgZ290IHRyYW5zbWl0
dGVkDQogICAgICBTVU5SUEM6IEZpeCBhIG1lbW9yeSBsZWFrIGluIGNhbGxfZW5jb2RlKCkNCiAg
ICAgIFNVTlJQQzogRml4IGEgcG90ZW50aWFsIHJhY2UgaW4geHBydF9jb25uZWN0KCkNCiAgICAg
IFNVTlJQQzogRml4IFJQQyByZWNlaXZlIGhhbmdzDQogICAgICBTVU5SUEM6IEZpeCB1cCBoYW5k
bGluZyBvZiB0aGUgWERSQlVGX1NQQVJTRV9QQUdFUyBmbGFnDQogICAgICBTVU5SUEM6IFRyZWF0
IEVGQVVMVCBhcyBhIHRydW5jYXRlZCBtZXNzYWdlIGluIHhzX3JlYWRfc3RyZWFtX3JlcXVlc3Qo
KQ0KICAgICAgU1VOUlBDOiBVc2UgdGhlIGRpc2NhcmQgaXRlcmF0b3IgcmF0aGVyIHRoYW4gTVNH
X1RSVU5DDQogICAgICBTVU5SUEM6IEZpeCB1cCBzb2NrZXQgcG9sbGluZw0KICAgICAgU1VOUlBD
OiBEb24ndCBmb3JjZSBhIHJlZHVuZGFudCBkaXNjb25uZWN0aW9uIGluIHhzX3JlYWRfc3RyZWFt
KCkNCg0KIGZzL25mcy9kaXJlY3QuYyAgICAgICAgICAgICAgICAgICAgICAgIHwgIDkgKysrLQ0K
IGZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dC5jIHwgIDYgKystDQogaW5jbHVk
ZS9saW51eC9zdW5ycGMveGRyLmggICAgICAgICAgICAgfCAgMSAtDQogbmV0L3N1bnJwYy9hdXRo
X2dzcy9hdXRoX2dzcy5jICAgICAgICAgfCAgNCArKw0KIG5ldC9zdW5ycGMvY2xudC5jICAgICAg
ICAgICAgICAgICAgICAgIHwgIDggKysrKw0KIG5ldC9zdW5ycGMveHBydC5jICAgICAgICAgICAg
ICAgICAgICAgIHwgMTMgKysrKystDQogbmV0L3N1bnJwYy94cHJ0c29jay5jICAgICAgICAgICAg
ICAgICAgfCA4MSArKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0tLS0tDQogNyBmaWxlcyBj
aGFuZ2VkLCA3MyBpbnNlcnRpb25zKCspLCA0OSBkZWxldGlvbnMoLSkNCi0tIA0KVHJvbmQgTXlr
bGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5t
eWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
