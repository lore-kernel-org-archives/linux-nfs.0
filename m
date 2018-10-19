Return-Path: <SRS0=a6gn=M7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF0BAECDE3D
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 16:13:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8595820838
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Oct 2018 16:13:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="aubhYkJu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8595820838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727641AbeJTAUm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Oct 2018 20:20:42 -0400
Received: from mail-eopbgr730119.outbound.protection.outlook.com ([40.107.73.119]:53885
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727603AbeJTAUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 20:20:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4HbBnb00i6+zMZV5dyIyFhpZhGw7A3495R22UX6yMuE=;
 b=aubhYkJulB3xscj2sf800/SZZiUZ3YGuUNGTQ+CwzUYtZQMZcbZ1z3lPLJ01X4Gk9OdQmtJIdeSN2l4uf69Y+zE7fr8Y5XFrZm/CG7UtMSZdCO5QBS8hKVKzF3u4LJpg/kqxYjIkxs1B7DhoTXbcooV4YDY/fI3SKPLIU1OG5t4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2413.namprd13.prod.outlook.com (52.135.94.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1250.18; Fri, 19 Oct 2018 16:13:52 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1273.012; Fri, 19 Oct 2018
 16:13:52 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
Thread-Topic: [PATCH v1 01/11] fs: Don't copy beyond the end of the file
Thread-Index: AQHUZ8CKiMl5nzeT10epp+ijvWPRr6UmvfAA
Date:   Fri, 19 Oct 2018 16:13:52 +0000
Message-ID: <4bbd2e38cf388629e50a9c1eb35a458786afa858.camel@hammerspace.com>
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
         <20181019152932.32462-2-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152932.32462-2-olga.kornievskaia@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2413;6:g/ZYeC/6gWneyyGHGMKpoQvZjzhe9XyaJ21BNqztY9fQ7vX9gq5YY3Pf1qzdFSzoqz4L+5AakMdeS2Kgp5eBQwCpsUeAMpNsmCVmqTrIDekman8w/XtILyytgTj1h+Xo57tMDHD0FBq97Xo3AMMczKVlObofJQUImcKfKOkT4onygQZbd1cJmKx2XUVAP7dWChRb7FrplrmE945vsQaCiIziRkImIWUkALdcTkU/xgKOMTcfvN1T3bQuOidRDXLN4SNk/jKuSB7EJVhHfn+HBKqonmbq/hdYdiiZAOVl2thwIggMLLCeW3we8Y09jRYt8NAvIkSFOA/ffNlCXfO0elFkiwWPwMT1Ek/s45kLY+bP7LBEi4OdPhgXXlJd7pXEb/JsrpT1VuJnodqKzKJpI1MBgC1RjEkpowpvyyzvsgEOoW4y3AkevXj+POP+ISu/a7+R3vIkJR5pq41R9Fdt8Q==;5:CH729/mqiq/aCvp21JgFemc27ryJPuWLf+pvgz5f7Ad1jITbag/fObXrPcSKr0sLl1TI4DxDMqJm0zeHz+dq5i1byhSBZeYkhIOJdsnU8PG3nb1SL/VNAG8sUkLZ4ne/8jI8GPGa43Ygm6dN8jakOA+ZbupDVGpWtBanwXGFRD8=;7:v4oUzDuhupV6erlK8/Z6APgjDOsue8+23FkJCoyC2OjImzBwBhbenBuMR79++hyPoWaS2328XQCyOgc1nBxeDyRwtaq38vR4ZTI2pjlDCYtn5Q+yh994SutSN9C7w2UW4MpEdQJv1K/Yw4GhXkIvBZMu0ImWpw2dCOfsz7SlXHMDse0kQUN+7wAx3MTo6qKgmZpVNuuNMyvUgGwZ/6WsI09yo0nDDIU3bPPGpktFn+J9FloHM/niSU6R71ud5S7P
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f171278f-bcd6-4dba-279d-08d635dddc91
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2413;
x-ms-traffictypediagnostic: SN6PR13MB2413:
x-microsoft-antispam-prvs: <SN6PR13MB24133F664B6EA6CB2A880AF4B8F90@SN6PR13MB2413.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(3231355)(944501410)(52105095)(93006095)(93001095)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(20161123560045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2413;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2413;
x-forefront-prvs: 0830866D19
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39840400004)(136003)(346002)(396003)(376002)(366004)(189003)(199004)(4326008)(76176011)(7736002)(39060400002)(6246003)(8676002)(102836004)(316002)(6512007)(86362001)(81166006)(81156014)(53936002)(3846002)(6116002)(8936002)(305945005)(256004)(118296001)(476003)(25786009)(478600001)(11346002)(446003)(486006)(6506007)(2616005)(14454004)(66066001)(4001150100001)(26005)(229853002)(97736004)(186003)(106356001)(6346003)(105586002)(2900100001)(2906002)(54906003)(5660300001)(110136005)(71190400001)(6486002)(6436002)(36756003)(2501003)(5250100002)(99286004)(68736007)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2413;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-message-info: 8B3Sa96kRwKhCtwtCSdVnHS287KgH14qWnnkDsfiIbeA7JubBQ5ydxRMyXtbZDbLtRdPAQc17sNzP98z8vwrMzp3PI6P+dyvx27JMmE6+pXl78nIRloO1Y4jaz/Mywq8fbEmyOpyvSFzp1jC/SHdUikTjNgWpmD/+nbSLovMkpDGMxxLkOhfv7mz1Rx9/C3niFLA2vtDfW0NptEgAO000tV3A5z7nIpvt+IKaQhGMf8EoPV+rZUVMEs1rU4XcrwXSo1a1YZZ/iTprwpDao7rKTO0TyLnHChpVMl4kiWKbSoHPXETpdtnXRdH6JNs6GpD356b78AWXe0fXe5FwxMyCG19Aysldt5y1xOCFShRIB4=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <605EE2FB08AFFC46996F0F87AA5F8481@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f171278f-bcd6-4dba-279d-08d635dddc91
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Oct 2018 16:13:52.2798
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2413
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
Message-ID: <20181019161352.JqDLd8YxGI2kGZ-Vb6ozLHJJCBs-n12KM6BZ3snPfT4@z>

T24gRnJpLCAyMDE4LTEwLTE5IGF0IDExOjI5IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogQW5uYSBTY2h1bWFrZXIgPEFubmEuU2NodW1ha2VyQE5ldGFwcC5jb20+DQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBBbm5hIFNjaHVtYWtlciA8QW5uYS5TY2h1bWFrZXJATmV0YXBw
LmNvbT4NCj4gLS0tDQo+ICBmcy9yZWFkX3dyaXRlLmMgfCAzICsrKw0KPiAgMSBmaWxlIGNoYW5n
ZWQsIDMgaW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL3JlYWRfd3JpdGUuYyBi
L2ZzL3JlYWRfd3JpdGUuYw0KPiBpbmRleCAzOWI0YTIxLi5jNjA3OTBmIDEwMDY0NA0KPiAtLS0g
YS9mcy9yZWFkX3dyaXRlLmMNCj4gKysrIGIvZnMvcmVhZF93cml0ZS5jDQo+IEBAIC0xNTcwLDYg
KzE1NzAsOSBAQCBzc2l6ZV90IHZmc19jb3B5X2ZpbGVfcmFuZ2Uoc3RydWN0IGZpbGUNCj4gKmZp
bGVfaW4sIGxvZmZfdCBwb3NfaW4sDQo+ICAJaWYgKHVubGlrZWx5KHJldCkpDQo+ICAJCXJldHVy
biByZXQ7DQo+ICANCj4gKwlpZiAocG9zX2luID49IGlfc2l6ZV9yZWFkKGlub2RlX2luKSkNCj4g
KwkJcmV0dXJuIC1FSU5WQUw7DQo+ICsNCj4gIAlpZiAoIShmaWxlX2luLT5mX21vZGUgJiBGTU9E
RV9SRUFEKSB8fA0KPiAgCSAgICAhKGZpbGVfb3V0LT5mX21vZGUgJiBGTU9ERV9XUklURSkgfHwN
Cj4gIAkgICAgKGZpbGVfb3V0LT5mX2ZsYWdzICYgT19BUFBFTkQpKQ0KDQpUaGlzIHBhdGNoIHJl
cXVpcmVzIGFuIEFDSyBmcm9tIHRoZSBWRlMgbWFpbnRhaW5lcnMgaWYgSSdtIHRvIHB1c2ggaXQN
CnVwc3RyZWFtLg0KQ2M6IEFsIGFuZCBMaW51eC1mc2RldmVsLg0KDQotLSANClRyb25kIE15a2xl
YnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
