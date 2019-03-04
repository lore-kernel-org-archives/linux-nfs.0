Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C50E6C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:21:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E97720823
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="TCwRdDhc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726098AbfCDQVb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 11:21:31 -0500
Received: from mail-eopbgr700118.outbound.protection.outlook.com ([40.107.70.118]:19616
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726082AbfCDQVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 11:21:31 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=A2BlPJrarTXb+MYi19I7FGL7TPegJOJX6EQdR0JVoXY=;
 b=TCwRdDhcWnhPBQKLLgmCZq5kiPbcgb0CXNBVtlXq2mn3z0NDLCS/Kb0msSdLkIdcKfWf0ijjGkqKM14lJJdtQX28kfogI8oPvc4DgT6oljUnpRRr9u9tOPmmaKk0qHEulq6lgwSsfZ/IwErkyEO7u4AwF9aJXUigTM4zRdB/LaI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2367.namprd13.prod.outlook.com (52.135.94.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.11; Mon, 4 Mar 2019 16:19:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1686.016; Mon, 4 Mar 2019
 16:19:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
Thread-Topic: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
Thread-Index: AQHU0p+GWIUi+XSmkUiwgoUZcRbqDKX7ofyAgAAA44CAAAEUgIAAARsAgAAB24A=
Date:   Mon, 4 Mar 2019 16:19:48 +0000
Message-ID: <532a63f71cb1cb39db5a883e84920c9a816a6369.camel@hammerspace.com>
References: <20190304153222.27638.90558.stgit@manet.1015granger.net>
         <ddaf320c5c7a4e90f7a1b034fbbabf9bba899fea.camel@hammerspace.com>
         <E8DA13E4-5164-4092-A695-B9F11E6D28F9@oracle.com>
         <b9eda570bb50902d28a498c9f6a67f9b7d959cbf.camel@hammerspace.com>
         <9DDE8951-8A91-4E79-92C6-C07F2824DC52@oracle.com>
In-Reply-To: <9DDE8951-8A91-4E79-92C6-C07F2824DC52@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3b33ff35-2621-43f2-bab9-08d6a0bd38e9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2367;
x-ms-traffictypediagnostic: SN6PR13MB2367:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzY3OzIzOnk5S0l0T1ZjOGNxaS9ieG5GV1JNcit1OU0v?=
 =?utf-8?B?NENxc21UQkFmamFYM0J0a0FmOG96dDJWdHNaaWtJcU1vaWc4UWU1am9BSkN2?=
 =?utf-8?B?RytLSVFKb2oyVnJBZzRkcDhWWjRzUWVDUlVSWWVrWFNMa0RlRDI5NmxjSzgw?=
 =?utf-8?B?YjYxejV2U3M3UUc1aTVQUm1HVi8rU0JQYy9BVHllZXZ5djAxTmdSbDNiZSt6?=
 =?utf-8?B?clZBQlhDTE5aNkNHOGRONmgwd0ZQY3p4QzBldnY4ZUZ5RElBY3ROMCtjMURh?=
 =?utf-8?B?aGQ2TzhYcDlYdGRkaklzOUd2NUw4N2NySWNid0hwK1A4NWRwTlVDSDA3a011?=
 =?utf-8?B?eWdrbVdyMVJjT0p1SHo2ZGhVNVRhOWp3d0NEN2NJbEZReTJwYzlwU284bDFh?=
 =?utf-8?B?VW9FVE9MVVo3Qi9pR1dsMjVnSFlQVzNmaEc5UVN0UUsyRTVXTERCdWVDUWJR?=
 =?utf-8?B?MHFkY2Rndzc4Y2VXSENEVXBINE1YdzM4MmlQZUNvSlAzbk5iRjFjQTc3WmhX?=
 =?utf-8?B?eHp0WG9uOS9EVE5iT0RpREN2eXllZlRIZjlXSitGekdJT2cwQmRxVGI1UHAr?=
 =?utf-8?B?VllOMGliOFFwdG5UVC9OaU5nS2hMTU5sN0dmTGh6Q21CaS81clI3c0YycWJ6?=
 =?utf-8?B?cXFXYkx5Z0FGNlhXTDlKd1hYbzg1dTJsWHppUGpFWVh1cmR3WFlIR0dnSXhP?=
 =?utf-8?B?ODA1Yk1EaVpUSFpEOFk1cm93bHdSd1ZvTlZmSTNLN0U4OFAvL3NTdDMrU095?=
 =?utf-8?B?c21VWENaZ1VpNDAvK05kVlNGZ3ZBME02QlNSY2pxaUlGL1Z3b0Q2YjhkMFNS?=
 =?utf-8?B?bENkRE1jbml2SHJHcXlRQkl5USt6bTNYa0dNRW1tTFZqRW5TR3FGaU1iVGRS?=
 =?utf-8?B?T0czaUlERG0yenZtMlROTTZxeFNvVjV5NVM5aTB4cXFTbjl5eC9EZXh1SXZ0?=
 =?utf-8?B?UEt2Y2RLa0o5cmpDNDNyM05Dc2RlbEIxbkxjS0Uxek5BRm9EdzNSL3VhZFdL?=
 =?utf-8?B?a3hGVWswSkpteDBjSVdNWGNjMUNscHVmUXQ5T1lrMjRtaXpJSEVDWmdlV283?=
 =?utf-8?B?OWtzK3VzVkNkZWM2UDRaLzFxWG5RTytRbDZ6L01GenRSajFQRWNFUitVcEp1?=
 =?utf-8?B?Q2JZaVdqUjdyampwMGxUbXdzNlNtMFpUVEFaTmMxcm9pSFk2ZkRzZG1NWXc0?=
 =?utf-8?B?cWZWdWxYSnpac3FvV0hhemduNERoTkt0eUVTMkkybVJ1aVJLcHordmdwbXo4?=
 =?utf-8?B?eUxWU3locXhGclhtSm1mVHU0a1pOZmhFTDVMTk1NTTNLTkVtREhqTTBnR1Yr?=
 =?utf-8?B?Ujg3WE1rSWplS1pMelZWN1hNMTdLekpQTFpiU1IrYWd1VnFhYTh6dnVwSEhs?=
 =?utf-8?B?YXhpMWV4WjdqNE92RWdZcUcvVWRXQjc4RFRRREhPM2lMSEI3eWh2YzZvbEVZ?=
 =?utf-8?B?eDJQY2JiT05jSTVGSGsrdEo4cGU4NG8yS3hmMEZhVVNRWHdTcStHelZzUSsx?=
 =?utf-8?B?bDFNUVNkd0oycVFkQUhib2RoQVJGQkxVdmxLOFM5bHpQK2F2SWVLSGxoUVVY?=
 =?utf-8?B?WFhVMHFwVjZhbjRQTENVWUlLYUxaT2RlVmg4TzJrbkxCZGNucitEYk1zZit5?=
 =?utf-8?B?NU1SRVhDQXhwcmRTNURoY2NVSWVQY2hIeW5Wd1Q4VGp4cmtMVSs4c015TXow?=
 =?utf-8?B?VUk5T2NYMFJSWWZSYzREZmpPbzRRMlE2a2E2V3dpOVpSOU41K2g4NXFzUzJo?=
 =?utf-8?B?NHZtZzY3QS92KzltUnUxWFhGckIvNkRJb0R4V01jL0lWditMSzk2T0hseHhO?=
 =?utf-8?Q?BbcOMYvFKSLhR?=
x-microsoft-antispam-prvs: <SN6PR13MB23677A340C1CDC054729EB78B8710@SN6PR13MB2367.namprd13.prod.outlook.com>
x-forefront-prvs: 09669DB681
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39830400003)(346002)(136003)(376002)(199004)(189003)(6116002)(71200400001)(106356001)(26005)(229853002)(93886005)(5660300002)(53546011)(6506007)(105586002)(102836004)(316002)(6346003)(5640700003)(3846002)(305945005)(68736007)(2906002)(6916009)(7736002)(2616005)(4326008)(476003)(15974865002)(446003)(11346002)(25786009)(14454004)(53936002)(478600001)(2501003)(186003)(97736004)(6486002)(6436002)(76176011)(71190400001)(2351001)(99286004)(6512007)(36756003)(81156014)(486006)(6246003)(81166006)(14444005)(256004)(86362001)(118296001)(8936002)(8676002)(66066001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2367;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: QvKRf1bLjw2X7ctLNUccMkTWdiSBggW167wqxIomYJotppPf+6OrQ1xFVailndIbDBV/2+TheHuoTeGTatWwppho6YKwnvhTY8ud86ifi4Z/TKr9fFOaJSx+8bd37CjhRIfs9b5NfTxapIrf/F43UMO2b2sOOMKqpupm8LP/1acFTRGbFWWBqrXIikpNmCLu+w10FIW8nxXjmk+I2g23auOauTaWtzQ8TQ7c7d8RNvP0pHjJ2D+RgsYRsw5efb/AVA0ho9jFJ7k00+CHuvk8xRQR51gLMeikCQ4quJixwAnDE9w5kO33iOmHhX+JCbHDaao3fTW0fzZlhZCaMbeKf5w8Aj85Ptdn8itjHmkRLbpCETSdH0XftcWF3frahSK9SULwuFhpqzh8H+onJo5636tx3cwkymtfvxCur2X7Xxg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B4089A626B588048903CA6204A059E90@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3b33ff35-2621-43f2-bab9-08d6a0bd38e9
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Mar 2019 16:19:48.1927
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2367
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAzLTA0IGF0IDExOjEzIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBNYXIgNCwgMjAxOSwgYXQgMTE6MDkgQU0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIE1vbiwgMjAxOS0wMy0w
NCBhdCAxMTowNSAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIE1hciA0LCAy
MDE5LCBhdCAxMTowMiBBTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gdHJvbmRteUBoYW1t
ZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gT24gTW9uLCAyMDE5LTAzLTA0
IGF0IDEwOjMyIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+ID4gPiBQYWdlIGFsbG9j
YXRpb24gcmVxdWVzdHMgbWFkZSB3aGVuIHRoZSBTUEFSU0VfUEFHRVMgZmxhZyBpcw0KPiA+ID4g
PiA+IHNldA0KPiA+ID4gPiA+IGFyZQ0KPiA+ID4gPiA+IGFsbG93ZWQgdG8gZmFpbCwgYW5kIGFy
ZSBub3QgY3JpdGljYWwuIE5vIG5lZWQgdG8gc3BlbmQgYQ0KPiA+ID4gPiA+IHJhcmUNCj4gPiA+
ID4gPiByZXNvdXJjZS4NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBDaHVj
ayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gPiA+ID4gPiAtLS0NCj4gPiA+ID4g
PiBuZXQvc3VucnBjL3NvY2tsaWIuYyAgICAgICAgICAgfCAgICAyICstDQo+ID4gPiA+ID4gbmV0
L3N1bnJwYy94cHJ0cmRtYS9ycGNfcmRtYS5jIHwgICAgMiArLQ0KPiA+ID4gPiA+IDIgZmlsZXMg
Y2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPiA+ID4gPiA+IA0KPiA+
ID4gPiA+IGRpZmYgLS1naXQgYS9uZXQvc3VucnBjL3NvY2tsaWIuYyBiL25ldC9zdW5ycGMvc29j
a2xpYi5jDQo+ID4gPiA+ID4gaW5kZXggN2U1NWNmYy4uOWZhZWExMiAxMDA2NDQNCj4gPiA+ID4g
PiAtLS0gYS9uZXQvc3VucnBjL3NvY2tsaWIuYw0KPiA+ID4gPiA+ICsrKyBiL25ldC9zdW5ycGMv
c29ja2xpYi5jDQo+ID4gPiA+ID4gQEAgLTEwNiw3ICsxMDYsNyBAQCBzdGF0aWMgc2l6ZV90DQo+
ID4gPiA+ID4geGRyX3NrYl9yZWFkX2FuZF9jc3VtX2JpdHMoc3RydWN0DQo+ID4gPiA+ID4geGRy
X3NrYl9yZWFkZXIgKmRlc2MsIHZvaWQgKnRvLA0KPiA+ID4gPiA+IAkJLyogQUNMIGxpa2VzIHRv
IGJlIGxhenkgaW4gYWxsb2NhdGluZyBwYWdlcyAtDQo+ID4gPiA+ID4gQUNMcw0KPiA+ID4gPiA+
IAkJICogYXJlIHNtYWxsIGJ5IGRlZmF1bHQgYnV0IGNhbiBnZXQgaHVnZS4gKi8NCj4gPiA+ID4g
PiAJCWlmICgoeGRyLT5mbGFncyAmIFhEUkJVRl9TUEFSU0VfUEFHRVMpICYmDQo+ID4gPiA+ID4g
KnBwYWdlID09DQo+ID4gPiA+ID4gTlVMTCkgew0KPiA+ID4gPiA+IC0JCQkqcHBhZ2UgPSBhbGxv
Y19wYWdlKEdGUF9BVE9NSUMpOw0KPiA+ID4gPiA+ICsJCQkqcHBhZ2UgPSBhbGxvY19wYWdlKEdG
UF9OT1dBSVQgfA0KPiA+ID4gPiA+IF9fR0ZQX05PV0FSTik7DQo+ID4gPiA+ID4gCQkJaWYgKHVu
bGlrZWx5KCpwcGFnZSA9PSBOVUxMKSkgew0KPiA+ID4gPiA+IAkJCQlpZiAoY29waWVkID09IDAp
DQo+ID4gPiA+ID4gCQkJCQljb3BpZWQgPSAtRU5PTUVNOw0KPiA+ID4gPiANCj4gPiA+ID4gSG1t
Li4uIENhbid0IHdlIG1ha2UgdGhpcyBHRlBfS0VSTkVMPyBJIGNhbid0IHNlZSB0aGF0IHdlJ3Jl
DQo+ID4gPiA+IGhvbGRpbmcNCj4gPiA+ID4gYW55IGxvY2tzIGhlcmUuDQo+ID4gPiANCj4gPiA+
IFdlJ3JlIGhvbGRpbmcgdGhlIHRyYW5zcG9ydCBzZW5kIGxvY2suIFNpbmNlIHRoaXMgaXMgYW4g
b3JkZXIgMA0KPiA+ID4gYWxsb2NhdGlvbg0KPiA+ID4gaXQncyB1bmxpa2VseSB0byBmYWlsIGV2
ZW4gd2l0aCBhIGxlc3MgYWdncmVzc2l2ZSByZXF1ZXN0IGxpa2UNCj4gPiA+IE5PV0FJVC4NCj4g
PiANCj4gPiBXZSBzaG91bGQgb25seSBiZSBob2xkaW5nIHRoZSByZWNlaXZlIG11dGV4LiBUaGF0
IHByZXZlbnRzIG90aGVycw0KPiA+IGZyb20NCj4gPiBjbG9zaW5nIHRoZSBzb2NrZXQgKG9yIHN0
YXJ0aW5nIGEgc2Vjb25kIHJlY2VpdmUgd29ya2VyKSBidXQgdGhhdCdzDQo+ID4gYWxsLg0KPiAN
Cj4gT0ssIEkgZ3Vlc3MgdGhlIFVEUCBhbmQgUlBDLW92ZXItUkRNQSBjYXNlcyBhcmUgZGlmZmVy
ZW50LiBGb3IgUkRNQSwNCj4gdGhpcyBhbGxvY2F0aW9uIGlzIGRvbmUgaW4gLT5zZW5kX3JlcXVl
c3QuDQoNClJpZ2h0LiBNeSBjb21tZW50IHdhcyBvbmx5IGludGVuZGVkIHRvIGFwcGx5IHRvIHRo
ZSBVRFAgY2FzZS4NCg0KPiA+IE9UT0gsIHRoZSBvbmx5IHRoaW5nIHVzaW5nIHRoaXMgbWVjaGFu
aXNtIG9uIFVEUCBzaG91bGQgYmUgdGhlDQo+ID4gTkZTdjIvdjMNCj4gPiBBQ0wgcmVjZWl2ZSBj
b2RlLCBzbyBJJ20gbm90IHJlYWxseSBzdXJlIGFueW9uZSBjYXJlcy4NCj4gDQo+IFRydWUuIEhv
d2V2ZXIsIGFzIEkndmUgc2FpZCBiZWZvcmUsIHRoZSByaWdodCBmaXggZm9yIHRoaXMgaXMgdG8N
Cj4gZ2V0IHJpZCBvZiBTUEFSU0VfUEFHRVMgYW5kIGVuc3VyZSB0aGF0IE5GUyBhbHdheXMgYWxs
b2NhdGVzIGVub3VnaA0KPiByZWNlaXZlIGJ1ZmZlciBzcGFjZSBkdXJpbmcgQ2FsbCBlbmNvZGlu
Zy4gQnV0IGl0J3Mgbm90IGNsZWFyIGFueW9uZQ0KPiBjYXJlcyBlbm91Z2guDQo+IA0KPiBXaWxs
IHRoZSBjdXJyZW50IHBhdGNoIGJlIGFjY2VwdGFibGUsIG9yIGRvIHlvdSB3YW50IG1lIHRvIHVz
ZSBhDQo+IHNoYXJwZXIgc3RpY2sgd2hlbiBhbGxvY2F0aW5nPw0KDQpJdCBzaG91bGQgYmUgZmlu
ZS4NCg0KPiANCj4gPiA+ID4gSXQgZG9lcyBsb29rIGxpa2Ugc3ZjX3VkcF9yZWN2ZnJvbSgpIGlz
IHdyYXBwaW5nIHRoZQ0KPiA+ID4gPiBjYWxsIHRvIGNzdW1fcGFydGlhbF9jb3B5X3RvX3hkcigp
IGluIGENCj4gPiA+ID4gbG9jYWxfYmhfZGlzYWJsZSgpL2VuYWJsZSgpDQo+ID4gPiA+IHBhaXIs
IGJ1dCBpcyB0aGF0IGFjdHVhbGx5IG5lZWRlZD8gSWYgc28sIGZvciB3aGF0Pw0KPiA+ID4gPiAN
Cj4gPiA+ID4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy94cHJ0cmRtYS9ycGNfcmRtYS5jDQo+
ID4gPiA+ID4gYi9uZXQvc3VucnBjL3hwcnRyZG1hL3JwY19yZG1hLmMNCj4gPiA+ID4gPiBpbmRl
eCA2YzFmYjI3Li5iNzU5YjE2IDEwMDY0NA0KPiA+ID4gPiA+IC0tLSBhL25ldC9zdW5ycGMveHBy
dHJkbWEvcnBjX3JkbWEuYw0KPiA+ID4gPiA+ICsrKyBiL25ldC9zdW5ycGMveHBydHJkbWEvcnBj
X3JkbWEuYw0KPiA+ID4gPiA+IEBAIC0yMzgsNyArMjM4LDcgQEAgc3RhdGljIGJvb2wgcnBjcmRt
YV9yZXN1bHRzX2lubGluZShzdHJ1Y3QNCj4gPiA+ID4gPiBycGNyZG1hX3hwcnQgKnJfeHBydCwN
Cj4gPiA+ID4gPiAJCSAqLw0KPiA+ID4gPiA+IAkJaWYgKHVubGlrZWx5KHhkcmJ1Zi0+ZmxhZ3Mg
Jg0KPiA+ID4gPiA+IFhEUkJVRl9TUEFSU0VfUEFHRVMpKSB7DQo+ID4gPiA+ID4gCQkJaWYgKCEq
cHBhZ2VzKQ0KPiA+ID4gPiA+IC0JCQkJKnBwYWdlcyA9DQo+ID4gPiA+ID4gYWxsb2NfcGFnZShH
RlBfQVRPTUlDKTsNCj4gPiA+ID4gPiArCQkJCSpwcGFnZXMgPSBhbGxvY19wYWdlKEdGUF9OT1dB
SVQNCj4gPiA+ID4gPiB8DQo+ID4gPiA+ID4gX19HRlBfTk9XQVJOKTsNCj4gPiA+ID4gPiAJCQlp
ZiAoISpwcGFnZXMpDQo+ID4gPiA+ID4gCQkJCXJldHVybiAtRU5PQlVGUzsNCj4gPiA+ID4gPiAJ
CX0NCj4gPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gPiA+IENoZWVycw0KPiA+ID4gPiBUcm9uZA0K
PiA+ID4gPiAtLSANCj4gPiA+ID4gVHJvbmQgTXlrbGVidXN0DQo+ID4gPiA+IExpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCj4gPiA+ID4gdHJvbmQubXlrbGVidXN0QGhh
bW1lcnNwYWNlLmNvbQ0KPiA+ID4gDQo+ID4gPiAtLQ0KPiA+ID4gQ2h1Y2sgTGV2ZXINCj4gPiA+
IA0KPiA+ID4gDQo+ID4gPiANCj4gPiAtLSANCj4gPiBUcm9uZCBNeWtsZWJ1c3QNCj4gPiBMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQo+ID4gdHJvbmQubXlrbGVidXN0
QGhhbW1lcnNwYWNlLmNvbQ0KPiANCj4gLS0NCj4gQ2h1Y2sgTGV2ZXINCj4gDQo+IA0KPiANCi0t
IA0KVHJvbmQgTXlrbGVidXN0DQpDVE8sIEhhbW1lcnNwYWNlIEluYw0KNDMwMCBFbCBDYW1pbm8g
UmVhbCwgU3VpdGUgMTA1DQpMb3MgQWx0b3MsIENBIDk0MDIyDQp3d3cuaGFtbWVyLnNwYWNlDQoN
Cg0K
