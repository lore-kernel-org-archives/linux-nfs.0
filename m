Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD73BC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 18:22:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 90EAA2075C
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 18:22:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rutgers.edu header.i=@rutgers.edu header.b="sFq8UFdb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725986AbfBVSWv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 13:22:51 -0500
Received: from mail-eopbgr760113.outbound.protection.outlook.com ([40.107.76.113]:26304
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725832AbfBVSWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 13:22:51 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=rutgers.edu;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=urYOcoaQbWRehL0BU3zTbzkbhWc6DTQSEHF6iU4FB9E=;
 b=sFq8UFdbgIvP9Z3j1CcnsOgkNQu8xg7Uv5XqfGZ4A2taYcI6OuSEZozFhoxcX8AOSvz46stc62ZKw5aD7vIcGCvMs1qg58KjI+F8WWtIikE/NI8VlHCAhJH8R34AgNMwOE0Qs3/hxy8R5x+Vfs+xpsrIVfx9QOpyZmDW/56y1w8=
Received: from BN6PR1401MB2099.namprd14.prod.outlook.com (10.174.114.144) by
 BN6PR1401MB1873.namprd14.prod.outlook.com (10.174.115.148) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Fri, 22 Feb 2019 18:22:48 +0000
Received: from BN6PR1401MB2099.namprd14.prod.outlook.com
 ([fe80::40dd:21b0:1915:6419]) by BN6PR1401MB2099.namprd14.prod.outlook.com
 ([fe80::40dd:21b0:1915:6419%12]) with mapi id 15.20.1643.018; Fri, 22 Feb
 2019 18:22:48 +0000
From:   Charles Hedrick <hedrick@rutgers.edu>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: wrong credentials used by gssd
Thread-Topic: wrong credentials used by gssd
Thread-Index: AQHUytudme0FY4rUxkaKAN2jzq5O/A==
Date:   Fri, 22 Feb 2019 18:22:48 +0000
Message-ID: <77C1FC02-698E-47C8-8817-63661B135B76@rutgers.edu>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hedrick@rutgers.edu; 
x-originating-ip: [2620:0:d60:ac1a:dc07:fc93:2977:336b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 501a8a60-2c33-4948-a013-08d698f2bfce
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BN6PR1401MB1873;
x-ms-traffictypediagnostic: BN6PR1401MB1873:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCTjZQUjE0MDFNQjE4NzM7MjM6U0s5eUU0TjdqSWpaSUs5VjRJQ3lCZjJy?=
 =?utf-8?B?Ukw1U0VaeVkwVUx6WkdRRXZqYnMwcDY4SUhScWZRSi8rdGY3S0NUcjA1cG15?=
 =?utf-8?B?YWxpN0RtckdKTVozeENJK3FKS0JFL2RYd2Y2eXUyL0k2SzAzWmhLWk9ZQUdm?=
 =?utf-8?B?MHZuNFI4R25INm5NQTdxTXl4MFNmcW0wSGxFbjhOUG5YcitKVE5pcDQvVW5O?=
 =?utf-8?B?WTBsZE9QdzBrdnRuSVBxL0sxWXArb2dDM0c3bG9ScDhRUGpZL2ttd3Y0WVpN?=
 =?utf-8?B?UXpKUHMzbjlpbkxZRit3V0t0U2JxanBlVVhpaHUwUGtqMmdJdHhjK1Npam5p?=
 =?utf-8?B?V3ZFMFE0aXl0VE9kZk16RGU4U29TdVNvcWNEVEVXZWFBeGxValNhSUhVK1Fi?=
 =?utf-8?B?K25UUXBUbmcwQzlzeFkvWHNGVDlLQ0lGYkRLVHAwUUI2SThBQ3lXMnlUNTRQ?=
 =?utf-8?B?SWZyblN5Y29pS0JqcU40T284ZFJOcjk1eXlSN2M0RUZHMk91R05xenhqYnhm?=
 =?utf-8?B?NDU1cDhuNzMvYktWUGV1dEFxd29EV0k2ZmRlOHBLL25OOStwczJ4RVVWZFBp?=
 =?utf-8?B?aFc5bktqRzB2Q1RjaGhwVnZFRjlsTWY2Nm1WZU4raWJGVGxhbkZEWVNOSTRs?=
 =?utf-8?B?SEtVc01NS3JDTUYzb2kvMG9yOW85WDhLKzF3a3FlWmIxRjNiaU96ejNScEw4?=
 =?utf-8?B?MTlBckNOOElsakl4RDRndlVKQWRCa2NJa050OEUza0d4ZGJ1VjdSYnZ0SzJR?=
 =?utf-8?B?WDVBMTBFNERaUEc0ZzNxMGlWNzQ3NUZOOVNYZDB4K3NuRlNvSXRFelo2Rnk2?=
 =?utf-8?B?ZmFPWWpTUjVld2g0blJWMW80QkgrcmdhSXZFZFZIM0JtVWpGbkpxdUFVMjFV?=
 =?utf-8?B?SldIY2Zqd1BrQjdNOEMvai8zQmJNd0dRZk5Wc0xDc25SUGZFbDd6Q1hYQjIx?=
 =?utf-8?B?cUczTEJ2dHZmY0E4TEkrcjBrbjlLcllGZzNkc1ZqVWdzalVDTm1yYjZQNzFJ?=
 =?utf-8?B?VHZIM2JmVlNZRTFVcklQSm1Zc2k1aHowOWYxdWlpQlhsQTd3UlMxSHZxSlpL?=
 =?utf-8?B?SEhMRHl2TkoxbkM3M2NKSnF3SWNtL3Q1TStBMEllbnd3SEFNQnRub3FFdGZD?=
 =?utf-8?B?VVVJZkZiSHAxRUpGV1BCN2xWM1gySUVSc08vRithNHlSOXVuTlBtYU9QeFBQ?=
 =?utf-8?B?aGEwbGEyTWUrWktjcG84S0luMHZRWlA4dUMxVmRDTG5iWGwrRDRVQkMvV0l3?=
 =?utf-8?B?VnkvWGc5a01qMGxZNm5RYVBTbXdhRTlmeDBBUE5RMzZMT256L2h0aUljRHUv?=
 =?utf-8?B?bjdrbWM0Y0NSOHdoTEZlbGhUV3grM0t5VWU0UCsyd2ZBL1VwUnBBL1VIaDlC?=
 =?utf-8?B?T1h1WDVEZ0ZKc290Q1pqdm5JbkpWR29ra2lCWGRlenNnTzRkT3J6WW1aQjR3?=
 =?utf-8?B?a0NOalFxYU1qd3RibVhYQnZGQnp0UGhISGErU3pqb09sUG1CRzBqTk9nWXB3?=
 =?utf-8?B?NG9uMDc0T2NqVlJnTEFYa3VpQ2hWZE5EaldBTmhRWWZweGVHZTRacWV4VzEy?=
 =?utf-8?B?bFJnYkN3czBwemFjQWg3bmZKVjd2LzFPdzY1bTdRV1pSL2pLYmtIOUJyRGcz?=
 =?utf-8?Q?Ofj5V3XqsfFsN3l2qG2+2w?=
x-microsoft-antispam-prvs: <BN6PR1401MB187318EB9DCE85E3683FCB8DAA7F0@BN6PR1401MB1873.namprd14.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(39860400002)(346002)(396003)(136003)(189003)(199004)(6486002)(82746002)(53936002)(106356001)(105586002)(256004)(14444005)(75432002)(478600001)(5660300002)(2351001)(25786009)(36756003)(5640700003)(6512007)(8676002)(6116002)(486006)(86362001)(88552002)(14454004)(33656002)(2906002)(6436002)(71200400001)(6506007)(2501003)(81166006)(81156014)(46003)(102836004)(186003)(476003)(8936002)(6916009)(4744005)(7736002)(71190400001)(83716004)(305945005)(97736004)(68736007)(316002)(99286004)(786003)(2616005);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR1401MB1873;H:BN6PR1401MB2099.namprd14.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: rutgers.edu does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: eX0XaHooG5v+s5m0Ow5wh2XPfFjeUDDpBBE97JD2JvYzO3r6yyKc0wQr+ECq1jiBgC5XRZGqoC5Cc1cSLGWC4G73dUPSrfRR+3h817GhZZAx0naR4GRO0S169QTvg+0OCt+Qkj/sXhzW+SVKROX//rExRFPv5qNG7RlaRdijx84dmunzwdZec//k9jPqpDs7hMo+ZPtbx7KpRJ0N3lDgkLooLzCkFWJnNGOyFOLU+Ao0xv/x4gpY8cA22ttrMQUQs64Jp8p9HPxYS3l6748xlceHxCcb7fcZLBJf7D3bgEcoY7BK1e3rfuQ4wpPIwSPSIee6RSycGPzbj7RwfsqJdr4uC05ruETJDxxclj7bC3DhQF+IT8/jFNqfwkYymTAtgDiM4Lf6vBGRlwj5gMG2a6OVyazn8tUG2S1RMYMd3kw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <289F74B3AE0532479F369F79D8BF5BDA@namprd14.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: rutgers.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 501a8a60-2c33-4948-a013-08d698f2bfce
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 18:22:48.5680
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b92d2b23-4d35-4470-93ff-69aca6632ffe
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR1401MB1873
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

V291bGQgc29tZW9uZSBwbGVhc2UgbG9vayBhdCBidWd6aWxsYSBsaW51eC1uZnMgb3JnIC8gc2hv
d19idWcuY2dpID8gaWQ9MzE4Lg0KDQpJZiBJ4oCZbSBsb2dnZWQgaW4gYSBoZWRyaWNrIGJ1dCBj
dXJyZW50IGNyZWRlbnRpYWxzIGFyZSBoZWRyaWNrLmFkbWluLCBJIGhhdmUgYSBrZXkgcmluZyB3
aXRoIGNyZWRlbnRpYWxzIGZvciBib3RoIGhlZHJpY2sgYW5kIGhlZHJpY2suYWRtaW4uDQoNCklm
IGdzc2QgbmVlZCB0byByZWNyZWF0ZSBpdHMgY29udGV4dCAoZS5nLiBiZWNhdXNlIHRoZXkgY3Jl
ZGVudGlhbHMgaGF2ZSBleHBpcmVkKSBpdCBhcXVpcmVzIEdTU0FQSSBjcmVkZW50aWFscyB3aXRo
IE5PTkFNRS4gVGhhdCB3aWxsIGdpdmUgaXQgaGVkcmljay5hZG1pbi4gTGF0ZXIgaW4gdGhlIGNv
ZGUgaXMgY2hlY2tzIHRvIHNlZSBpZiB0aGUgY3JlZGVudGlhbHMgaXQgaGFzIGFyZSBmb3IgaGVk
cmljaywgYW5kIGZhaWxzLiBUaGlzIGlzIGtpbmQgb2Ygc2lsbHkuIElmIHlvdSBhcXVpcmUgd2hh
dCBjcmVkZW50aWFscyB5b3Ugd2FudCwgaXQgd2lsbCBsb29rIHRocm91Z2ggdGhlIGtleXJpbmcg
YW5kIHBpY2sgdGhlIHJpZ2h0IG9uZXMuIFNvIHRoZSBjYWxsIHRvIGFjcXVpcmUgc2hvdWxkIHNw
ZWNpZnkgdGhlIGRlc2lyZWQgcHJpbmNpcGFsLg0KDQpUaGUgYnVnIHJlcG9ydCBnaXZlcyBjb2Rl
IHRvIGZpeCBpdC4gQmVjYXVzZSBJIGRvbuKAmXQgd2FudCB0byBidWlsZCBteSBvd24gZ3NzZCwg
bXkgcGF0Y2ggdXNlcyBMRF9QUkVMT0FEIHRvIGludGVyY2VwdCBjYWxscywgYnV0IHRoZSBjb2Rl
IGNvdWxkIGJlIHB1dCBpbnRvIHRoZSBzb3VyY2UgaW4gdGhlIG9idmlvdXMgd2F5Lg==
