Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F210C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:18:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B074C2082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DwDCmHMW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B074C2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726871AbeLAJ3l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:29:41 -0500
Received: from mail-eopbgr730105.outbound.protection.outlook.com ([40.107.73.105]:18944
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725867AbeLAJ3l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 04:29:41 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=L/hPMC0+7bvcpI1wvt0Klzj6yslFKZpsMfEkZULaxNA=;
 b=DwDCmHMWdfL4H99lHqtzCxCB4HQRjOB9rfNiDGogic8kGqZvxuqQzJAwQEesF3QuZLRhSqNZiD+TDxYaKt/9apgO/Qu5O44bS/jrqOZdNMXxKry65gV7+Lta21hGHQE0VnZxQANUos8FvP1j3RzNWUmQYweYqyYMSk3Ui0SNni0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2397.namprd13.prod.outlook.com (52.135.94.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1382.12; Fri, 30 Nov 2018 22:18:50 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 22:18:50 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Topic: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Index: AQHUiPekUfCRRl/oV0O8KonnDr8pv6Vo4moAgAAA+wA=
Date:   Fri, 30 Nov 2018 22:18:50 +0000
Message-ID: <545d13619ffe92a69097f8f68fc36df85944cac2.camel@hammerspace.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
         <20181130215555.91107-2-trond.myklebust@hammerspace.com>
         <20181130215555.91107-3-trond.myklebust@hammerspace.com>
         <E9450F2D-D888-4EFC-B0BD-6506E4EC2887@oracle.com>
In-Reply-To: <E9450F2D-D888-4EFC-B0BD-6506E4EC2887@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2397;6:cUJXcucD1/bx1ieOVt31Y5FEsJujaigTSdN30MF5LhCc1gwfDaqdzDAoXonvq0xnKCYckNjvxkfu5hYaShIJj0pF7hYScz+5dq4HMLuGX19WggoGYJDkJyVH+aRX4izMhV6Tt/QlwJNIonHUpYXtIKCeakFBYiAknscVpO+FSrZMinM+vW8+AT368yyZNhhH/nH/ZIDQWE067Qt6I1qLPmWgqZJ9OVII8q3fApxOVsk0Xq5q40A90h89WFGhR1iHfiY7IvFsVqCOIktM+VNjT4jn9ymsylE70hIlnOcOahLhSsOGCUykOvOQ9t8Fz9/4VpqVzCwaeR4WczofuxheZUGF/uDC5/zDFI0wL419cZaNQ1UNP/m6ez40s7Gt/ioeKPPzxeRTUbgiuyP4vm70lZuC3dghUd1sBzB4WH0PDO4JZQ7kvv9LAa5HyTmMvWIc9WeaweWP2a2o+wDIDo/NmQ==;5:pQ5v4epBW1+i+Rf5xGTJ4j0NLn7peHbhLdd7JP4HW6ki01vfKlNkMw4F1wZ/znuV7X4CdLxIwnGDA/6T9KFjcp3rkgZmpHehdvrxxbrvIvyFmAOThjfU0JqqC+4AqXWa62IaYadd8AhzqIqwgPVGeXCmQlESxzhBHkcr6tGIyzY=;7:W+m5OUHwaB5yAXkvb3BylRjkuODlUADaqfDVOSVMem340LhFhwx3Nvruyny2mh63UIudYl0rqze8AipFTtFlwwnfm7d3ux/UmM71xi9s4Jqa7y2QFsGZCM3WoNbygfdsmIdkuDWxF9Z06GZJR0evbQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 14543a68-b3ae-4cdf-8820-08d65711ce46
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2397;
x-ms-traffictypediagnostic: SN6PR13MB2397:
x-microsoft-antispam-prvs: <SN6PR13MB2397341DC3A373196B26F3FBB8D30@SN6PR13MB2397.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3231453)(999002)(944501410)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123562045)(20161123560045)(20161123564045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2397;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2397;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39830400003)(396003)(136003)(376002)(346002)(199004)(189003)(81166006)(14444005)(71200400001)(71190400001)(256004)(2906002)(3846002)(6116002)(316002)(478600001)(97736004)(4001150100001)(14454004)(25786009)(36756003)(6512007)(7736002)(53936002)(305945005)(186003)(76176011)(53546011)(68736007)(2351001)(486006)(26005)(11346002)(6506007)(446003)(2501003)(6246003)(2616005)(476003)(229853002)(5660300001)(93886005)(118296001)(8936002)(81156014)(8676002)(5640700003)(86362001)(66066001)(6916009)(105586002)(102836004)(6436002)(106356001)(6486002)(99286004)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2397;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 90lo6sCwN078+GlnoBx/RJfLEc0RcKKXwtXp088z+L2nDRzzZuKIqBhfpZ0/lowZsX8aizA3C/QUuR8UaTPyIEXX2cvLP0Tzh1OHI/5GJLZ+1cWP2PreFytmjvnOZ3dkK7tECI77yNqYIaSk0n6fYFrx3BkwcDr6BzGd70ykIviE9v/61Ls7WU52+4GfzvZ3ItAMqs1+Ji14UDP+9uFOd2D75fetJeK0WJB7j/qesGjFb8k62YUPVcUpBsQNPc9r72XwDwBd+QoH3mOQeiCCgrHRKEj35sYaP5F+cwH3yeDbiElfcYZLRhsC57XhYmRCgX5iyIJUrV45dhkTj3Z4DDKhGuwskaC5f+spQZd1j/I=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <C1907E68948DF4479FE182F0805990D4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 14543a68-b3ae-4cdf-8820-08d65711ce46
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 22:18:50.5062
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2397
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE3OjE1IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBOb3YgMzAsIDIwMTgsIGF0IDQ6NTUgUE0sIFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBn
bWFpbC5jb20+DQo+ID4gd3JvdGU6DQo+ID4gDQo+ID4gQSBjYWxsIHRvIGdzc193cmFwX3JlcV9w
cml2KCkgd2lsbCBlbmQgdXAgcmVwbGFjaW5nIHRoZSBvcmlnaW5hbA0KPiA+IGFycmF5DQo+ID4g
aW4gcnFzdHAtPnJxX3NuZF9idWYucGFnZXMgd2l0aCBhIG5ldyBvbmUgY29udGFpbmluZyB0aGUg
ZW5jcnlwdGVkDQo+ID4gZGF0YS4gSW4gb3JkZXIgdG8gYXZvaWQgaGF2aW5nIHRoZSBycXN0cC0+
cnFfc25kX2J1Zi5idmVjIHBvaW50IHRvDQo+ID4gdGhlDQo+ID4gd3JvbmcgcGFnZSBkYXRhLCB3
ZSBuZWVkIHRvIHJlZnJlc2ggdGhhdCB0b28uDQo+IA0KPiBJIHdvdWxkIGFkZCBhIG5vdGUgaGVy
ZSB0aGF0IHRoaXMgcGF0Y2ggZml4ZXMgYSBtZW1vcnkgbGVhay4gQW5kDQo+IHlvdSBtaWdodCB3
YW50IHRvIGFkZCBhIEZpeGVzOiB0YWcuDQo+IA0KDQpJdCBvbmx5IGFwcGxpZXMgdG8gbmV3IGNv
ZGUgdGhhdCB3ZW50IGludG8gNC4yMCwgc28gaXQgd29uJ3QgbmVlZCBhbnkNCnN0YWJsZSBiYWNr
cG9ydGluZy4NCg0KVGhhdCBzYWlkLCBJJ20gcmVhbGlzaW5nIChzbG93bHkgLSBhcHBhcmVudGx5
IEknbSBhc2xlZXAgdG9kYXkpIHRoYXQNCnRoaXMgaXMgcmVjZWl2ZSBzaWRlIGNvZGUsIHNvDQoN
CmEpIFRoZSBjb250ZW50cyBvZiBycV9zbmRfYnVmIGFyZSBpcnJlbGV2YW50Lg0KYikgV2Ugd2Fu
dCB0byBiZXdhcmUgb2YgY2hhbmdpbmcgaXQgd2hpbGUgdGhlcmUgaXMgYSBjb3B5IGluDQpycV9w
cml2YXRlX2J1Zi4NCg0KSU9XOiBhIHY0IGlzIGZvcnRoY29taW5nLg0KDQo+IEknbSB0cnlpbmcg
aXQgb3V0IG5vdy4NCj4gDQo+IA0KPiA+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gPiAtLS0NCj4gPiBpbmNsdWRlL2xp
bnV4L3N1bnJwYy94ZHIuaCB8IDEgLQ0KPiA+IG5ldC9zdW5ycGMveHBydC5jICAgICAgICAgIHwg
MiArKw0KPiA+IG5ldC9zdW5ycGMveHBydHNvY2suYyAgICAgIHwgMSArDQo+ID4gMyBmaWxlcyBj
aGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4gPiANCj4gPiBkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9zdW5ycGMveGRyLmgNCj4gPiBiL2luY2x1ZGUvbGludXgvc3Vu
cnBjL3hkci5oDQo+ID4gaW5kZXggNDMxMDZmZmE2Nzg4Li4yZWMxMjgwNjAyMzkgMTAwNjQ0DQo+
ID4gLS0tIGEvaW5jbHVkZS9saW51eC9zdW5ycGMveGRyLmgNCj4gPiArKysgYi9pbmNsdWRlL2xp
bnV4L3N1bnJwYy94ZHIuaA0KPiA+IEBAIC03Miw3ICs3Miw2IEBAIHhkcl9idWZfaW5pdChzdHJ1
Y3QgeGRyX2J1ZiAqYnVmLCB2b2lkICpzdGFydCwNCj4gPiBzaXplX3QgbGVuKQ0KPiA+IAlidWYt
PmhlYWRbMF0uaW92X2Jhc2UgPSBzdGFydDsNCj4gPiAJYnVmLT5oZWFkWzBdLmlvdl9sZW4gPSBs
ZW47DQo+ID4gCWJ1Zi0+dGFpbFswXS5pb3ZfbGVuID0gMDsNCj4gPiAtCWJ1Zi0+YnZlYyA9IE5V
TEw7DQo+ID4gCWJ1Zi0+cGFnZXMgPSBOVUxMOw0KPiA+IAlidWYtPnBhZ2VfbGVuID0gMDsNCj4g
PiAJYnVmLT5mbGFncyA9IDA7DQo+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydC5jIGIv
bmV0L3N1bnJwYy94cHJ0LmMNCj4gPiBpbmRleCA4NmJlYTQ1MjBjNGQuLjEyMmM5MWMyOGU3YyAx
MDA2NDQNCj4gPiAtLS0gYS9uZXQvc3VucnBjL3hwcnQuYw0KPiA+ICsrKyBiL25ldC9zdW5ycGMv
eHBydC5jDQo+ID4gQEAgLTE2MjMsNiArMTYyMyw4IEBAIHhwcnRfcmVxdWVzdF9pbml0KHN0cnVj
dCBycGNfdGFzayAqdGFzaykNCj4gPiAJcmVxLT5ycV9zbmRfYnVmLmJ1ZmxlbiA9IDA7DQo+ID4g
CXJlcS0+cnFfcmN2X2J1Zi5sZW4gPSAwOw0KPiA+IAlyZXEtPnJxX3Jjdl9idWYuYnVmbGVuID0g
MDsNCj4gPiArCXJlcS0+cnFfc25kX2J1Zi5idmVjID0gTlVMTDsNCj4gPiArCXJlcS0+cnFfcmN2
X2J1Zi5idmVjID0gTlVMTDsNCj4gPiAJcmVxLT5ycV9yZWxlYXNlX3NuZF9idWYgPSBOVUxMOw0K
PiA+IAl4cHJ0X3Jlc2V0X21ham9ydGltZW8ocmVxKTsNCj4gPiAJZHByaW50aygiUlBDOiAlNXUg
cmVzZXJ2ZWQgcmVxICVwIHhpZCAlMDh4XG4iLCB0YXNrLT50a19waWQsDQo+ID4gZGlmZiAtLWdp
dCBhL25ldC9zdW5ycGMveHBydHNvY2suYyBiL25ldC9zdW5ycGMveHBydHNvY2suYw0KPiA+IGlu
ZGV4IGFlNzdjNzFjMWY2NC4uNjE1ZWYyMzk3ZmM1IDEwMDY0NA0KPiA+IC0tLSBhL25ldC9zdW5y
cGMveHBydHNvY2suYw0KPiA+ICsrKyBiL25ldC9zdW5ycGMveHBydHNvY2suYw0KPiA+IEBAIC04
NDMsNiArODQzLDcgQEAgc3RhdGljIGludCB4c19ub3NwYWNlKHN0cnVjdCBycGNfcnFzdCAqcmVx
KQ0KPiA+IHN0YXRpYyB2b2lkDQo+ID4geHNfc3RyZWFtX3ByZXBhcmVfcmVxdWVzdChzdHJ1Y3Qg
cnBjX3Jxc3QgKnJlcSkNCj4gPiB7DQo+ID4gKwl4ZHJfZnJlZV9idmVjKCZyZXEtPnJxX3Jjdl9i
dWYpOw0KPiA+IAlyZXEtPnJxX3Rhc2stPnRrX3N0YXR1cyA9IHhkcl9hbGxvY19idmVjKCZyZXEt
PnJxX3Jjdl9idWYsDQo+ID4gR0ZQX05PSU8pOw0KPiA+IH0NCj4gPiANCj4gPiAtLSANCj4gPiAy
LjE5LjINCj4gPiANCj4gDQo+IC0tDQo+IENodWNrIExldmVyDQo+IA0KPiANCj4gDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
