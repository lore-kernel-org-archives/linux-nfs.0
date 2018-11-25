Return-Path: <SRS0=//lM=OE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBBCFC43441
	for <linux-nfs@archiver.kernel.org>; Sun, 25 Nov 2018 03:04:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E3B72086B
	for <linux-nfs@archiver.kernel.org>; Sun, 25 Nov 2018 03:04:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="sC90ZLHy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E3B72086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726770AbeKYNyR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 25 Nov 2018 08:54:17 -0500
Received: from mail-eopbgr700120.outbound.protection.outlook.com ([40.107.70.120]:47104
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726722AbeKYNyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 25 Nov 2018 08:54:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1/b8TJV3dfqYhVID4HnadO8C3sLYbwMVprinuxhicbg=;
 b=sC90ZLHyDDqDS4zwpcPdzdZsu0iCQWoN687Z9xyZBd/VufrJB6u76Nkldn+7GqMw6Dz+aWSEZKn+kW+A7PUh8GZ6zVOB8PrjvuzAu7uR3csDixsD4qxZen1qo/I15U88Gj/RhaGwRml4pK6SHTxFaQh0IMXN6XpsiyymJKfsuRQ=
Received: from BYAPR13MB2486.namprd13.prod.outlook.com (52.135.230.12) by
 BYAPR13MB2455.namprd13.prod.outlook.com (52.135.229.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1361.13; Sun, 25 Nov 2018 03:04:12 +0000
Received: from BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::4c50:319e:6ba0:dfb7]) by BYAPR13MB2486.namprd13.prod.outlook.com
 ([fe80::4c50:319e:6ba0:dfb7%4]) with mapi id 15.20.1361.019; Sun, 25 Nov 2018
 03:04:11 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client changes
