Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00067C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 18:32:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 96A1C2087C
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 18:32:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YJJK2nmi"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728037AbfBDScf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 13:32:35 -0500
Received: from mail-eopbgr740117.outbound.protection.outlook.com ([40.107.74.117]:51808
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727946AbfBDSce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 13:32:34 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=eJToRsYo3yupqF2+VkD3JxnbVdtgUnEAlqYc66I53o4=;
 b=YJJK2nmiIdGInfM6Y4KQQPmQ9UO0vcmtkbGmdRviB08iCS//fO5aafPwzdjUvZ9zF3u19ppWI88jGQt4OZQwAUnka9OhOMh2dk3MFvaadpCapV/m/kod7nmwVXal6nPap+sHh/22m99HpjTHahHh9zpzZFUAao7BdjT4hA7DT0A=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2317.namprd13.prod.outlook.com (52.135.94.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.12; Mon, 4 Feb 2019 18:32:30 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0%3]) with mapi id 15.20.1601.016; Mon, 4 Feb 2019
 18:32:30 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Don't use page_file_mapping after removing the page
Thread-Topic: [PATCH] NFS: Don't use page_file_mapping after removing the page
Thread-Index: AQHUvLVOMBU/aGgFlEWHK7NYEV9MQ6XP9oWA
Date:   Mon, 4 Feb 2019 18:32:30 +0000
Message-ID: <c525031691d77cff46adc30dc16bf1d19fb46900.camel@hammerspace.com>
References: <b85247642d77ea12153d042a4dce85b94d7624ca.1549303962.git.bcodding@redhat.com>
In-Reply-To: <b85247642d77ea12153d042a4dce85b94d7624ca.1549303962.git.bcodding@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2317;6:xiXJ/CL+5Mp83ylfusTjzxCP0niQSErdCeIdc7UiFknlQg0XB1ayc13yCPoFZH3Duf2gi+FeLMtWEFixyBTcHnj3inxD4HbGmsRVslEuGWB6daO6GkB4Tk20dGsYAap9pFzzt7jssEKkz8/ipA06xYQY1Y08nRzVBmca2TgPUK4RGIIE5VoW2UvwfqF6C9fNW5l8LjxkN/21OilHHHvh5+zyhWrkZJs3/2P0lizFgTi3rjtEa3j6GCHDsPp3RxujMlsWlri1iQtC1Jz4wpGglKV0gTtbYbyPWJ31JvveiLU3gUsVpxP3SF3IT12A3Ii24aTergPXn6DPQj283BcG3o8mvhRApfqdUiW3WtzL7MQB0RwgQEd/8CEGBmg1Y23j446yD/MBMp7FtIcK1SUluuXR29FkI97kLe4lmAr+4Q8Z5mkOywAy1poTXo4afYU8NKZW7Jvuw7J57XLmOLQcbA==;5:F3YwN7tYr05P1BlkwKLHf8KxBeXI5cV43+bCdSkwtL27ykDnP/dQNGOERD18QpXoHS78UYMx+dyjZw5o/APVICn2bM2RVKOFFefXwiBG42Z0NKEb5UHrdu7R6yX5FuwE98mjhn/6SFxW6Ex2Bf1VyylbeBKXbNfg+gwteikPM1V3vthYVYqk2/mcM0nEePXKGX28N54ZT8WXP0REWBSAVA==;7:pOPmqPOCNH5OJy1tvy4vaVAylGJdG4DqjN7xsI0QRU3Nlg5lX13RcCPWg/dTjc3nQR5SYj355UwVoeOVhbVVh6nw8XNGuExnQhhUhtmORAmdulPTJw0wUYmmi0bqpP6dOadiRDYfOb9El7Oy8BwDjw==
x-ms-office365-filtering-correlation-id: 4084fe57-b1a5-48ae-a358-08d68acf1f02
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2317;
x-ms-traffictypediagnostic: SN6PR13MB2317:
x-microsoft-antispam-prvs: <SN6PR13MB2317F67F6575A6B65CD47B30B86D0@SN6PR13MB2317.namprd13.prod.outlook.com>
x-forefront-prvs: 0938781D02
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(346002)(136003)(39830400003)(376002)(199004)(189003)(4744005)(508600001)(256004)(8676002)(11346002)(3846002)(305945005)(2906002)(102836004)(6116002)(316002)(53936002)(446003)(110136005)(6246003)(99286004)(86362001)(476003)(76176011)(229853002)(97736004)(36756003)(81166006)(6512007)(6436002)(66066001)(81156014)(8936002)(6486002)(2616005)(118296001)(68736007)(7736002)(25786009)(486006)(71190400001)(71200400001)(186003)(14454004)(6506007)(26005)(105586002)(106356001)(4326008)(2501003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2317;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Gl1XnrCtBEhISPJJxs1RvrYLjH31SovwhlZgIAu6VdRU04YVgZF9+vgDiVWw/QL+RqrOjbqzOBhEOoYhqNeax+kFyR+DbOHkMEVt/mmjzVoeJg9LgYmony7+OGdYZo2aT6K/K24wV6WYG1lEWImUT6eyNp+Y+zksL9ZFCiQyrP5NT/Rph+CGDXqz8mmVjyw+r6AY7Jjb2R/0IXO3MY7pyzve1TySz2vrS3Z5y/NuRHKwoIZyqcKnpamJk0sOVQXOsHf6aBfUoQ7G9fQBuoahePq9vlAbM/eN/0jpcb86usqNoRLmSLF6wYIsAJqX6ejc5rgHM6vxDohcqDhJsfiFEZ7YzqCzjVO5FLR97im/iMUwQbUUaF2vrxYBl7vdM7JGSTw82SAJjFGhBosdZKjS8MWNeN5hkU2ov/Veqn7zuNc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3F7B99A83CCA3F49824F4D32F5518603@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4084fe57-b1a5-48ae-a358-08d68acf1f02
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Feb 2019 18:32:30.1002
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2317
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAyLTA0IGF0IDEzOjEzIC0wNTAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBJZiBuZnNfcGFnZV9hc3luY19mbHVzaCgpIHJlbW92ZXMgdGhlIHBhZ2UgZnJvbSB0
aGUgbWFwcGluZywgdGhlbiB3ZQ0KPiBjYW4ndA0KPiB1c2UgcGFnZV9maWxlX21hcHBpbmcoKSBv
biBpdCBhcyBuZnNfdXBkYXRlcGF0ZSgpIGlzIHdvbnQgdG8gZG8gd2hlbg0KPiByZWNlaXZpbmcg
YW4gZXJyb3IuICBJbnN0ZWFkLCBzaW1wbGlmeSBuZnNfemFwX21hcHBpbmcoKSB0byB0YWtlIHRo
ZQ0KPiBpbm9kZS4NCj4gDQoNCldvbid0IHRoaXMgYnJlYWsgTkZTIHN3YXA/DQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
