Return-Path: <SRS0=Ptm/=RD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F3E7C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 23:57:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0E962087E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 23:56:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="HdiwKuj8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727147AbfB1X47 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Feb 2019 18:56:59 -0500
Received: from mail-eopbgr740111.outbound.protection.outlook.com ([40.107.74.111]:32005
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725955AbfB1X46 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Feb 2019 18:56:58 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4CZV17S3k3jch9s/2vwwTDICPLGHdGIlzquCKnII1OA=;
 b=HdiwKuj8ZPjXBtheXRZyjqZbHi08NTnDeADCHNmI6E5+seze1A/i+Vl1vg6fx5X9SMN/6Cq98chFBU0dAn8kYIjtUYMjuNeLP+ZV9LqwLMUtz0Wmm39eQOYzkhRjYnsz9+UIYZ0hgijVmgfpfQxz5VRIWakrYwgMF2BRMwMWNK4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2352.namprd13.prod.outlook.com (52.135.94.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.12; Thu, 28 Feb 2019 23:56:53 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1686.011; Thu, 28 Feb 2019
 23:56:53 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jiufei.xue@linux.alibaba.com" <jiufei.xue@linux.alibaba.com>,
        "aglo@umich.edu" <aglo@umich.edu>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
Thread-Topic: [bug report] task hang while testing xfstests generic/323
Thread-Index: AQHUz03JX9HUIwfLV060fPzVrzJvGKX1yrYAgAAZN4A=
Date:   Thu, 28 Feb 2019 23:56:52 +0000
Message-ID: <dae18b965a55ed36071b5296d6b1466a57878d16.camel@hammerspace.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
         <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
In-Reply-To: <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 16bb383a-7ac6-49dc-3a78-08d69dd869aa
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2352;
x-ms-traffictypediagnostic: SN6PR13MB2352:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzUyOzIzOjlKVmJpVFo2MGs0aDc2UEVmd0plSDFBdTFv?=
 =?utf-8?B?NWswUnZvbWp0VXVqcXJjbjJnSXRKNUdnZUhacWpOakV5VlR0cEoxanRjR1Q1?=
 =?utf-8?B?UzZlM0daNEY0eWRzckIwd3laU3gvZWkzakp5ZytKZVZlazhSUUkvc1l3WlV6?=
 =?utf-8?B?MVcrWHJkS2lBZjZoTlRieW54eC9ReDVBM1ZvU0g2d2lDeGdNTU9WbzVxNGNw?=
 =?utf-8?B?TzdCL3IyTU1mOWhNVzZKV2pxY0kwb3ZGK1hCSDZ5RjMwZitneExneWF5Uy9F?=
 =?utf-8?B?c09JYkt5OEQ1SnRzL2FMZG5EYzNHSThFSEs2S3YrbVdMV0t0N1ZURm5tbGJV?=
 =?utf-8?B?SWkzVUFiMUt3cXBsdmhlME1sTE9hUm9GVi9uNzI0TWN1MUtibFBxU3FxZmZC?=
 =?utf-8?B?ZTdqd3dOSW9Nd0R0Q1lpaFcyZFJUZnB0NkU4djVGdjRRMlF0VWxVMEl5L1ky?=
 =?utf-8?B?VzVZdjNuV0RDend5K080Mis3Nm5UQmhDbnc2T3RHYmZsSVB1UGVXK1Q5eGZS?=
 =?utf-8?B?Qk1wNjYwMGhmcHVNQjRvd3NVVVlKV1pmY1Jvb1c5ZjJkTHdiVGlXMlY1Qjdj?=
 =?utf-8?B?NGMxelNWTGFvdmdLUE0wc3FRQW91VzUwamRsUGJZTDBqUEJQeXF3T2pKSU9X?=
 =?utf-8?B?UnUzVTNpMG16akJMMnk0NW5iY2tTMGhLMHNsRW1lUFM2NEtNZFlSa0MweTNC?=
 =?utf-8?B?bVVMSy9oSmpuRWVFaVRnNVp0Z2cyZnhvc25GWWpKdHBZZnhBUDg1Vk53VStF?=
 =?utf-8?B?cmxlZGlLc3hETlNHeTkvcHZ3OEtiSWV0U0tVZmxwV3FyTHVqNFEvb0xHQlN1?=
 =?utf-8?B?Mmc5OUVxUTd6NE9ZR0lUQkk3Q2VlTThZRU84QlZKYjB4algxM0ZmdXBZSkUw?=
 =?utf-8?B?b3ZhakFiNnduWUZBTDV5eEplZndZZC80TTB0ZEM4MDJrSG1KWkt0ZjhBNUhv?=
 =?utf-8?B?OTE3Ynlpbnp4bVpoY1dyNUwrcWJXYnB0OTRBOFllNUhLeFUyUGtURUQvNVJV?=
 =?utf-8?B?c1JRZjFOTHZJQThEWlQ4cVNWYy9pcEhsL0tub09WankvdktHUHlTK2lRbjds?=
 =?utf-8?B?SnpYS0ViSjV3S1BpZmlwMElpcWFxeUtQMDhmVFl4QlNXQnl1U2UreUNjS2ZO?=
 =?utf-8?B?eU5zWEFJRVcwL0dsMWdDc2U0VVAzMVhwcEUxWmphbCs3TFN0Nzg1NXA0RWV6?=
 =?utf-8?B?N2hSeU5yd2VWR1FxeHFTZEpxalZ2bEVuR2hjTFVzU3FNdnZaMElhTkVXalZD?=
 =?utf-8?B?NmNRdVdWdzFaV21wbm4vNmI0NUYrTThLNTBSbHJZdFpmZ1pSdzhKUUdJQWht?=
 =?utf-8?B?dUdvaWFCdm00T2RSSnZscFplYVRiSVF0N2EvTTVXaGsrVUtSZGN4ZEJ0Y3hI?=
 =?utf-8?B?akp3Q29xVEl3Zmk0Vk82dXREVEhnTlo0RGYxb0wwZ3dISjlyWkRoODdzdEJY?=
 =?utf-8?B?Nmo3M3RYWWJqbGpXbFF4L0JCRGp3L0NZakVjNWVBTHorcFV0SHlOaXE0TW8w?=
 =?utf-8?B?UURFck03TGtzNmE0SENMQW5USkl4OVNPVmUrWGxoRldua2NzaVBGNG5OaW9r?=
 =?utf-8?B?cXNxMmsyRGJ0Sm1mYnNkUzVGY0lFajRMVlZHcmIzWWxMeEt4TlRibVRmVnYz?=
 =?utf-8?B?WXN6NGZQbk0yZGc3eEZHMDNQTVRrdTI2VUFhUGVqaGZqY2dFd2E3ajJaWm5B?=
 =?utf-8?B?OUhreG5yR2tjU2J0Nm55Q0tXUkptc0VSZkl3R2FqdlgxckNxL3hPRjRxT1dF?=
 =?utf-8?B?aW4vcWt3ZkNuUTNYUlNBZz09?=
x-microsoft-antispam-prvs: <SN6PR13MB235271A00AF7A195A37F7795B8750@SN6PR13MB2352.namprd13.prod.outlook.com>
x-forefront-prvs: 0962D394D2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39830400003)(396003)(346002)(136003)(366004)(199004)(189003)(446003)(66066001)(86362001)(11346002)(476003)(2616005)(486006)(6486002)(8936002)(478600001)(305945005)(68736007)(71200400001)(6436002)(71190400001)(14444005)(6512007)(2501003)(97736004)(36756003)(229853002)(25786009)(4326008)(2906002)(6116002)(2171002)(76176011)(3846002)(186003)(26005)(256004)(105586002)(118296001)(106356001)(6246003)(53936002)(54906003)(110136005)(8676002)(102836004)(53546011)(6506007)(99286004)(7736002)(316002)(5660300002)(14454004)(81156014)(81166006)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2352;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ovlzTdoXLtF+szXKXNXD/FJBLZjyGcOOKo2y5Ab4uZkOpdONsJMtIaWE2p0YdlhCJKGB8lSRyC3gtGH3fjS8ZqiDS1f5SkNOz6If9RycbHOAGj0SUe89vLucITik60C6nns6g74sAqFjiztlmp2pF4W3df35pK6MLMHG9ElceIvtF24+G91tEkyB3+OGcWc8CDC6pdy8p4w4mNqmC8bZdXsPnq1eEg0kiXRCqdzmp+3tQbe0ofhk1b3UtIvOdnIVjw/TAVo1dwpGOYrcjz4P/Ux78H1TGzmw1RtROaq9CAAN/Ys7OOobtXaA6y9LDFlCm4VT+9dMoDC2s30/ynxXoUBuFq5REJWL4iXnRpM37V5ktjZ9OnFOTEwafTLTwPZudYyHydOomUaa0qSWTd6PDEKj3eXZxnUyuapIXKJ9b3I=
Content-Type: text/plain; charset="utf-8"
Content-ID: <229065A3C9CDCB408B39BBFC56C599B5@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 16bb383a-7ac6-49dc-3a78-08d69dd869aa
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Feb 2019 23:56:52.9853
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2352
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAyLTI4IGF0IDE3OjI2IC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gVGh1LCBGZWIgMjgsIDIwMTkgYXQgNToxMSBBTSBKaXVmZWkgWHVlIDwNCj4gaml1
ZmVpLnh1ZUBsaW51eC5hbGliYWJhLmNvbT4gd3JvdGU6DQo+ID4gSGksDQo+ID4gDQo+ID4gd2hl
biBJIHRlc3RlZCB4ZnN0ZXN0cy9nZW5lcmljLzMyMyB3aXRoIE5GU3Y0LjEgYW5kIHY0LjIsIHRo
ZSB0YXNrDQo+ID4gY2hhbmdlZCB0byB6b21iaWUgb2NjYXNpb25hbGx5IHdoaWxlIGEgdGhyZWFk
IGlzIGhhbmdpbmcgd2l0aCB0aGUNCj4gPiBmb2xsb3dpbmcgc3RhY2s6DQo+ID4gDQo+ID4gWzww
Pl0gcnBjX3dhaXRfYml0X2tpbGxhYmxlKzB4MWUvMHhhMCBbc3VucnBjXQ0KPiA+IFs8MD5dIG5m
czRfZG9fY2xvc2UrMHgyMWIvMHgyYzAgW25mc3Y0XQ0KPiA+IFs8MD5dIF9fcHV0X25mc19vcGVu
X2NvbnRleHQrMHhhMi8weDExMCBbbmZzXQ0KPiA+IFs8MD5dIG5mc19maWxlX3JlbGVhc2UrMHgz
NS8weDUwIFtuZnNdDQo+ID4gWzwwPl0gX19mcHV0KzB4YTIvMHgxYzANCj4gPiBbPDA+XSB0YXNr
X3dvcmtfcnVuKzB4ODIvMHhhMA0KPiA+IFs8MD5dIGRvX2V4aXQrMHgyYWMvMHhjMjANCj4gPiBb
PDA+XSBkb19ncm91cF9leGl0KzB4MzkvMHhhMA0KPiA+IFs8MD5dIGdldF9zaWduYWwrMHgxY2Uv
MHg1ZDANCj4gPiBbPDA+XSBkb19zaWduYWwrMHgzNi8weDYyMA0KPiA+IFs8MD5dIGV4aXRfdG9f
dXNlcm1vZGVfbG9vcCsweDVlLzB4YzINCj4gPiBbPDA+XSBkb19zeXNjYWxsXzY0KzB4MTZjLzB4
MTkwDQo+ID4gWzwwPl0gZW50cnlfU1lTQ0FMTF82NF9hZnRlcl9od2ZyYW1lKzB4NDQvMHhhOQ0K
PiA+IFs8MD5dIDB4ZmZmZmZmZmZmZmZmZmZmZg0KPiA+IA0KPiA+IFNpbmNlIGNvbW1pdCAxMmYy
NzVjZGQxNjMoTkZTdjQ6IFJldHJ5IENMT1NFIGFuZCBERUxFR1JFVFVSTiBvbg0KPiA+IE5GUzRF
UlJfT0xEX1NUQVRFSUQpLCB0aGUgY2xpZW50IHdpbGwgcmV0cnkgdG8gY2xvc2UgdGhlIGZpbGUg
d2hlbg0KPiA+IHN0YXRlaWQgZ2VuZXJhdGlvbiBudW1iZXIgaW4gY2xpZW50IGlzIGxvd2VyIHRo
YW4gc2VydmVyLg0KPiA+IA0KPiA+IFRoZSBvcmlnaW5hbCBpbnRlbnRpb24gb2YgdGhpcyBjb21t
aXQgaXMgcmV0cnlpbmcgdGhlIG9wZXJhdGlvbg0KPiA+IHdoaWxlDQo+ID4gcmFjaW5nIHdpdGgg
YW4gT1BFTi4gSG93ZXZlciwgaW4gdGhpcyBjYXNlIHRoZSBzdGF0ZWlkIGdlbmVyYXRpb24NCj4g
PiByZW1haW5zDQo+ID4gbWlzbWF0Y2ggZm9yZXZlci4NCj4gPiANCj4gPiBBbnkgc3VnZ2VzdGlv
bnM/DQo+IA0KPiBDYW4geW91IGluY2x1ZGUgYSBuZXR3b3JrIHRyYWNlIG9mIHRoZSBmYWlsdXJl
PyBJcyBpdCBwb3NzaWJsZSB0aGF0DQo+IHRoZSBzZXJ2ZXIgaGFzIGNyYXNoZWQgb24gcmVwbHkg
dG8gdGhlIGNsb3NlIGFuZCB0aGF0J3Mgd2h5IHRoZSB0YXNrDQo+IGlzIGh1bmc/IFdoYXQgc2Vy
dmVyIGFyZSB5b3UgdGVzdGluZyBhZ2FpbnN0Pw0KPiANCj4gSSBoYXZlIHNlZW4gdHJhY2Ugd2hl
cmUgY2xvc2Ugd291bGQgZ2V0IEVSUl9PTERfU1RBVEVJRCBhbmQgd291bGQNCj4gc3RpbGwgcmV0
cnkgd2l0aCB0aGUgc2FtZSBvcGVuIHN0YXRlIHVudGlsIGl0IGdvdCBhIHJlcGx5IHRvIHRoZSBP
UEVODQo+IHdoaWNoIGNoYW5nZWQgdGhlIHN0YXRlIGFuZCB3aGVuIHRoZSBjbGllbnQgcmVjZWl2
ZWQgcmVwbHkgdG8gdGhhdCwNCj4gaXQnbGwgcmV0cnkgdGhlIENMT1NFIHdpdGggdGhlIHVwZGF0
ZWQgc3RhdGVpZC4NCg0KSSBhZ3JlZSB3aXRoIE9sZ2EncyBhc3Nlc3NtZW50LiBUaGUgc2VydmVy
IGlzIG5vdCBhbGxvd2VkIHRvIHJhbmRvbWx5DQpjaGFuZ2UgdGhlIHZhbHVlcyBvZiB0aGUgc2Vx
aWQsIGFuZCB0aGUgY2xpZW50IHNob3VsZCBiZSB0YWtpbmcgcGFpbnMNCnRvIHJlcGxheSBhbnkg
T1BFTiBjYWxscyBmb3Igd2hpY2ggYSByZXBseSBpcyBtaXNzZWQuIFRoZSBleHBlY3RhdGlvbg0K
aXMgdGhlcmVmb3JlIHRoYXQgTkZTNEVSUl9PTERfU1RBVEVJRCBzaG91bGQgYWx3YXlzIGJlIGEg
dGVtcG9yYXJ5DQpzdGF0ZS4NCg0KSWYgaXQgaXMgbm90LCB0aGVuIHRoZSBidWdyZXBvcnQgbmVl
ZHMgdG8gZXhwbGFpbiB3aHkgdGhlIHNlcnZlciBidW1wZWQNCnRoZSBzZXFpZCB3aXRob3V0IGlu
Zm9ybWluZyB0aGUgY2xpZW50Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNs
aWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNl
LmNvbQ0KDQoNCg==
