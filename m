Return-Path: <SRS0=a6gn=M7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6AB7ECDE43
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 15:47:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4CFFD20658
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 15:47:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Iz4UFiBp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CFFD20658
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726967AbeJSXyJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Oct 2018 19:54:09 -0400
Received: from mail-bl2nam02on0135.outbound.protection.outlook.com ([104.47.38.135]:32800
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726935AbeJSXyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 19:54:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=p3EIUci5JQaVg2VX2pcdfwfKcRWnYcZjtXoLE+Gh4aM=;
 b=Iz4UFiBp7nc1+RFkKf034nfYQcyDhwau/2za3oULTjl4rHW3ohoVk2y/J2xbdX+NCdZ6cCF4me1YiyNdhyt6YF4/9rXuJdurGEURTRc2+do/ubulo9vORa6sc030088TNnJm3WMj+DHWxE893oIcC2Wcc/1xskVWYJvtxtxIwss=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2384.namprd13.prod.outlook.com (52.135.94.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1250.15; Fri, 19 Oct 2018 15:47:25 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1273.012; Fri, 19 Oct 2018
 15:47:25 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: review of v4.20 linux-next merge commit
Thread-Topic: review of v4.20 linux-next merge commit
Thread-Index: AQHUZ7cOGvhaDheNOEC3d5QJy9vQM6Umtp+A
Date:   Fri, 19 Oct 2018 15:47:25 +0000
Message-ID: <2a1d19f8ccdb5c936aff29badf0f66a19e2bf645.camel@hammerspace.com>
References: <2177F9CF-E9E8-4E10-AD14-E53F0F5F9574@oracle.com>
In-Reply-To: <2177F9CF-E9E8-4E10-AD14-E53F0F5F9574@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2384;6:MNypYpdsx+gyb3t11OQaT0M5uri3bG9Im+rmC0E+PTM8jBMq8XD+9N0agaELreHmuUFlgCRNGSv6zHzZ/Xm2vI4YVdIvTSgcx479nR9Ta/GtjpiL773v0nJetSRNA/o81yPUk2lSRQdWPVapYt8h2A7pYEzpPx+MwLff2Yggh3/sIh9L2I401ZsX/VMysQxGdpVHJsMOz766ljCqsPQpPg1uLxcuDn3SWC12mim9C/EUe1Vhr8tOyLImqChx0SxccCRfQI5Xb3cQveGyQw/oBFeE+eIKK0tynhKMAEIzXJzG7HKaTs7xJC1/p/tRXgycc6prtry7cfNejUd+s603tIC7ahnJph0+cy3Cduuv8Y62JGlw8cSuFsa5Nc2G43NyW79vTswoHqpb/3iXlYlnKuhDOKNpppTN/cv0FI/Mbn1v10KCTlL16KTbTeXXFQGmhUPMfwV5XCTzvWnxXRPwew==;5:whN7XP3QgpbQ8xgSxELz2k6JLPDGQakHyIe7YQ3noejC/CS1mvdNNq60vOwMGuemQcSy5G6cU062+s+H+fp+U4EMpg4pUGNCWW6ZEmuSkRHwYQJEy7Q4Ih0cvNDvDojuhBhTNyHAWeosMakbzBfNiHqvAPWP/MYiW973BF90eOE=;7:/c/FElVPbXx4dEWcK/Wy3zFCYYLmuPmvPS23jq9mq6D8xg74h7iki9Q+SmQD7BP1HngY91DvE/CzNNHUA/JEXz4lRRkvfTUrAMa1//lkHVRV7kE5SHcdKN/KYqRp0jgee5rzp3VvqFr9vFPTGBs7jOiLFGnoZIC9hF2fh7iEC+FoHBVyrE+76HPb7uw/HsSGPCT0yLzPw8Fw2i4J6G3izvy1wzK1BYQap5VsC8qkPnH3xSX1jxpLqel0UwfiVUX2
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 6f741f34-8016-479c-9f51-08d635da2a9f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2384;
x-ms-traffictypediagnostic: SN6PR13MB2384:
x-microsoft-antispam-prvs: <SN6PR13MB238444C472B452844A3E7949B8F90@SN6PR13MB2384.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3002001)(3231355)(944501410)(4982022)(52105095)(10201501046)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123560045)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2384;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2384;
x-forefront-prvs: 0830866D19
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(376002)(396003)(136003)(39840400004)(189003)(199004)(229853002)(81166006)(2351001)(105586002)(2501003)(76176011)(476003)(2616005)(99286004)(5250100002)(26005)(106356001)(93376004)(446003)(6506007)(86362001)(11346002)(478600001)(7736002)(305945005)(486006)(14454004)(71190400001)(71200400001)(66066001)(966005)(6116002)(6916009)(68736007)(8936002)(5640700003)(6436002)(53936002)(6512007)(3846002)(6346003)(102836004)(118296001)(8676002)(256004)(4001150100001)(186003)(6246003)(4326008)(2906002)(5660300001)(25786009)(6306002)(2900100001)(6486002)(97736004)(81156014)(316002)(36756003)(15302535012);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2384;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-message-info: +R/6r8cyZmkps19XGZe5wnM2C7TQo0yavK9BdTBicFqmmIVF8cWgHJCSOeztaIoYUi7O1SVPsLsKqcGG5n0PWxHa9yI13+betcDYm4Enjr1kWGLNjNx5YxPKpdi8f5FhvhdvsCGv54XlFvhM0l0A9iOYTWlnyYacrGfuE0D/AIRD7rl7utYC+IBv4w19kEKOn22K7mG/heD+zO53L+fN1exm5WERPgInhMMWeSW0LrMjuVYG2dOc0r+4UHxzkvhiMZFxtoovNGrIiWtidmsoPbH6Et50RE0Pq0JCRkUc8jWyECNHEcKh7cCZNyo2bzWqar0EW0jjfswfY8KDZN/Hm8jy2ng6PAnAhjI0g1qYnyM=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <0776D183A6BF0540ACD64DA826B5C4B3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6f741f34-8016-479c-9f51-08d635da2a9f
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Oct 2018 15:47:25.1406
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2384
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
Message-ID: <20181019154725.Qe_SROBJRBhJxIhR0jqfPRuWtxFlyfsvG-ZYm7EWAZA@z>

T24gRnJpLCAyMDE4LTEwLTE5IGF0IDEwOjIxIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
DQpodHRwOi8vZ2l0LmxpbnV4LW5mcy5vcmcvP3A9dHJvbmRteS9saW51eC1uZnMuZ2l0O2E9Y29t
bWl0ZGlmZjtoPTkzYmRjZjlmZGI4OTY0NmU5NDQ2ZmFiMjVhZWM3NmE3NTQ5Njk2MTkNCj4gDQo+
IEkgZG9uJ3Qgc2VlIGEgcHJvYmxlbS4NCj4gDQo+IA0KDQpDb29sISBUaGFua3MgZm9yIGNoZWNr
aW5nLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
LCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
