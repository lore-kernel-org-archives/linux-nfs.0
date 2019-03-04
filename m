Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92639C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:09:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 43C18206B6
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 16:09:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="rYT7KutN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726984AbfCDQJQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 11:09:16 -0500
Received: from mail-eopbgr700127.outbound.protection.outlook.com ([40.107.70.127]:12320
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726430AbfCDQJQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 11:09:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=66vl1snRiEH/nmMid/nb56hETJqOrbzXexxrLqGIoIk=;
 b=rYT7KutNbLeZiRUlzfDGXC4ohpmGMQnVUPiPV/xWRszyMttHHx0oclV3SvG0vNKBzPN1iRyBE29gM6xKdkTOpdq4XLmT6ERHGsQo2jhQsj52LmvcEdcSpZVRdGBjlFUsfJ63TAkjvX2o/rN0ddi5vDTZJu3UFGEhAcHSdixQ3t4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2285.namprd13.prod.outlook.com (52.135.94.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.9; Mon, 4 Mar 2019 16:09:11 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1686.016; Mon, 4 Mar 2019
 16:09:11 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
Thread-Topic: [PATCH RFC] SUNRPC: Avoid digging into the ATOMIC pool
Thread-Index: AQHU0p+GWIUi+XSmkUiwgoUZcRbqDKX7ofyAgAAA44CAAAEUgA==
Date:   Mon, 4 Mar 2019 16:09:11 +0000
Message-ID: <b9eda570bb50902d28a498c9f6a67f9b7d959cbf.camel@hammerspace.com>
References: <20190304153222.27638.90558.stgit@manet.1015granger.net>
         <ddaf320c5c7a4e90f7a1b034fbbabf9bba899fea.camel@hammerspace.com>
         <E8DA13E4-5164-4092-A695-B9F11E6D28F9@oracle.com>
In-Reply-To: <E8DA13E4-5164-4092-A695-B9F11E6D28F9@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d3a62aca-59c7-4960-a49e-08d6a0bbbd6d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2285;
x-ms-traffictypediagnostic: SN6PR13MB2285:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMjg1OzIzOnFOblJrRkc4UUx1TGdsOHYvTUtnck45Snkw?=
 =?utf-8?B?YWtleVI1N3VDbVhxandXMlBjODRNRFhORGpCR0RxSFJocUk2djkrTENuaFBV?=
 =?utf-8?B?c01melBPd1QzMElDa2ZzSjhTQ012Mkt6T0FIL2kvS29ST1hEYlorVzFoOHBC?=
 =?utf-8?B?eTdGdjB1RklZTElCWUdZbDAvbERjQWVuRXRmajVCR3VyOWtlQzZmenhqNWJs?=
 =?utf-8?B?SG9VOXowMkdHS1VYdmI5Nm92eG9FbWUxaGJxd2VCd1ZyZVBnUzFJZTg5dUhS?=
 =?utf-8?B?T1A1OHg1UmRKUjlQeXB3ZXFHdUhPeDdtNHRseTUvYVg0Ny9BM0tFSGZaUEdV?=
 =?utf-8?B?ck11cUpSSC9USEJHMXJCanp4aDhRV1lIdVB2OFlPQlJKQ3FRcXNNRmxqQStH?=
 =?utf-8?B?SExZZDBkZ0FoQTdiajBOaFREaGNOM3B2WFNVT3JlTDh3MEljQXU1dmtaSjNr?=
 =?utf-8?B?czZ2NlNaVGtjbDRLN3QvV3dwc2k0b0szbjJWOHJjd2VjaVRRS01GZVlNRDhH?=
 =?utf-8?B?VUdQeUNhSllDZzM5WTNxalh2Q1E4cEhBZjQ0djJLWkF5UFJFdk1oV2pibmpP?=
 =?utf-8?B?c3V1cFFlSWoyNmRTVzJEeFRqTE1xUmlHcGV0UXRhL0pDYU9RTW93RDdWRHdL?=
 =?utf-8?B?SXdzS1hka3JMc3FEMElVeHpvbWg0dWhiYm1XdGtWejF2UnFQcXhVcitlUE1R?=
 =?utf-8?B?UTVXWjBwVy9Pc0ZoL2hIUjBCZ1JmYmtoM09tSDVpY3FCdDhqN1lVSkpKdFRj?=
 =?utf-8?B?U2ZNdnNybmpWd25JSUpnYjhheE83cXBaVFVVazBHL05jSzkvVnpPTVhhV0Rh?=
 =?utf-8?B?czVqMUdiQmh2TXlvSzhERDZKdmFHaTZhbm1nVS9GVW9sK1lNNnJFN3A0bHZh?=
 =?utf-8?B?cEo5OUw3cW5IUkhiQVFSMU5jUWZQREdFcmVBMEJkR3FzTG9yejVvSFViNGd1?=
 =?utf-8?B?dnpweFhwMG1Ec2MyNXFlZTdpclgvL1BrRk1vNUl1ckFmT1E1b0JKRm9NQjNl?=
 =?utf-8?B?NE8zeFltVDl3QXU2N0pyRDFvNHR1Z1VWRE02d1ZoRHRSNmZkODdaa25DYXFh?=
 =?utf-8?B?ajFMRjhWbHdJWlcveU41cmJCSmhYSkNBRWNTNU10ckM4L1dBY2Q4cE1HcFEz?=
 =?utf-8?B?bldPNmwyK09FcTBnUHpQeXltb2FMcWtzb3E0SEI5aWdiYVZ0TkM4TTV0Z1lZ?=
 =?utf-8?B?WHNLK3BBYjcrMG00WWkwTStjaG9LT0pDMkpGNEZzdG1vYXNkZmZqc2Z4YkpR?=
 =?utf-8?B?bmZNTmdaUG4wQkc2UkVRRUwyMnJNck5PUWdyeTd6aTB2TStaU3ZqZkEyVmZs?=
 =?utf-8?B?eXQ5UE9FK1lkVitXNTBva0lKY3ptUzVFVDN0SDY5YVNubkY3SGVFQ2RXQ0Vu?=
 =?utf-8?B?S1N1M2tvNGdka25yL2QzaTZ3VW1vcWlMS1lZNW9tbHE2c3l4K3NBTzFsMUI5?=
 =?utf-8?B?dEQzSFFnSTRSc0R1WjlFZi9YWlNMMmNOT3V0UjhmQjZQdUlmRm1OK0w3U1I1?=
 =?utf-8?B?YVdWSy9WNTM5dlkyNnFmR1BreEpXc0YySXdpTCswdkNVdGp1RThuZ0pwbjJl?=
 =?utf-8?B?ZXRrSFRHZkluNFVYQ2lEYnlBVVNsU2ZtaFAxbFV4dzFtV2xjTmk1MnNLS0FX?=
 =?utf-8?B?bklDVG1pbm80N001MjhNbzYveFNMMXJGUkVZT29TRnRTeWNVa2V2RUxKZXVF?=
 =?utf-8?Q?beU7lW3IlBi9N5zHLrFaVV56i5WxcwqSRLp5JLa?=
x-microsoft-antispam-prvs: <SN6PR13MB2285479481B31166F3FBE8F9B8710@SN6PR13MB2285.namprd13.prod.outlook.com>
x-forefront-prvs: 09669DB681
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(376002)(366004)(396003)(346002)(189003)(199004)(6116002)(14454004)(97736004)(86362001)(6246003)(478600001)(53936002)(76176011)(106356001)(446003)(11346002)(118296001)(6436002)(66066001)(3846002)(81156014)(316002)(81166006)(5640700003)(8936002)(2501003)(305945005)(6486002)(7736002)(256004)(14444005)(8676002)(26005)(25786009)(2906002)(6512007)(36756003)(2616005)(476003)(186003)(102836004)(99286004)(6506007)(68736007)(53546011)(2351001)(229853002)(486006)(4326008)(71200400001)(71190400001)(5660300002)(105586002)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2285;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6r+jseNs8mrGsbHPnUsPibc/NoeSpx3av5SGqW+/RnvAXCZoyjgrpe6HtGEUe77hE2vjRuOCGi2d9JOI6GyZtkN5Bgs9i0bRPfbwRmm2uR4VJ/0J9brSAidtfVkXclXndCvcB0eAjgv1F7Aj8IeRC2AWaR23PcWkuxEW8VoW4tkmgEbyfRP2eqI0I5UVW3Cu3EZP/uY/6tsnMFP3PpcK6efEhHuG4X4q438ynIVpIRtky75AKkUu6i8z66kuhiVd3JQSnqVoih+MARiRtuKPi9p9nibuJxlFUFYNlifAgC8nL7vREO/guhgTSNC10OHbKPRMz/f0sTHgm7vx0MZZQgxx4+0sdVvBg9gIAKRc9TSFQmKbKr+Q089Q19PMCiTJkTY9NLNBR5lp6s4g21ZF+iSgujWmUO8hhUmKIu4Tko4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2A3BA741D2084849A2ADE9689011F171@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d3a62aca-59c7-4960-a49e-08d6a0bbbd6d
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Mar 2019 16:09:11.5680
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2285
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAzLTA0IGF0IDExOjA1IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBNYXIgNCwgMjAxOSwgYXQgMTE6MDIgQU0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIE1vbiwgMjAxOS0wMy0w
NCBhdCAxMDozMiAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiBQYWdlIGFsbG9jYXRp
b24gcmVxdWVzdHMgbWFkZSB3aGVuIHRoZSBTUEFSU0VfUEFHRVMgZmxhZyBpcyBzZXQNCj4gPiA+
IGFyZQ0KPiA+ID4gYWxsb3dlZCB0byBmYWlsLCBhbmQgYXJlIG5vdCBjcml0aWNhbC4gTm8gbmVl
ZCB0byBzcGVuZCBhIHJhcmUNCj4gPiA+IHJlc291cmNlLg0KPiA+ID4gDQo+ID4gPiBTaWduZWQt
b2ZmLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gPiA+IC0tLQ0K
PiA+ID4gbmV0L3N1bnJwYy9zb2NrbGliLmMgICAgICAgICAgIHwgICAgMiArLQ0KPiA+ID4gbmV0
L3N1bnJwYy94cHJ0cmRtYS9ycGNfcmRtYS5jIHwgICAgMiArLQ0KPiA+ID4gMiBmaWxlcyBjaGFu
Z2VkLCAyIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQo+ID4gPiANCj4gPiA+IGRpZmYg
LS1naXQgYS9uZXQvc3VucnBjL3NvY2tsaWIuYyBiL25ldC9zdW5ycGMvc29ja2xpYi5jDQo+ID4g
PiBpbmRleCA3ZTU1Y2ZjLi45ZmFlYTEyIDEwMDY0NA0KPiA+ID4gLS0tIGEvbmV0L3N1bnJwYy9z
b2NrbGliLmMNCj4gPiA+ICsrKyBiL25ldC9zdW5ycGMvc29ja2xpYi5jDQo+ID4gPiBAQCAtMTA2
LDcgKzEwNiw3IEBAIHN0YXRpYyBzaXplX3QNCj4gPiA+IHhkcl9za2JfcmVhZF9hbmRfY3N1bV9i
aXRzKHN0cnVjdA0KPiA+ID4geGRyX3NrYl9yZWFkZXIgKmRlc2MsIHZvaWQgKnRvLA0KPiA+ID4g
CQkvKiBBQ0wgbGlrZXMgdG8gYmUgbGF6eSBpbiBhbGxvY2F0aW5nIHBhZ2VzIC0gQUNMcw0KPiA+
ID4gCQkgKiBhcmUgc21hbGwgYnkgZGVmYXVsdCBidXQgY2FuIGdldCBodWdlLiAqLw0KPiA+ID4g
CQlpZiAoKHhkci0+ZmxhZ3MgJiBYRFJCVUZfU1BBUlNFX1BBR0VTKSAmJiAqcHBhZ2UgPT0NCj4g
PiA+IE5VTEwpIHsNCj4gPiA+IC0JCQkqcHBhZ2UgPSBhbGxvY19wYWdlKEdGUF9BVE9NSUMpOw0K
PiA+ID4gKwkJCSpwcGFnZSA9IGFsbG9jX3BhZ2UoR0ZQX05PV0FJVCB8IF9fR0ZQX05PV0FSTik7
DQo+ID4gPiAJCQlpZiAodW5saWtlbHkoKnBwYWdlID09IE5VTEwpKSB7DQo+ID4gPiAJCQkJaWYg
KGNvcGllZCA9PSAwKQ0KPiA+ID4gCQkJCQljb3BpZWQgPSAtRU5PTUVNOw0KPiA+IA0KPiA+IEht
bS4uLiBDYW4ndCB3ZSBtYWtlIHRoaXMgR0ZQX0tFUk5FTD8gSSBjYW4ndCBzZWUgdGhhdCB3ZSdy
ZQ0KPiA+IGhvbGRpbmcNCj4gPiBhbnkgbG9ja3MgaGVyZS4NCj4gDQo+IFdlJ3JlIGhvbGRpbmcg
dGhlIHRyYW5zcG9ydCBzZW5kIGxvY2suIFNpbmNlIHRoaXMgaXMgYW4gb3JkZXIgMA0KPiBhbGxv
Y2F0aW9uDQo+IGl0J3MgdW5saWtlbHkgdG8gZmFpbCBldmVuIHdpdGggYSBsZXNzIGFnZ3Jlc3Np
dmUgcmVxdWVzdCBsaWtlDQo+IE5PV0FJVC4NCg0KV2Ugc2hvdWxkIG9ubHkgYmUgaG9sZGluZyB0
aGUgcmVjZWl2ZSBtdXRleC4gVGhhdCBwcmV2ZW50cyBvdGhlcnMgZnJvbQ0KY2xvc2luZyB0aGUg
c29ja2V0IChvciBzdGFydGluZyBhIHNlY29uZCByZWNlaXZlIHdvcmtlcikgYnV0IHRoYXQncw0K
YWxsLg0KDQpPVE9ILCB0aGUgb25seSB0aGluZyB1c2luZyB0aGlzIG1lY2hhbmlzbSBvbiBVRFAg
c2hvdWxkIGJlIHRoZSBORlN2Mi92Mw0KQUNMIHJlY2VpdmUgY29kZSwgc28gSSdtIG5vdCByZWFs
bHkgc3VyZSBhbnlvbmUgY2FyZXMuDQoNCg0KPiA+IEl0IGRvZXMgbG9vayBsaWtlIHN2Y191ZHBf
cmVjdmZyb20oKSBpcyB3cmFwcGluZyB0aGUNCj4gPiBjYWxsIHRvIGNzdW1fcGFydGlhbF9jb3B5
X3RvX3hkcigpIGluIGEgbG9jYWxfYmhfZGlzYWJsZSgpL2VuYWJsZSgpDQo+ID4gcGFpciwgYnV0
IGlzIHRoYXQgYWN0dWFsbHkgbmVlZGVkPyBJZiBzbywgZm9yIHdoYXQ/DQo+ID4gDQo+ID4gPiBk
aWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy94cHJ0cmRtYS9ycGNfcmRtYS5jDQo+ID4gPiBiL25ldC9z
dW5ycGMveHBydHJkbWEvcnBjX3JkbWEuYw0KPiA+ID4gaW5kZXggNmMxZmIyNy4uYjc1OWIxNiAx
MDA2NDQNCj4gPiA+IC0tLSBhL25ldC9zdW5ycGMveHBydHJkbWEvcnBjX3JkbWEuYw0KPiA+ID4g
KysrIGIvbmV0L3N1bnJwYy94cHJ0cmRtYS9ycGNfcmRtYS5jDQo+ID4gPiBAQCAtMjM4LDcgKzIz
OCw3IEBAIHN0YXRpYyBib29sIHJwY3JkbWFfcmVzdWx0c19pbmxpbmUoc3RydWN0DQo+ID4gPiBy
cGNyZG1hX3hwcnQgKnJfeHBydCwNCj4gPiA+IAkJICovDQo+ID4gPiAJCWlmICh1bmxpa2VseSh4
ZHJidWYtPmZsYWdzICYgWERSQlVGX1NQQVJTRV9QQUdFUykpIHsNCj4gPiA+IAkJCWlmICghKnBw
YWdlcykNCj4gPiA+IC0JCQkJKnBwYWdlcyA9IGFsbG9jX3BhZ2UoR0ZQX0FUT01JQyk7DQo+ID4g
PiArCQkJCSpwcGFnZXMgPSBhbGxvY19wYWdlKEdGUF9OT1dBSVQgfA0KPiA+ID4gX19HRlBfTk9X
QVJOKTsNCj4gPiA+IAkJCWlmICghKnBwYWdlcykNCj4gPiA+IAkJCQlyZXR1cm4gLUVOT0JVRlM7
DQo+ID4gPiAJCX0NCj4gPiA+IA0KPiA+IA0KPiA+IENoZWVycw0KPiA+ICBUcm9uZA0KPiA+IC0t
IA0KPiA+IFRyb25kIE15a2xlYnVzdA0KPiA+IExpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCj4gPiB0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQo+IA0KPiAt
LQ0KPiBDaHVjayBMZXZlcg0KPiANCj4gDQo+IA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4
IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1t
ZXJzcGFjZS5jb20NCg0KDQo=
