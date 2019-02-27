Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09811C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 18:05:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D5142184A
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 18:05:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="G8F96ajD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728397AbfB0SFp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 13:05:45 -0500
Received: from mail-eopbgr680110.outbound.protection.outlook.com ([40.107.68.110]:6497
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726397AbfB0SFo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 13:05:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hrDvJvBh1V6dlf4NZaJQ1wvkN2zW0ct3JWQKPdxB4bY=;
 b=G8F96ajDdwGru2NisnexiQ+0stf7/fnXtWL1gvMuah2rKXMK317XlFNF+DsWI0QAjfZUom5qPueWLvz+8AzI5YTE3jeMdYFLKWeC5mqenlzo96THpbl9mzLZ1fELW0ocSqLLKIspzoI9HGu7tO6do6v9ZfsKGuxvTaHTp5dbbvk=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2240.namprd13.prod.outlook.com (52.135.93.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.13; Wed, 27 Feb 2019 18:05:39 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Wed, 27 Feb 2019
 18:05:39 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "davenoveck@gmail.com" <davenoveck@gmail.com>
CC:     "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "devel@lists.nfs-ganesha.org" <devel@lists.nfs-ganesha.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rmacklem@uoguelph.ca" <rmacklem@uoguelph.ca>
Subject: Re: [nfsv4] file size and getattr
Thread-Topic: [nfsv4] file size and getattr
Thread-Index: xAHUywXrcRtlAwSKakyZeT3C7wTpA6XxZwkAgAAIQwCAAJ3JAIAAv0QAgAAQiYCAARdogIAAA7+A
Date:   Wed, 27 Feb 2019 18:05:39 +0000
Message-ID: <90c104ee477cdc8e999ddaff4ccab32332d0f71d.camel@hammerspace.com>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
         <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
         <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
         <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>
         <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
         <QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
         <QB1PR01MB3537215D010370E139D70843DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
         <1cbdd04ce23c5012f59b6d5dcbb6b505be0675b9.camel@hammerspace.com>
         <QB1PR01MB3537841A7F121CFA082B778ADD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
         <9bae6a43ea26f112e015b7b0b213fb9dd43bac68.camel@hammerspace.com>
         <CADaq8jfcFCuM5u30bXqTvg+0Hc-V+1VO9aUdSJLA090j48LCvA@mail.gmail.com>
In-Reply-To: <CADaq8jfcFCuM5u30bXqTvg+0Hc-V+1VO9aUdSJLA090j48LCvA@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c281a08b-1f35-4ff4-4a9a-08d69cde2e60
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2240;
x-ms-traffictypediagnostic: SN6PR13MB2240:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMjQwOzIzOkdRcitITjRrbkMyMG96eEh3RHh0YjFXZTFG?=
 =?utf-8?B?KzZXa0ZIbWlpQ2JyMng3Y1o2czBIMmJPK2RlN0NNdGR6VzJtRTZaWXZ1eDFW?=
 =?utf-8?B?cmVJRGJpRVoxRGU0WUFDd1Q0OFN2K3YrbU5RVUtucUNGOWZLcEVXa3BKb3Bi?=
 =?utf-8?B?VXJRWWR2Y3dEZzhsbGdmZ1JTdGV6cVNmMlE1NyszZUY3R3FDcXBoN0xGanBN?=
 =?utf-8?B?VC9kVWFHT25MWjRvTVFFM1N4ZzlMakZNSGkreENONHpseEVINHEzNEtha24v?=
 =?utf-8?B?QXY2VjNZRXJXYVVwaFg4Q0RRWTJyRmhYSG14dnRxenpWNDBjdExiWTlNWmdt?=
 =?utf-8?B?MzBYODFYbmhGNzErZERjWnRiVERiZEJsVDl1Q1p4TUkwblovbzRkMHJGdlhz?=
 =?utf-8?B?TXMrRmpraEJPN1NUUmpyeVl5aWN6ajBXR3ErbEFHYmlqaTBPZUpzczNVTlFM?=
 =?utf-8?B?YnlYVGVib1RUdVlJM00ybUZxMjlTT3plSlMyZE1KNW5BeWpyMVFkQldFL1BX?=
 =?utf-8?B?eVUwM2NWVnB0R0UwRDNLUjdKSUxQSU1KSldnY1Zid0piMDZRQ0YxTVVyaDc2?=
 =?utf-8?B?MGxkZFo2d291WDNLTDEwN1JzQ1FHZkhITW4xSHdPYllOazdrYjdORlFpcENR?=
 =?utf-8?B?WFBIeGVLUzJJYVQyNHg1QUV2eUxsMUtZcmNmcGc4WHd3bWtSbWUzWFlKcjQw?=
 =?utf-8?B?Zmp5M1pvL1FITTlaMXdlUnU4MXd3QVdGUUJXam4yTHBVS2U0WlpDRXpzQnZp?=
 =?utf-8?B?SGx4cEdOV21YcEx2dHM0V2JDbG8xNDRDYm9rdkw1UU1UU2JsZEt1WnJsWkZS?=
 =?utf-8?B?am1nM1g1MEtnRktjQjFucFIrSTNhS0ZSNGxYcU0veDhBVDBsVmNzdVlZbmxz?=
 =?utf-8?B?bmFYK09BaEFQZkRsdUZLZ2dINmJYUGU1V2JGeldDakErZVVMMHpiRDVFRmVC?=
 =?utf-8?B?dEJ2Q2tNNXhsZHhZNVhRRmhwUjJ2NkpKZEdXU1ZDVTZmTURKMUJrUWxXcDFh?=
 =?utf-8?B?OFRyNHJmV2dWWXY1Qmp0ekFHWEZPTklNOURLQ3Izczgrci9BTHpuMDlzWkR6?=
 =?utf-8?B?eXl3L0lsM3cyT3c3dXo0Mk9KbDZDMWwvazJ4c05GWnR0bDc2WVFFNGVaOGwz?=
 =?utf-8?B?TVVoek5Wa2VpYTAyallOSWU4YzlFTTFxOGJ6bDAyRTUvLzBvYXJHTVVUdWkv?=
 =?utf-8?B?akxBYjM5V0p4UU5ad04rM3dkZTRrckF4dVcyeU1hS2VOOXBwYm9rSHRKQWVy?=
 =?utf-8?B?aE8zTmg5NTJoWmdkYkVGWlYwRzJ2VEtpWmFFRjFZRDFCcVhzR0c3bC9rckky?=
 =?utf-8?B?dkRxdjJLZVpMRWtUajRPc0pnS2lzdWdPVllHNE1pY1hMZmZFb3B5dWVDa2o0?=
 =?utf-8?B?Q3ZtS2xKbzZXK2YxOE9vamVzZzVYSHZTM0dlY05vMC9LSFZsMWxJc2FHQ3JT?=
 =?utf-8?B?MmZ4KytGWmRaMWJkZnlOVldGbzRIUnlmL1lRMEVWbnFIK0syRk5KU1JrcWVv?=
 =?utf-8?B?NHFwZEFhK1pEQmlNaHZLN2FXRVc1aDJaUzQ0US9Yb1BzbW1haGwveHcyQTVV?=
 =?utf-8?B?aERzV0VWRCs3M3QxTE1rN0EzcEpNd1FNU2RPYjlXTFFCdndJZlBPNXBoNktM?=
 =?utf-8?B?U3NjdGc2K0NOSytPbVFqaEU3QVA0WjhtTjhrcGVVWktwbWtEZC9ZdDlkRy9l?=
 =?utf-8?B?MFpZeWlDTjRENDRhbFJqSnlQTGM2U2djYTVnekZWVnMrQmRxVXJJR3A3M3A2?=
 =?utf-8?B?SEdEbFNVTlk4MXp5anFXZzhhWUVyS1Bob3p4YXRvZFZlb3MxZTU5aDgwUm15?=
 =?utf-8?B?dnNNQURUQ0VUMUNFRVN6aEdHR3dkeDFjbG9TRDlHYXQrOW5ZODJPZm96amIx?=
 =?utf-8?B?T2x1UWxnV1VsM3N5NUoyano4WUxjK2tnYko5OHI0S3FERXJtYUE2cXNDMzll?=
 =?utf-8?B?VEJxMXdra2pBPT0=?=
x-microsoft-antispam-prvs: <SN6PR13MB224035DD62447A852A1D064CB8740@SN6PR13MB2240.namprd13.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(346002)(376002)(396003)(39830400003)(199004)(189003)(486006)(4326008)(6486002)(7736002)(2351001)(229853002)(2906002)(81156014)(14454004)(68736007)(71190400001)(1730700003)(71200400001)(54906003)(81166006)(36756003)(86362001)(97736004)(256004)(14444005)(106356001)(105586002)(966005)(5660300002)(8936002)(6436002)(478600001)(6916009)(53936002)(76176011)(6512007)(186003)(93886005)(99286004)(2501003)(1361003)(316002)(66066001)(5640700003)(1411001)(53546011)(6306002)(6506007)(118296001)(476003)(305945005)(446003)(3846002)(8676002)(26005)(11346002)(2616005)(102836004)(25786009)(6246003)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2240;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: uYd2cwa67KXj45Axcc6h07qtBOS4zfsJFkFEJQR2CFgEnlvyTlqnT/fNruIZoNgXmOp2N8qI/WoVJv+DjY80ujeNXvR9tq+/uV+GTr2tlblJYpTVUE1RZcplfLvBOuc54XY1KtItJYQHo4suhuROluUE9npkCk9qVDOzBbG39lnPWt/QxkYS/m6OF99nrzPTx+05mgRepKzRagqGDpvR1Z46yL8i/+hCrPmMeitfde9AKaRFvW/yuV37n4tay77olanu2NfdJa6JVL10jrMEiYaWhgZ+0pghMp1+axjYsby01pWMEnSKg5AI2UbO6wC70L5p6aOyXxYVBXPqSRqU4HL3w0tFpk59w3T1osGhEMwgd124sXGkSBtapfQFn0sEFymCJ3OkjYjX/HaSYLJl4gph8/qRUAD5bp3DQaOh6mE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <9379D98BC732C94DA765FBE9DC8AF4AE@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c281a08b-1f35-4ff4-4a9a-08d69cde2e60
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 18:05:39.2948
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2240
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAyLTI3IGF0IDEyOjUyIC0wNTAwLCBEYXZpZCBOb3ZlY2sgd3JvdGU6DQo+
ID4gSG93ZXZlciBub3RlDQo+ID4gdGhhdCB0aGUgY291bnRlciBhcmd1bWVudCB0byB3aGF0IHlv
dSBzdGF0ZSBhYm92ZSBpcyB0aGF0IF9pZl8gdGhlDQo+ID4gc2VydmVyIHJlcXVpcmVzIGEgbGF5
b3V0Y29tbWl0IGJlZm9yZSBpdCB3aWxsIGFja25vd2xlZGdlIGEgZmlsZQ0KPiBzaXplDQo+ID4g
Y2hhbmdlLCB0aGVuIHBORlMgaXMgbGlrZWx5IHRvIHVuZGVycGVyZm9ybSBmb3IgYXBwbGljYXRp
b25zIHN1Y2gNCj4gYXMNCj4gPiBkYXRhYmFzZXMgb3IgVk1zIHdoZXJlIGVhY2ggcmVjb3JkIGlz
IHJlcXVpcmVkIHRvIGJlIHdyaXR0ZW4gaW4NCj4gc3RhYmxlDQo+ID4gbW9kZS4NCj4gPiBJT1c6
IElmIGFsbCB3cml0ZXMgdGhhdCBuZWVkIHRvIGJlIHN0YWJsZSBhcmUgYWxzbyByZXF1aXJlZCB0
byBiZQ0KPiA+IGFja25vd2xlZGdlZCB3aXRoIGEgbGF5b3V0Y29tbWl0ICh0byB0aGUgTURTKSwN
Cj4gDQo+IEJ1dCBpdCBpcyBub3QgdHJ1ZSB0aGF0ICphbGwqIHdyaXRlcyB0aGF0IG5lZWQgdG8g
YmUgc3RhYmxlIGFyZSBhbHNvDQo+IHJlcXVpcmVkIA0KPiB0byBiZSBhY2tub3dsZWRnZWQgd2l0
aCBhIGxheW91dGNvbW1pdCAodG8gdGhlIE1EUy4gIE9ubHkgdGhvc2UgdGhhdCANCj4gcG90ZW50
aWFsbHkgY2hhbmdlIHRoZSBmaWxlIHNpemUgcmVxdWlyZSB0aGlzLg0KDQpUaGF0J3MgdHJ1ZSBm
b3IgUE9TSVggT19EU1lOQyB3cml0ZXMsIGJ1dCBpdCBpcyBub3QgdHJ1ZSBmb3IgT19TWU5DLiBJ
bg0KdGhlIGxhdHRlciBjYXNlLCB0aGUgdGltZXN0YW1wcyBhcmUgcmVxdWlyZWQgdG8gYmUgdXBk
YXRlZA0Kc3luY2hyb25vdXNseSBhcyB3ZWxsLCB3aGljaCBpbXBsaWVzIGEgbGF5b3V0Y29tbWl0
Lg0KDQo+ICANCj4gPiB0aGVuIHlvdXIgYWJpbGl0eSB0bw0KPiA+IHNjYWxlIG91dCB5b3VyIHNl
cnZlciB3aWxsIGJlIGluIGRvdWJ0DQo+IA0KPiBGb3IgbWFueSBhcHBsaWNhdGlvbnMsIHBhcnRp
Y3VsYXJseSBkYXRhYmFzZXMsIGl0IHdpbGwgZWFzeSB0byBtYWtlDQo+IHN1cmUNCj4gdGhhdCB0
aGUgd3JpdGVzIHRoYXQgcG90ZW50aWFsbHkgY2hhbmdlIHRoZSBmaWxlIHNpemUgYXJlIGZldyBh
bmQgZmFyDQo+IGJldHdlZW4uICANCg0KSWYgdGhlIGRhdGFiYXNlIHVzZXMgT19EU1lOQywgeWVz
Lg0KDQo+IA0KPiBPbiBUdWUsIEZlYiAyNiwgMjAxOSBhdCA4OjEyIFBNIFRyb25kIE15a2xlYnVz
dCA8DQo+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiBPbiBXZWQsIDIwMTkt
MDItMjcgYXQgMDA6MTMgKzAwMDAsIFJpY2sgTWFja2xlbSB3cm90ZToNCj4gPiA+IFRyb25kIE15
a2xlYnVzdCB3cm90ZToNCj4gPiA+IFtzdHVmZiBzbmlwcGVkXQ0KPiA+ID4gPiBQbGVhc2Ugc2Vl
IHRoZSBFcnJhdGEgSUQgMjc1MSANCj4gPiA+ID4gaHR0cDovL3d3dy5yZmMtZWRpdG9yLm9yZy9l
cnJhdGEvZWlkMjc1MQ0KPiA+ID4gDQo+ID4gPiBJJ2xsIGFkbWl0IEkgaGFkbid0IHNlZW4gdGhp
cyBlcnJhdGEgYmVmb3JlLiBIb3dldmVyLCBpdCBzZWVtcyB0bw0KPiA+IGJlDQo+ID4gPiBzcGVj
aWZpYyB0bw0KPiA+ID4gdGhlIEZpbGUgTGF5b3V0LiBGb3IgdGhlIEZsZXhpYmxlIEZpbGUgTGF5
b3V0Li4uDQo+ID4gPiANCj4gPiA+IFdoZW4gSSBsb29rIGluIFJGQy04NDM1LCBJIGNhbm5vdCBm
aW5kIGFueXRoaW5nIHRoYXQgc3RhdGVzIHRoYXQNCj4gPiBhDQo+ID4gPiBMYXlvdXRDb21taXQN
Cj4gPiA+IGlzIG9ubHkgcmVxdWlyZWQgZm9yIGNhc2Uocykgd2hlcmUgYSBDb21taXQgdG8gdGhl
IFN0b3JhZ2UgU2VydmVyDQo+ID4gaXMNCj4gPiA+IHJlcXVpcmVkLg0KPiA+ID4gU2VjLiAyLjEN
Cj4gPiA+ICAgIENsZWFybHkgc3RhdGVzIHRoYXQgYSBDb21taXQgdG8gdGhlIFN0b3JhZ2UgU2Vy
dmVyIGlzIHJlcXVpcmVkDQo+ID4gPiBiZWZvcmUgdGhlIGNsaWVudA0KPiA+ID4gICAgZG9lcyBh
IExheW91dENvbW1pdCB3aGVuIHRoZSB3cml0ZShzKSB3ZXJlIG5vdCBkb25lIEZJTEVfU1lOQy4N
Cj4gPiA+ICAgIEhvd2V2ZXIsIEkgZG8gbm90IHNlZSBhbnkgaW5kaWNhdGlvbiB0aGF0IHRoZSBM
YXlvdXRDb21taXQgaXMNCj4gPiBub3QNCj4gPiA+IHRvIGJlIGRvbmUNCj4gPiA+ICAgIGZvciB0
aGUgY2FzZSB3aGVyZSB0aGUgd3JpdGUocykgYXJlIGRvbmUgRklMRV9TWU5DLg0KPiA+ID4gDQo+
ID4gPiBGRl9GTEFHU19OT19MQVlPVVRDT01NSVQgY2FuIGJlIHVzZWQgdG8gaW5kaWNhdGUgdG8g
YSBjbGllbnQgdGhhdA0KPiA+ID4gTGF5b3V0Q29tbWl0cyBhcmUgbm90IHJlcXVpcmVkLCBidXQg
dGhpcyBkb2VzIG5vdCBiZSBkZXBlbmRlbnQgb24NCj4gPiBob3cNCj4gPiA+IHRoZSB3cml0ZShz
KSB0byB0aGUgU3RvcmFnZSBTZXJ2ZXIgd2VyZSBkb25lLg0KPiA+ID4gDQo+ID4gPiBUaGUgb25s
eSB3YXkgYSBGbGV4aWJsZSBGaWxlIGxheW91dCBNZXRhZGF0YSBzZXJ2ZXIgY2FuIGtub3cgd2hh
dA0KPiA+IHRoZQ0KPiA+ID4gY3VycmVudCBmaWxlIHNpemUgaXMgKHdoZW4gYSByZWFkL3dyaXRl
IGxheW91dCBpcyBpc3N1ZWQgdG8gYQ0KPiA+IGNsaWVudCkNCj4gPiA+IGlzIHRvIGRvIGENCj4g
PiA+IEdldGF0dHIgdG8gdGhlIFN0b3JhZ2UgU2VydmVyLg0KPiA+ID4gSWYgYSBjbGllbnQgaXMg
bm90IHJlcXVpcmVkIHRvIGRvIGEgTGF5b3V0Q29tbWl0IHdoZW4gdGhlDQo+ID4gd3JpdGUocykg
dG8NCj4gPiA+IHRoZQ0KPiA+ID4gU3RvcmFnZSBTZXJ2ZXIgYXJlIGRvbmUgRklMRV9TWU5DLCB0
aGVuIHRoZSBNZXRhZGF0YSBzZXJ2ZXIgbXVzdA0KPiA+IGRvDQo+ID4gPiBHZXRhdHRyIFJQQ3Mg
dG8gdGhlIFN0b3JhZ2UgU2VydmVyIHdoZW5ldmVyIGl0IG5lZWRzIGFuIHVwIHRvDQo+ID4gZGF0
ZQ0KPiA+ID4gZmlsZSBzaXplDQo+ID4gPiBpZiBhIHJlYWQvd3JpdGUgbGF5b3V0IGlzIGlzc3Vl
ZCB0byBhIGNsaWVudC4NCj4gPiA+IA0KPiA+ID4gVGhpcyBjYW4gcmVzdWx0IGluIGEgbG90IG9m
IG92ZXJoZWFkIHRoYXQgY2FuIGJlIGF2b2lkZWQgYnkNCj4gPiByZXF1aXJpbmcNCj4gPiA+IHRo
ZQ0KPiA+ID4gTGF5b3V0Q29tbWl0IHRvIGJlIGRvbmUgYnkgYSBjbGllbnQgYWZ0ZXIgd3JpdGlu
ZyB0byBhIFN0b3JhZ2UNCj4gPiA+IFNlcnZlciwNCj4gPiA+IGlycmVzcGVjdGl2ZSBvZiB0aGUg
bmVlZCBmb3IgYSBDb21taXQgdG8gdGhlIFN0b3JhZ2UgU2VydmVyLg0KPiA+ID4gQXMgc3VjaCwg
SSB3b3VsZCByYXRoZXIgbm90IGhhdmUgdGhpcyBlcnJhdGEgYXBwbGllZCB0byBSRkMtODQzNS4N
Cj4gPiA+IA0KPiA+IA0KPiA+IEZhaXIgZW5vdWdoLiBJIGFncmVlIHRoYXQgdGhlIGVycmF0YSBp
biBxdWVzdGlvbiBvbmx5IGFwcGxpZXMgdG8NCj4gPiB0aGUNCj4gPiBwTkZTIGZpbGVzIGxheW91
dCwgaG93ZXZlciB5b3Ugd2VyZSB0YWxraW5nIGFib3V0IFJGQzU2NjEgYW5kDQo+ID4gd2hldGhl
cg0KPiA+IG9yIG5vdCB3ZSB3ZXJlIGludGVycHJldGluZyB0aGF0IGNvcnJlY3RseS4gU2luY2Ug
UkZDNTY2MSBvbmx5DQo+ID4gcmVmZXJzDQo+ID4gdG8gYWJvdXQgdGhlIGJlaGF2aW91ciBvZiB0
aGUgcE5GUyBmaWxlcyBsYXlvdXQsIHRoZW4gSSBhc3N1bWVkDQo+ID4gdGhhdA0KPiA+IHdhcyB3
aGF0IHlvdSB3ZXJlIHJlZmVycmluZyB0by4NCj4gPiANCj4gPiBGb3IgZmxleGZpbGVzIHdlIG1h
eSBoYXZlIGEgYnVnIGluIHRoZSBsYXlvdXRjb21taXQgY2FzZS4gSG93ZXZlcg0KPiA+IG5vdGUN
Cj4gPiB0aGF0IHRoZSBjb3VudGVyIGFyZ3VtZW50IHRvIHdoYXQgeW91IHN0YXRlIGFib3ZlIGlz
IHRoYXQgX2lmXyB0aGUNCj4gPiBzZXJ2ZXIgcmVxdWlyZXMgYSBsYXlvdXRjb21taXQgYmVmb3Jl
IGl0IHdpbGwgYWNrbm93bGVkZ2UgYSBmaWxlDQo+ID4gc2l6ZQ0KPiA+IGNoYW5nZSwgdGhlbiBw
TkZTIGlzIGxpa2VseSB0byB1bmRlcnBlcmZvcm0gZm9yIGFwcGxpY2F0aW9ucyBzdWNoDQo+ID4g
YXMNCj4gPiBkYXRhYmFzZXMgb3IgVk1zIHdoZXJlIGVhY2ggcmVjb3JkIGlzIHJlcXVpcmVkIHRv
IGJlIHdyaXR0ZW4gaW4NCj4gPiBzdGFibGUNCj4gPiBtb2RlLg0KPiA+IElPVzogSWYgYWxsIHdy
aXRlcyB0aGF0IG5lZWQgdG8gYmUgc3RhYmxlIGFyZSBhbHNvIHJlcXVpcmVkIHRvIGJlDQo+ID4g
YWNrbm93bGVkZ2VkIHdpdGggYSBsYXlvdXRjb21taXQgKHRvIHRoZSBNRFMpLCB0aGVuIHlvdXIg
YWJpbGl0eSB0bw0KPiA+IHNjYWxlIG91dCB5b3VyIHNlcnZlciB3aWxsIGJlIGluIGRvdWJ0Lg0K
PiA+IA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