Thread-Topic: [GIT PULL] Please pull NFS client changes
Thread-Index: AQHUhGuKpcJuVXrbnEmJF/fjvSTNSQ==
Date:   Sun, 25 Nov 2018 03:04:11 +0000
Message-ID: <adb722d9cf7e1d6d1a3290f0af044b948bc81511.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR13MB2455;6:7FHVggp0vrVxT2LG/azFuXpgKhB+s7JuJY3Lo4Mk1Q9JG2MApvvCU2wUIsOEFscDp4JYh+ocsn2YCQplqAizDDQhfmW/HmjUTlp1VezVQK5kr831euktmRZ+Rz14EcRVHNzvWuw/acc5KWqlIA6bONZHMDWDEEvqZv5GScABn5cWeRI/qpghqOxNA1h1qN7IgXe6/QHEFMfxadOLQldmMTK39SW0+adq3cmfFRDM26W9kt94JNdcIEFeovG4yjUXAIqbSIGdDpreJYTlieXEYTP6uI7mcg9+XDRubx+MSXizCz94sTezKtnFKXLRWhrNoxn8ixszI8/12AwjbM190o1Hycs9T41iaYfYCp8VMwgecTEGNLAdAmwviotmNWAtqpA756irSZjHli6TBKTMatKgOU5VKvM8rYMQlwAijARwat1L0DXHI7/rQCuE4QqHMj46dnT1hiiUBAglTFmbqw==;5:cMZ2tL0Mf08eg+BV7GD4rby3wIzEQDx5YN0t4b1NjrvQ9DVIUdOPZ+YwRqSrfIAFChrTQ4yy1rVKs+QyOpCt2gyxBIuSc8gA5CJilw70ayGEMVBmY49/TrTOEBvqNprkBH+Kref9l75jZkdUe0axuA4t/aWNiE1Y19hOYkcK0Ak=;7:whUsifGlEJ0eYUEzO8SCQryn2ASNBsq+vGk/z9TmDFg9QtljSMMG6z4Ud3BEqQd+/tQkgEeZZpB2jzNf58BrrgiR0OgDG9WviQ3XzE99l5pn457Ca+Tu/WzMA4DY+ff+/KEp6/bFzT9zfuCjx9nYcA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: c97d3e8a-06ef-4752-cadf-08d65282acca
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:BYAPR13MB2455;
x-ms-traffictypediagnostic: BYAPR13MB2455:
x-microsoft-antispam-prvs: <BYAPR13MB2455C93AA8F3C3B4E444D6E8B8D60@BYAPR13MB2455.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(3231442)(944501410)(52105112)(3002001)(93006095)(93001095)(10201501046)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(20161123558120)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:BYAPR13MB2455;BCL:0;PCL:0;RULEID:;SRVR:BYAPR13MB2455;
x-forefront-prvs: 0867F4F1AA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(39830400003)(396003)(346002)(366004)(199004)(189003)(97736004)(4001150100001)(8936002)(68736007)(118296001)(86362001)(25786009)(14454004)(8676002)(1730700003)(81156014)(81166006)(478600001)(575784001)(2501003)(6116002)(3846002)(2351001)(106356001)(105586002)(71200400001)(71190400001)(66066001)(316002)(54906003)(36756003)(305945005)(7736002)(6486002)(6436002)(26005)(486006)(99286004)(476003)(2616005)(186003)(102836004)(6506007)(53936002)(6916009)(2906002)(14444005)(256004)(5640700003)(6512007)(4326008)(5660300001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR13MB2455;H:BYAPR13MB2486.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: QoPb+caTgwpGDQt6CcZsV3oQ3lBAMvKmU1f2OEhhfm6uVv+kO8OKbFkZgS05ruAu06eucOJE9x8sXNKWe1AEBe9wRb9SNlgffGeUucUApSB0T2BgXE4Px8oO3UL0+9tvKXfL9kqph5FdPAg65FgwszcwzxWg8QSmtM1w+QsqmJmOACBKGt70eDugbpT+zE1Ud94ARO0YhuDCCg1RA9sIuHWrxWI4I44U8lw9raBnyfH8Qf/y3TmlzJfSqTUuM/F6XpWf8jjJFsu0bm4IkdthqxZLXy7t8OUEYUsI/iyNW4/dr1q8VqOr26cpHZQ0kplVNc/Af3bonxGjDt+1LCRSFEOxswjDta2rYfyhk/4Wh3Q=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <442199519C7E2248AE067D6746522199@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c97d3e8a-06ef-4752-cadf-08d65282acca
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Nov 2018 03:04:11.5920
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR13MB2455
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgOWZmMDExOTNh
MjBkMzkxZThkYmNlNDQwM2RkNWVmODdjN2VhYWNhNjoNCg0KICBMaW51eCA0LjIwLXJjMyAoMjAx
OC0xMS0xOCAxMzozMzo0NCAtMDgwMCkNCg0KYXJlIGF2YWlsYWJsZSBpbiB0aGUgR2l0IHJlcG9z
aXRvcnkgYXQ6DQoNCiAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9s
aW51eC1uZnMuZ2l0IHRhZ3MvbmZzLWZvci00LjIwLTQNCg0KZm9yIHlvdSB0byBmZXRjaCBjaGFu
Z2VzIHVwIHRvIGJiMjFjZTBhZDIyN2I2OWVjMGY4MzI3OTI5N2VlNDQyMzIxMDVkOTY6DQoNCiAg
ZmxleGZpbGVzOiB1c2UgcGVyLW1pcnJvciBzcGVjaWZpZWQgc3RhdGVpZCBmb3IgSU8gKDIwMTgt
MTEtMjIgMTQ6MDQ6NTUgLTA1MDApDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCk5GUyBjbGllbnQgYnVnZml4ZXMgZm9y
IExpbnV4IDQuMjANCg0KSGlnaGxpZ2h0cyBpbmNsdWRlOg0KDQpCdWdmaXhlczoNCiAtIEZpeCBh
IE5GU3Y0IHN0YXRlIG1hbmFnZXIgZGVhZGxvY2sgd2hlbiByZXR1cm5pbmcgYSBkZWxlZ2F0aW9u
DQogLSBORlN2NC4yIGNvcHkgZG8gbm90IGFsbG9jYXRlIG1lbW9yeSB1bmRlciB0aGUgbG9jaw0K
IC0gZmxleGZpbGVzOiBVc2UgdGhlIGNvcnJlY3Qgc3RhdGVpZCBmb3IgSU8gaW4gdGhlIHRpZ2h0
bHkgY291cGxlZCBjYXNlDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCk9sZ2EgS29ybmlldnNrYWlhICgxKToNCiAgICAg
IE5GU3Y0LjIgY29weSBkbyBub3QgYWxsb2NhdGUgbWVtb3J5IHVuZGVyIHRoZSBsb2NrDQoNClRp
Z3JhbiBNa3J0Y2h5YW4gKDEpOg0KICAgICAgZmxleGZpbGVzOiB1c2UgcGVyLW1pcnJvciBzcGVj
aWZpZWQgc3RhdGVpZCBmb3IgSU8NCg0KVHJvbmQgTXlrbGVidXN0ICgxKToNCiAgICAgIE5GU3Y0
OiBGaXggYSBORlN2NCBzdGF0ZSBtYW5hZ2VyIGRlYWRsb2NrDQoNCiBmcy9uZnMvY2FsbGJhY2tf
cHJvYy5jICAgICAgICAgICAgICAgICAgICB8IDIyICsrKysrKysrKysrLS0tLS0tLS0tLS0NCiBm
cy9uZnMvZmxleGZpbGVsYXlvdXQvZmxleGZpbGVsYXlvdXQuYyAgICB8IDIxICsrKysrKysrKy0t
LS0tLS0tLS0tLQ0KIGZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dC5oICAgIHwg
IDQgKysrKw0KIGZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dGRldi5jIHwgMTkg
KysrKysrKysrKysrKysrKysrKw0KIGZzL25mcy9uZnM0MnByb2MuYyAgICAgICAgICAgICAgICAg
ICAgICAgIHwgMTkgKysrKysrKysrKy0tLS0tLS0tLQ0KIGZzL25mcy9uZnM0X2ZzLmggICAgICAg
ICAgICAgICAgICAgICAgICAgIHwgIDIgKysNCiBmcy9uZnMvbmZzNHN0YXRlLmMgICAgICAgICAg
ICAgICAgICAgICAgICB8IDE2ICsrKysrKysrKysrLS0tLS0NCiA3IGZpbGVzIGNoYW5nZWQsIDY2
IGluc2VydGlvbnMoKyksIDM3IGRlbGV0aW9ucygtKQ0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBo
YW1tZXJzcGFjZS5jb20NCg0KDQo=
