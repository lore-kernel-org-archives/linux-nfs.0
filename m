Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CECDC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 21:17:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A27EB2243E
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 21:17:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="BIvSy4/2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A27EB2243E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727642AbeKMHMT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 02:12:19 -0500
Received: from mail-eopbgr690122.outbound.protection.outlook.com ([40.107.69.122]:37475
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727595AbeKMHMT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Nov 2018 02:12:19 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=j0q1ktK/iHEXv0rHObP6nNzkNrIWVsLLDtNhUs9t/DY=;
 b=BIvSy4/2+Nsg6H6hNg6l52rGqFirWmXDQ8sBhWTYKp5UL09hufMYYZEJyczAQebn+U0TmtdTi+Tst2ZO4HaC35Stxlv8YmtlxPEuHesSzm4OfVr3QPfi4LuJqbqWlBXZL0iY0i1ZtYjqlPZHxQlBguwKiNuD1AnKoG2EovAGcC4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2365.namprd13.prod.outlook.com (52.135.94.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1339.11; Mon, 12 Nov 2018 21:17:17 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1339.019; Mon, 12 Nov 2018
 21:17:16 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "chucklever@gmail.com" <chucklever@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference in rpcauth_lookup_credcache
Thread-Topic: NULL dereference in rpcauth_lookup_credcache
Thread-Index: AQHUd6xJVdpNrPMTaUWtaTxXqXNyo6VHvSMAgAHSE4CAAuRdgIAABxgAgAAwJgA=
Date:   Mon, 12 Nov 2018 21:17:16 +0000
Message-ID: <2e62a77385b4e5d91e2ca9128313cf817c46a1ae.camel@hammerspace.com>
References: <20181108214452.GH6090@fieldses.org>
         <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
         <20181110214939.GA16755@fieldses.org>
         <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
         <20181112182454.GE16755@fieldses.org>
In-Reply-To: <20181112182454.GE16755@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2365;6:ePQlRAtOmy1Je9Hsv1eK76jyQGegVV6IaylkeSfVkqaPDVzqy3KnSUMWf1Sz7l3qe7G2O3Kxl6i/z7x4JpKDQoII2wFoSEf7XY2/zNLNPkzrxvqG98qhdMdjBZ0Sny0hWXIIHZWpwRERo/ewA8a2tZrWpAOepr5QQ8QfoHvpCi00iWpHPyOR8/okL6YlJXcsnesNRe4hBGYTq1gAcjnX58YxJO41+hGnxuG1eJamI8+jhSNm/QG8kmSMZ2hWFWL/dwbTrVkdumvcaMZHPFSOf+hxHWltZniXm2l1jL2cPdblSxh9BR3+seM4gSiFOtnIrS+H7RQfy/qDrozEB1QxbS7ndatkFIJZBpd0mz0N9HcV92F+Th+MYc7FeEpgonUyr+nB8c1XYIzMA+neLGLbsvxEAvdP9QxmK0oSLNfRkefbxDl0T/1LoGG4uinsch32ha98sE2MY38o+VAKZDzShw==;5:3lMoQRxgkpOBjCGsTljULAAli/qXrQOFWRhOmZrcJR1WZILyMsW0GrK5BaPwd/Ltk8dZWyRmVoDkUOFbXeKlAHI1eWAdyMd3uoC/VgmrwTWcKLLXji/l2qeEn7p4XCh6hJhz9ul7yc1s7EEGonIzEUJAePr3s4ZrIwQwEe5DAmw=;7:y+3/agF4PGVqDKRyN8YJLV8W2bwcesnOr+nuJTubQRUNDWtGkh5hcgddf+DVd9D/RBcGdIUqpiOs2O3rmZqPbHT9hPzefUyrguFOmVY+toAJHdnMoU16PP11nmfRZ69YgPLgR55sTxa1WAlrsXbZFw==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: cfe8afa9-31a4-42eb-a382-08d648e43940
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390040)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2365;
x-ms-traffictypediagnostic: SN6PR13MB2365:
x-microsoft-antispam-prvs: <SN6PR13MB23655F4069CB92DA65AD859BB8C10@SN6PR13MB2365.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3231382)(944501410)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123562045)(20161123558120)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2365;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2365;
x-forefront-prvs: 0854128AF0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(366004)(376002)(136003)(39830400003)(199004)(189003)(6116002)(81166006)(8936002)(486006)(3846002)(2616005)(102836004)(11346002)(5660300001)(478600001)(446003)(2906002)(2351001)(476003)(39060400002)(6512007)(26005)(5640700003)(66066001)(229853002)(118296001)(6486002)(6436002)(186003)(6916009)(8676002)(2501003)(81156014)(1730700003)(256004)(53936002)(2900100001)(76176011)(105586002)(14454004)(25786009)(97736004)(93886005)(6506007)(316002)(68736007)(106356001)(54906003)(4326008)(7736002)(86362001)(305945005)(99286004)(71200400001)(71190400001)(4001150100001)(36756003)(6246003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2365;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: fcOAImC/tYpq4PSeh0ET+y5oQnXTeIEdd3csFYLsf7424SQl1sme951+n/QIF3f0C1BRJQhbXu3OPM2D9xcSiBfi54hfG4sn/NBJjCH0IUIY3+F2aqMO7B8bgyy25bkYMFRieWRt/pAUeTpYhxbVKvILb9FCez9e9iz0f8KjMdSeiCVAbyQgzqDA0ambSkPGsV174aHzl3tBWMQ9O9Kj2o2ZaCTEDzIJA+UNDVcJ6zILNTUgJHuUrwLctmy6wOyQA48j4czzuaB/c/etZmO5a1YTAq1r2a1YsyFTh6WfmMm09Dcgo2QL5KsueCUhC5Fj7TOgqPBQDbs4YmAY28lclqJ484I6oNWMVupTgBFrd2s=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <5734EE478B0EF74A9B7DF4ADA2900A0C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cfe8afa9-31a4-42eb-a382-08d648e43940
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Nov 2018 21:17:16.8673
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2365
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTExLTEyIGF0IDEzOjI0IC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gTW9uLCBOb3YgMTIsIDIwMTggYXQgMDU6NTk6MzNQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIFNhdCwgMjAxOC0xMS0xMCBhdCAxNjo0OSAtMDUwMCwg
QnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiA+ID4gTG9va3MgbGlrZSBpdCdzIHRoZSBmYXVsdCBvZg0K
PiA+ID4gDQo+ID4gPiAwN2QwMmE2N2I3ZmFhZSAiU1VOUlBDOiBTaW1wbGlmeSBsb29rdXAgY29k
ZSINCj4gPiANCj4gPiBJJ20gaGF2aW5nIHRyb3VibGUgcmVwcm9kdWNpbmcgdGhpcyBidWcuIEkn
dmUgdHJpZWQgYm90aCBjdGhvbiBhbmQNCj4gPiB4ZnN0ZXN0cyBpbiBhIGxvb3AsIHNvIGZhciB3
aXRob3V0IHN1Y2Nlc3MgKGJvdGggTkZTdjMgYW5kIHY0LjEsDQo+ID4gYnV0DQo+ID4gb25seSBz
ZWM9c3lzKS4gSXMgdGhlcmUgYW55dGhpbmcgZWxzZSB5b3UncmUgZG9pbmcgdGhhdCBJIG1pZ2h0
DQo+ID4gdHJ5Pw0KPiA+IA0KPiA+IGUuZy4gQXJlIHlvdSBydW5uaW5nIG11bHRpcGxlIHdvcmts
b2FkcyBpbiBwYXJhbGxlbD8gRGlmZmVyZW50DQo+ID4gdXNlcnM/Li4NCj4gDQo+IE5vdGhpbmcg
dGhhdCBpbnRlcmVzdGluZy4gIEN1cnJlbnRseSBpdCdzIGNvbm5lY3RhdGhvbiBvdmVyIHY0LCB2
MywNCj4gdjQva3JiNSwgdjMva3JiNSwgdjQva3JiNWksIHY0L2tyYjVwLCB2NC4xLCB2NC4xL2ty
YjUsIGJ1dCBqdXN0DQo+IHNlcmlhbGx5DQo+IG9uZSBhZnRlciB0aGUgb3RoZXIuICBUaGVuIHNv
bWUgcHluZnMgdGVzdHMgKHdoaWNoIGJ5cGFzcyB0aGUNCj4gY2xpZW50KSwNCj4gdGhlbiB4ZnN0
ZXN0cyBvdmVyIHY0LjIvc3lzLiAgQW5kIGFsc28gYSBmZXcgb25lLW9mZiBsb2NraW5nIHRlc3Rz
IG9mDQo+IG15DQo+IG93biB0aGF0IHByb2JhYmx5IGFyZW4ndCBhIGZhY3RvciBoZXJlLg0KPiAN
Cj4gKEhhaCwgSSBqdXN0IHJlYWxpemVkIEkgd2FzIG1vdW50aW5nIHdpdGggdmVycz00IGFuZCBh
c3N1bWluZyB0aGF0DQo+IG1lYW50DQo+IDQuMCwgYnV0IGFjdHVhbGx5IGl0J3MgY2hhbmdlZCBv
dmVyIHRpbWUgZGVwZW5kaW5nIG9uIHRoZSBkZWZhdWx0cywNCj4gc28NCj4gY3VycmVudGx5IHRo
b3NlICJ2NCIgcnVucyBhcmUgYWN0dWFsbHkgYWxsIDQuMi4gIEdhaC4pDQoNCkFyZSB5b3UgcGVy
aGFwcyBib3RoIHVzaW5nIFJQQ1NFQ19HU1Mgdy8gaW50ZWdyaXR5IGNoZWNraW5nIGZvciB5b3Vy
DQpFWENIQU5HRV9JRCBhdXRoZW50aWNhdGlvbj8gVGhlIGNsaWVudCB3aWxsIGF0dGVtcHQgdG8g
dXNlIHRoYXQgYnkNCmRlZmF1bHQgaWYgcnBjLmdzc2QgaXMgcnVubmluZy4NCg0KSSBhc2sgYmVj
YXVzZSBJIHRoaW5rIHRoZSBpc3N1ZSBtaWdodCBiZSB3aXRoIFJQQ1NFQ19HU1MsIHNwZWNpZmlj
YWxseQ0Kd2l0aCB0aGUgUlBDU0VDX0dTUyBjb250ZXh0IGRlc3Ryb3kgY29kZSwgaGVuY2UgdGhl
IDIgcGF0Y2hlcyB0aGF0IEkNCmp1c3Qgc2VudCBvdXQuDQoNCkNoZWVycw0KICBUcm9uZA0KDQot
LSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJz
cGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
