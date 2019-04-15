Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE2E3C10F0E
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 16:24:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91DB32075B
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 16:24:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FUzOybzW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726988AbfDOQYo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Apr 2019 12:24:44 -0400
Received: from mail-eopbgr820129.outbound.protection.outlook.com ([40.107.82.129]:64805
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726034AbfDOQYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 Apr 2019 12:24:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2xgL6tT/fDCOMn3xkRIC6uGq3RcVVwNHQhiUWuIJNj8=;
 b=FUzOybzWsLeaicD2KtModM98g8OFTOpkTMQIkoq5NsT/B+GVJMvZCwrwL0KXSkP5hBW5dcmBQIEtVDyUz8MWDqrNAAkAesseyLNNBlwYbirlk8xwP/O7FmTqWnAJkTyMOq2OV1cWyVRjHLRxL4kh51YGWHEzuBtMWDsjJ+aR5G4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2558.namprd13.prod.outlook.com (52.135.96.18) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Mon, 15 Apr 2019 16:24:41 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1813.009; Mon, 15 Apr 2019
 16:24:41 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: error=Invalid slot
Thread-Topic: error=Invalid slot
Thread-Index: AQHU85ydVB0rnpfSJkGGMtmyhXgDYKY9YvYAgAABf4CAAAPDgA==
Date:   Mon, 15 Apr 2019 16:24:41 +0000
Message-ID: <eed8138c835abb5c9587f38aae6e3043df5b526d.camel@hammerspace.com>
References: <2996CEEE-0A1A-4C15-AA8B-A97E917D7924@oracle.com>
         <76d240e019d0ccc35bce05c1edb1ca104d7c18bf.camel@hammerspace.com>
         <32DC3CC2-700B-4F44-849C-F229BAA2CB57@oracle.com>
In-Reply-To: <32DC3CC2-700B-4F44-849C-F229BAA2CB57@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4760626d-1a91-4fc6-0c19-08d6c1bedcc9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600140)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2558;
x-ms-traffictypediagnostic: SN6PR13MB2558:
x-microsoft-antispam-prvs: <SN6PR13MB25586048B0019029A0266B98B82B0@SN6PR13MB2558.namprd13.prod.outlook.com>
x-forefront-prvs: 000800954F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(376002)(39830400003)(366004)(346002)(199004)(189003)(97736004)(446003)(476003)(99286004)(11346002)(2616005)(71190400001)(186003)(71200400001)(6916009)(118296001)(53936002)(6512007)(76176011)(486006)(3480700005)(2501003)(6246003)(106356001)(105586002)(2351001)(316002)(305945005)(68736007)(5660300002)(7736002)(6506007)(66066001)(26005)(478600001)(8936002)(256004)(8676002)(25786009)(81156014)(81166006)(102836004)(14454004)(4744005)(5640700003)(229853002)(36756003)(6116002)(3846002)(2906002)(6436002)(4326008)(86362001)(6486002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2558;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: GjjxyOwPJK90iVicAGV6ScWywWAvF8Hee4aRIM3Q9mj5GrTUvmBVL9DA1aDBxj/ReJ5YRzp09pNIeb2uSArA48YVt5Y9jQCHcWcRaLvIlHY4DeYy5RXxkV3dOS+cVkI/kDKKlLFebJ0cZ13ROGTP4WoDemiCgTKv+GW5GyJz0CRqZ1AJgySUTvMRmjNnCLe0imATjyNfaXHyXJ7NzNeNEsG2nwPBN41dm1fnwvmNXaeWp0oVRAr7AolYu/Q2wbPLuipaJB8AWaviNwsTRf7vC3SjR7gnTq4LpTBeA0VimeTJHm0gLvTsTc5knXtmxNkAc1U4CXCaNTECmd2WZe7Nx6KhBBh4FUvohgp3DPvL+2XPTsF+CwfmQBOT/zaPVMl4tR8WRd+7AXFO4dJyYeDCRUDoq5oPqGYTaGbyKwkHz28=
Content-Type: text/plain; charset="utf-8"
Content-ID: <1765B515CEB2364596EF0419FAE2CE84@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4760626d-1a91-4fc6-0c19-08d6c1bedcc9
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Apr 2019 16:24:41.0793
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2558
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTA0LTE1IGF0IDEyOjExIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiANCj4gSSB3YXMgYWJvdXQgdG8gdHJ5IHNvbWV0aGluZyBsaWtlIHRoaXMuDQo+IA0KDQpTbywg
dGhlIHJlYXNvbiBmb3IgdGhhdCBhcHByb2FjaCBpcyB0aGF0IEkgYmVsaWV2ZSB3ZSBjYW4gY3Vy
cmVudGx5DQpsZWFrIEVOT0JVRlMgYW5kIHBvc3NpYmx5IG90aGVyIGVycm9ycyBpbiBhZGRpdGlv
biB0byBFQkFEU0xUIHRocm91Z2gNCnRoZSBzYW1lIHJhY2UuDQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWts
ZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
