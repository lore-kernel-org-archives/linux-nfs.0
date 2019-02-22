Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 661F8C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 18:36:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 15A96207E0
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 18:36:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rutgers.edu header.i=@rutgers.edu header.b="SKDWw47X"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726109AbfBVSg5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 13:36:57 -0500
Received: from mail-eopbgr800090.outbound.protection.outlook.com ([40.107.80.90]:19781
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725878AbfBVSg5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 13:36:57 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=rutgers.edu;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lQ1EWoImVCwpaQYz5qRvjGhVY0RQzghMWuDwLYGRMsQ=;
 b=SKDWw47XOB2qx3ZQ//4g3uXMRJAS3ehH7AQy7FyQ5wfqlv+azeaJriW3tcxFz0G+N9oCJw+jZhZa/x7VxnSfFAG73Jk0hpDuXmRP5py/sXkXmDh61o6wRSegVpp1qBJDDRFBPkDRMQddm9ZWg9zveOi8s+gysI8S0IjPNqskv6s=
Received: from BN6PR1401MB2099.namprd14.prod.outlook.com (10.174.114.144) by
 BN6PR1401MB1956.namprd14.prod.outlook.com (10.174.114.137) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.14; Fri, 22 Feb 2019 18:36:54 +0000
Received: from BN6PR1401MB2099.namprd14.prod.outlook.com
 ([fe80::40dd:21b0:1915:6419]) by BN6PR1401MB2099.namprd14.prod.outlook.com
 ([fe80::40dd:21b0:1915:6419%12]) with mapi id 15.20.1643.018; Fri, 22 Feb
 2019 18:36:54 +0000
From:   Charles Hedrick <hedrick@rutgers.edu>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: bad principal used by gssd
Thread-Topic: bad principal used by gssd
Thread-Index: AQHUyt2VRBs/Joi/nkmdsAlhPvNd7Q==
Date:   Fri, 22 Feb 2019 18:36:54 +0000
Message-ID: <4F12379C-3DF3-4A9F-A2CB-087984214767@rutgers.edu>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hedrick@rutgers.edu; 
x-originating-ip: [2620:0:d60:ac1a:dc07:fc93:2977:336b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 988b765b-037e-47bf-556d-08d698f4b7d1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BN6PR1401MB1956;
x-ms-traffictypediagnostic: BN6PR1401MB1956:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCTjZQUjE0MDFNQjE5NTY7MjM6ckw4Zk1POWN5V2plVzFzMW8vUjZRY0pC?=
 =?utf-8?B?dHR5RFBXRHRhR016cmM2Sys5Q01pSGwvcW43S3MxNkE4OHV2TFhFQTVPeDAy?=
 =?utf-8?B?VGtEYmZnenRCVHVhWmFmcG8vS2FJejZDV2hpRUx2bVJRSERRbitXbjl5NGdB?=
 =?utf-8?B?eXVyRXdVUy9ONDNteGxsQzhJclhqYytIZ3dzd0h3cTBOWWU4bnRsL21IRFF1?=
 =?utf-8?B?MjFNREk5S3VYQlVJdTNlZzFGSlAzYzErcDFiSGFUOUk2S0ZiaWdQKytkUXBD?=
 =?utf-8?B?aEhHb3NsZytwOUpLQ3c0UUw0bGhOSW9wOWM0UTZEdTFwZ3NrbUFucjNSNXVC?=
 =?utf-8?B?OUFTc3BsNGpZQ3B2alR6cmFqL3lxM1paK3FodmxlOGpPbWZWMW9nUkZ6aUVL?=
 =?utf-8?B?dmN0QUZIcEtHQzZXR2NITFAxNDNKMnJacjJCM0NlM01ZTFN0UmN1RThjRE0y?=
 =?utf-8?B?cTJxN011dmV0bXRkUVlxRm1GYUtvdm9BNDdKT2ltbzg2ZjhPZ2RvajVFdUhv?=
 =?utf-8?B?WHJ5SVNmUEllYlcrcUZnRUZ3ZGZOUGs0ZDZzV3kwdXlCbU5hMXNTcTQ4Wi9U?=
 =?utf-8?B?eTZIOGV5bWVUK3RBVDlRcDFKRm9ZRHplTFZycU1RMUJXQzI2NVd2VUZjdUZJ?=
 =?utf-8?B?cmdXREwycmZjczRidE1MSWU5NWgzb0VaVUp3UEdkdmZJZzcxQ2lxS3dMTys1?=
 =?utf-8?B?T2w2N3B1ZmRIdTR6dEFqR0E2cHlybWN1RXZkZE9VQTZnWUxRMEk4Q0JlRndS?=
 =?utf-8?B?UHcyZDVMbXl3UUw4T1lnUkVRUjloc2xxcW5xY3hGMFRaVzNOUHl5THRrWnFy?=
 =?utf-8?B?OXVrN0tudlcyMm1sVG5vTmQ5U2JCayswK1M3REI1ck9wS3UwMFlYTTJISWZP?=
 =?utf-8?B?a29WR2xBZFVhcklUc28xRmFZTTlTSGtUR2FXVEZhTzNoOURGL1hPM2tKNkNy?=
 =?utf-8?B?dml5MWtndURObDJ5ZkVJZ0tzWE1HUUNSTUo1WHppcE9pdGZXRmxJUUQ4YjlT?=
 =?utf-8?B?Nm9KWS9veVl5Rm10U1dSTFVvczlxQjV3eS9RT3NZc01ERmk2UGZxQjFmNTJZ?=
 =?utf-8?B?SmFBZHZwYW5rTDF2eFQrenY2aHVIWHg0ZXMyTndzV25vNnBlUjNvMmRDZWJC?=
 =?utf-8?B?SERXQ2h0R0Vjd0xtcksxNmk5S0lPRGh1RkdzL1N3aGh3RXQ0S25aUjZBMDU5?=
 =?utf-8?B?cE4wNXlFVDFzczE1eGUvelRtZzRWQmdKU25VMnBuZGZGckFDdGVEVmIwTVBp?=
 =?utf-8?B?MHo0TU1RTVZSMW5ITnhpL1dPWTgxYVdOOWNSa3A0ZllERTNGK044eEc0MVdw?=
 =?utf-8?B?UVdIaWFoZVUxRUJ0MFFER3NDY3dxcUU1ZWVGQ3hSWnFDUURTdzQ0VFN6M0RI?=
 =?utf-8?B?aHVjUGJSTllYNFU2SVlMUnFNQkUxWFptRUVjRmcvS1VtbVQ0Y3QvMElmRjVJ?=
 =?utf-8?B?UFhHZ0N3R0craUtJTkdFUklVRnRQRUZiVmlETzlUNlZsMldwZVNUSlMwMmFt?=
 =?utf-8?B?anlMZjNiNXJNSHk5QlYxRGlmVncwY283c28veTcySUVzMk9vUUdJSnJGUHdo?=
 =?utf-8?B?WTNUWFpMODcvSXhWZVlIZ1l5OTQzRHJTUVdSL01lRmQ2MGs1Y0JoY3RBRWZH?=
 =?utf-8?B?S0tYcW9Fc0tYOTN0M1o1NmlZalB0SW5rQXlWYnROV1lQZjdoVFN5YlV2WUtm?=
 =?utf-8?Q?wMX0R4tzn3ujwKR7Kb00=3D?=
x-microsoft-antispam-prvs: <BN6PR1401MB19560485E1038CF9A7CBFF35AA7F0@BN6PR1401MB1956.namprd14.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(136003)(366004)(376002)(39860400002)(189003)(199004)(97736004)(83716004)(5640700003)(8936002)(6436002)(5660300002)(71200400001)(71190400001)(6486002)(33656002)(106356001)(81156014)(6916009)(81166006)(102836004)(6506007)(105586002)(786003)(2351001)(8676002)(82746002)(316002)(478600001)(14444005)(14454004)(2906002)(2616005)(4744005)(88552002)(75432002)(256004)(46003)(305945005)(25786009)(6512007)(53936002)(6306002)(36756003)(99286004)(86362001)(186003)(486006)(966005)(476003)(7736002)(68736007)(2501003)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR1401MB1956;H:BN6PR1401MB2099.namprd14.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: rutgers.edu does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: F6zUo2PhlB0oduIIuoH+g2Yf1S0J5/f8kxHitHnv2IdoJX90yeFtjTLQcZZlBR9ev2kyih2XePCOySOJg7Q7STK7zewGUt0N5tvlm4UI8cZIyImQFZTKNu8Olhps+oqNPdIJdYjoqOxHFi2rusaZ8iqhG6OfYAKpq93/O/cwmM1IGVz4vQw6WPseB9sCk0UfxrNMldQM/j4nKwQd0fi5X7L1TFDab9oSHJ7dyeEO06t9IMpPermHYjNXXuWcwVcGdTppje7dEl/0NaYGKOAKvbMd88XtazCrQ5AQEOFbAFf8EYdVJFDnhBAyV9jZWpEYb/gn7m2jhFDWeKbTsHzQhRtO+IPCG/ClTSAQgOnlFU8DZxk8NCm9X7PpXw+ZZ0jq6cTBofRASs8X7LMeZW8OgBTmoCK8eJpV9LTJGvO5rlA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F58A9E6728424440A54E3E3A20CF696C@namprd14.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: rutgers.edu
X-MS-Exchange-CrossTenant-Network-Message-Id: 988b765b-037e-47bf-556d-08d698f4b7d1
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 18:36:54.2044
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b92d2b23-4d35-4470-93ff-69aca6632ffe
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR1401MB1956
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

V291bGQgc29tZW9uZSBwbGVhc2UgbG9vayBhdCBodHRwczovL2J1Z3ppbGxhLmxpbnV4LW5mcy5v
cmcvc2hvd19idWcuY2dpP2lkPTMxOD8NCg0KSWYgSeKAmW0gbG9nZ2VkIGluIGFzIGhlZHJpY2sg
YnV0IGN1cnJlbnQgY3JlZGVudGlhbHMgYXJlIGhlZHJpY2suYWRtaW4sIEkgaGF2ZSBhIGtleSBy
aW5nIHdpdGggY3JlZGVudGlhbHMgZm9yIGJvdGggaGVkcmljayBhbmQgaGVkcmljay5hZG1pbi4N
Cg0KSWYgZ3NzZCBuZWVkcyB0byByZWNyZWF0ZSBpdHMgY29udGV4dCAoZS5nLiBiZWNhdXNlIHRo
ZSBjcmVkZW50aWFscyBoYXZlIGV4cGlyZWQpIGl0IGFjcXVpcmVzIEdTU0FQSSBjcmVkZW50aWFs
cyB3aXRoIE5PTkFNRS4gVGhhdCB3aWxsIGdpdmUgaXQgdGhlIGN1cnJlbnQgc2VsZWN0ZWQgcHJp
bmNpcGFsLCB3aGljaCBpcyBoZWRyaWNrLmFkbWluLiBPZiBjb3Vyc2UgZm9yIE5GUyBvbmx5IGEg
cHJpbmNpcGFsIHRoYXQgbWF0Y2hlcyB0aGUgY3VycmVudCBVSUQgY2FuIHdvcmsuIFNvIGxhdGVy
IGluIHRoZSBjb2RlIGl0IGNoZWNrcyB0byBzZWUgaWYgdGhlIGNyZWRlbnRpYWxzIGl0IGhhcyBh
cmUgZm9yIGhlZHJpY2ssIGFuZCBmYWlscy4gVGhpcyBpcyBraW5kIG9mIHNpbGx5LiBJZiB5b3Ug
dGVsbCBhY3F1aXJlIHdoYXQgY3JlZGVudGlhbHMgeW91IHdhbnQsIGl0IHdpbGwgbG9vayB0aHJv
dWdoIHRoZSBrZXlyaW5nIGFuZCBwaWNrIHRoZSByaWdodCBvbmUuIFNvIHRoZSBjYWxsIHRvIGFj
cXVpcmUgc2hvdWxkIHNwZWNpZnkgdGhlIGRlc2lyZWQgcHJpbmNpcGFsLg0KDQpUaGUgYnVnIHJl
cG9ydCBnaXZlcyBjb2RlIHRvIGZpeCBpdC4gQmVjYXVzZSBJIGRvbuKAmXQgd2FudCB0byBidWls
ZCBteSBvd24gZ3NzZCwgbXkgcGF0Y2ggdXNlcyBMRF9QUkVMT0FEIHRvIGludGVyY2VwdCBjYWxs
cywgYnV0IHRoZSBjb2RlIGNvdWxkIGJlIHB1dCBpbnRvIHRoZSBzb3VyY2UgaW4gdGhlIG9idmlv
dXMgd2F5Lg==
