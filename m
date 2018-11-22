Return-Path: <SRS0=4pmG=OB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A355AC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 14:32:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5362F20685
	for <linux-nfs@archiver.kernel.org>; Thu, 22 Nov 2018 14:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=virtuozzo.com header.i=@virtuozzo.com header.b="NRMsEQVX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5362F20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389021AbeKWBMU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 22 Nov 2018 20:12:20 -0500
Received: from mail-eopbgr150121.outbound.protection.outlook.com ([40.107.15.121]:33472
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2403891AbeKWBMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Nov 2018 20:12:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tdYTJqXr1iAM09ucEkOHIk9AhJgDlEg1ulHuaYOb5zo=;
 b=NRMsEQVX/89PjbEagjbHt+wCYjfMU8Nu7wMsAnwkrGbgXD5YlXDBpjpKQqJVAR2YI3ubwgJIDaew9qo0B6MIO8S5hFO1/l2eCZ98BjDz7srttjGtdxzzPTqnvLTS0xg6q82pf9aHGP4w6ARo0S4d5uyEQ2WP/xrfkdq17YG9HU0=
Received: from AM0PR08MB3890.eurprd08.prod.outlook.com (20.178.82.146) by
 AM0PR08MB2978.eurprd08.prod.outlook.com (52.134.92.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1339.26; Thu, 22 Nov 2018 14:32:39 +0000
Received: from AM0PR08MB3890.eurprd08.prod.outlook.com
 ([fe80::7dcc:8b82:dbe7:480c]) by AM0PR08MB3890.eurprd08.prod.outlook.com
 ([fe80::7dcc:8b82:dbe7:480c%4]) with mapi id 15.20.1339.027; Thu, 22 Nov 2018
 14:32:39 +0000
From:   Evgenii Shatokhin <eshatokhin@virtuozzo.com>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC:     Trond Myklebust <trond.myklebust@hammerspace.com>
Subject: Debugging a kernel crash in svc_process_common() on the client (NFS
 4.1)
Thread-Topic: Debugging a kernel crash in svc_process_common() on the client
 (NFS 4.1)
Thread-Index: AQHUgnA4YqsjhIe0M0KOHhJIyLI/ng==
Date:   Thu, 22 Nov 2018 14:32:39 +0000
Message-ID: <ffb9d35c-46a8-17f5-dbfa-c0cb2be444e0@virtuozzo.com>
Accept-Language: ru-RU, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: HE1PR0402CA0017.eurprd04.prod.outlook.com
 (2603:10a6:3:d0::27) To AM0PR08MB3890.eurprd08.prod.outlook.com
 (2603:10a6:208:109::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=eshatokhin@virtuozzo.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [95.26.137.43]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;AM0PR08MB2978;20:/hTxspvjuIWZcCoq9RX4VnVp/F/bw8nq6Xnj3QYeCQpEAK6s+32iciYxMQPsabhz6HqrXmRWpo6AKDqOzy4yH+ca5BjtdQWWSPRTtqPnXzb07biTwF3Snd7w/gEQR+3j74JvY2weNEGLMy3ABC1h4vK61UehrCB7Dpsf2oOvBn8=
x-ms-office365-filtering-correlation-id: 5e796f0e-832d-4ec4-9b6f-08d650875a94
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:AM0PR08MB2978;
x-ms-traffictypediagnostic: AM0PR08MB2978:
x-microsoft-antispam-prvs: <AM0PR08MB2978F8B317DC06D2F0CBBF57D9DB0@AM0PR08MB2978.eurprd08.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3231442)(944501410)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(20161123562045)(20161123560045)(20161123558120)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:AM0PR08MB2978;BCL:0;PCL:0;RULEID:;SRVR:AM0PR08MB2978;
x-forefront-prvs: 0864A36BBF
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39850400004)(366004)(396003)(346002)(376002)(199004)(189003)(26005)(2351001)(14444005)(256004)(99286004)(86362001)(476003)(2616005)(486006)(186003)(6916009)(8676002)(6436002)(6506007)(386003)(31686004)(6486002)(2906002)(31696002)(2900100001)(7736002)(4326008)(53936002)(305945005)(508600001)(25786009)(68736007)(14454004)(97736004)(36756003)(6512007)(66066001)(3846002)(52116002)(6116002)(105586002)(71190400001)(102836004)(81166006)(2501003)(71200400001)(106356001)(81156014)(8936002)(5640700003)(316002)(5660300001);DIR:OUT;SFP:1102;SCL:1;SRVR:AM0PR08MB2978;H:AM0PR08MB3890.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: virtuozzo.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: Hw+9AF2xOnN8vyA/EHh/bRoKV7+bNEY/+NDSO2A7FQeTevLvzsqi5UQzI85397H9z8G39IKZdsaWBzbkxK3P3suuILIB4HrT+tOngr1WURdjTSW3Jkk412rDgfAD+XbYZHa0bM6GojJWfs+p8HRiMmVfcOtM6F7NY4a3Q/Qfsb0VCKlzQwXyWKGQIgnE0B8RC5O5hdXGlvFut9SFpgxXLiKBlarTCr+w3Ez418qtd5vCe7FYYCNehnGYVXAXTgFC/XJ+sMGmXAmhH30yxQC0/zMUATp2+xGHFCT4mfLNVSj7EpvNEXST1RTm4oQfamB1uqhKigy9DhX2zymQ43wCMMwJW05xkWqLoOKXf254WvE=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <F5B7FA6105F3E9439AF175D7674DD7F4@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: virtuozzo.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5e796f0e-832d-4ec4-9b6f-08d650875a94
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Nov 2018 14:32:39.3437
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0bc7f26d-0264-416e-a6fc-8352af79c58f
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR08MB2978
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGksDQoNCkkgYW0gZGVidWdnaW5nIHJhcmVseSBvY2N1cnJpbmcga2VybmVsIGNyYXNoZXMgaW4g
c3ZjX3Byb2Nlc3NfY29tbW9uIA0KKCdzdW5ycGMnIGtlcm5lbCBtb2R1bGUpIHRoYXQgc29tZSBv
ZiBvdXIgY3VzdG9tZXJzIGdvdC4gVW5mb3J0dW5hdGVseSwgDQpJIGFtIHN0aWxsIHVuYWJsZSB0
byByZXByb2R1Y2UgdGhlc2UgYW5kIGNhbiBzZWUgbm8gb2J2aW91cyBmaXggaW4gdGhlIA0KbWFp
bmxpbmUga2VybmVsLg0KDQpBbnkgaGludHMgb24gaG93IHRvIGRlYnVnIHRoZSBpc3N1ZSBmdXJ0
aGVyIGNvdWxkIGJlIHZlcnkgaGVscGZ1bC4NCg0KVGhlIE9TIGlzIFZpcnR1b3p6byA3LiBUaGUg
Y3Jhc2hlcyBoYXBwZW5lZCB3aXRoIGF0IGxlYXN0IDIga2VybmVscywgDQpiYXNlZCBvbiAzLjEw
LjAtODYyLjExLjYgYW5kIDMuMTAuMC02OTMuMjEuMSBmcm9tIFJIRUwuDQoNClRoZSBjcmFzaGVz
IGhhcHBlbmVkIHdoZW4gdGhlIGN1c3RvbWVycycgc3lzdGVtcyB3ZXJlIHdyaXRpbmcgYmFja3Vw
cyBvZiANCnNvbWUgZGF0YSB0byBORlMgc2hhcmVzLiBORlMgNC4xIHdhcyB1c2VkLiBObyBSRE1B
Lg0KDQpUaGUgYmFja3RyYWNlIGxvb2tzIGxpa2UgdGhpczoNCg0KIzAgc3ZjX3Byb2Nlc3NfY29t
bW9uIFtzdW5ycGNdDQojMSBiY19zdmNfcHJvY2VzcyBbc3VucnBjXQ0KIzIgbmZzNDFfY2FsbGJh
Y2tfc3ZjIFtuZnN2NF0NCiMzIGt0aHJlYWQNCg0KRWFjaCB0aW1lLCB0aGUgY3Jhc2ggaGFwcGVu
ZWQgaGVyZToNCg0KCS8qIFNldHVwIHJlcGx5IGhlYWRlciAqLw0KCXJxc3RwLT5ycV94cHJ0LT54
cHRfb3BzLT54cG9fcHJlcF9yZXBseV9oZHIocnFzdHApOw0KDQonc3RydWN0IHN2Y194cHJ0JyBp
bnN0YW5jZSBycXN0cC0+cnFfeHBydCBwb2ludGVkIHRvIHdhcyBmaWxsZWQgd2l0aCANCmludmFs
aWQgZGF0YS4gQWNjZXNzaW5nIHJxc3RwLT5ycV94cHJ0LT54cHRfb3BzLT54cG9fcHJlcF9yZXBs
eV9oZHIgDQpjYXVzZWQgdGhlIGNyYXNoIGFzIGEgcmVzdWx0Lg0KDQpJIGNoZWNrZWQgdGhlIGNy
YXNoIGR1bXBzIGFuZCBmb3VuZCB0aGF0IHRoZSBtZW1vcnkgcGFnZSBhbGxvY2F0ZWQgZm9yIA0K
dGhhdCAnc3RydWN0IHN2Y194cHJ0JyAodG8gJ3N0cnVjdCBzdmNfc29jaycgdGhhdCBjb250YWlu
cyBpdCwgdG8gYmUgDQpleGFjdCkgaGFkIGJlZW4gZ2l2ZW4gdG8gYW5vdGhlciwgdW5yZWxhdGVk
LCBwcm9jZXNzIGJ5IHRoYXQgdGltZS4gU28sIA0KaXQgc2VlbXMsIHRoZSBwcm9jZXNzaW5nIG9m
IHRoZSBiYWNrY2hhbm5lbCByZXF1ZXN0IG9uIHRoZXNlIE5GUyBjbGllbnRzIA0KY291bGQgcmFj
ZSB3aXRoIHNvbWV0aGluZyB0aGF0IGNhbGxlZCBzdmNfeHBydF9wdXQoKSBmb3IgdGhhdCAnc3Ry
dWN0IA0Kc3ZjX3hwcnQnIGluc3RhbmNlLg0KDQpGaXJzdCwgSSB0aG91Z2h0IHRoYXQgaXQgbWln
aHQgYmUgYSByYWNlIGJldHdlZW4gYSBiYWNrY2hhbm5lbCByZXF1ZXN0IA0KYW5kIHVtb3VudCBv
ZiB0aGUgTkZTIHNoYXJlIChhbHRob3VnaCBJIGhhdmUgbm8gaW5kaWNhdGlvbiB0aGF0IHRoZSAN
CmN1c3RvbWVycycgc3lzdGVtIHRyaWVkIHRvIHVubW91bnQgaXQpLiBTbywgSSBhZGRlZCBhIGRl
bGF5IGludG8gDQpiY19zdmNfcHJvY2VzcygpLCBvcGVuZWQgYSBmaWxlIG9uIGFuIE5GUyBzaGFy
ZSBmcm9tIG9uZSBORlMgY2xpZW50IGFuZCANCnJlcGxhY2VkIHRoZSBmaWxlIGZyb20gYW5vdGhl
ciBjbGllbnQgdG8gbWFrZSB0aGUgc2VydmVyIHJlY2FsbCB0aGUgDQpkZWxlZ2F0aW9uLCB0byB0
cmlnZ2VyIGEgYmFja2NoYW5uZWwgcmVxdWVzdC4gVGhlbiAtIGNsb3NlZCB0aGUgZmlsZXMgDQph
bmQgdHJpZWQgdG8gdW1vdW50IHRoZSBORlMgc2hhcmUuIEV2ZXJ5dGhpbmcgd2VudCBPSywgbm8g
Y3Jhc2guIHVtb3VudCANCndhaXRlZCB0aWxsIHRoZSBiYWNrY2hhbm5lbCByZXF1ZXN0IGhhZCBi
ZWVuIHByb2Nlc3NlZCBieSB0aGUgY2xpZW50LCBhcyANCml0IHNob3VsZCBoYXZlLg0KDQpJIGFt
IG5ldyB0byB0aGlzIGNvZGUsIHNvIG1pZ2h0IGJlIG1pc3Npbmcgc29tZXRoaW5nIG9idmlvdXMu
IEhvd2V2ZXIsIEkgDQpjYW5ub3Qgc2VlIGF0IHRoZSBtb21lbnQsIGhvdyBiY19zdmNfcHJvY2Vz
cygpIGNvdWxkIHJhY2Ugd2l0aCBmcmVlaW5nIA0Kb2YgdGhhdCAnc3RydWN0IHN2Y19zb2NrJy4N
Cg0KQW55IGlkZWFzPw0KDQpSZWdhcmRzLA0KRXZnZW5paQ0K
