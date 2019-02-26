Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53579C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 12:49:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E14932173C
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 12:49:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="MleKfXYC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726627AbfBZMtM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 07:49:12 -0500
Received: from mail-eopbgr800130.outbound.protection.outlook.com ([40.107.80.130]:28779
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726115AbfBZMtL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 07:49:11 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VzTMttP71byhyPm0ioO4/23d+8F3+95lDRDLhv1I4j8=;
 b=MleKfXYCoMWPyr+vmj6A+GiujX3MkNgUZFyKr60nlHQ/hKEkVYalh8tGzNkw5rgTm4SEr39Yz8hJc7pPZweS3ZDSwq8yv2b7Z3HjrFOm2odGyYt/P0tZRIiAETGKPSFOD5wQnwSYF6O7TjY5czVI9ruYNV8w1s0mux6TEySrwB0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2429.namprd13.prod.outlook.com (52.135.94.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.11; Tue, 26 Feb 2019 12:48:28 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Tue, 26 Feb 2019
 12:48:28 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "davenoveck@gmail.com" <davenoveck@gmail.com>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "rmacklem@uoguelph.ca" <rmacklem@uoguelph.ca>
CC:     "devel@lists.nfs-ganesha.org" <devel@lists.nfs-ganesha.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] file size and getattr
Thread-Topic: [nfsv4] file size and getattr
Thread-Index: xAHUywXrcRtlAwSKakyZeT3C7wTpA6XxZwkAgAAIQwCAAJ3JAA==
Date:   Tue, 26 Feb 2019 12:48:28 +0000
Message-ID: <1cbdd04ce23c5012f59b6d5dcbb6b505be0675b9.camel@hammerspace.com>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
         <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
         <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
         <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>   ,
 <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
        ,<QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
         <QB1PR01MB3537215D010370E139D70843DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
In-Reply-To: <QB1PR01MB3537215D010370E139D70843DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1962a2b0-de84-46cc-1522-08d69be8b4c8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2429;
x-ms-traffictypediagnostic: SN6PR13MB2429:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDI5OzIzOnQvV09iWlBvWjgyU0wrNitNZTE5QWJDd1hM?=
 =?utf-8?B?Qk1acnE4cCtFTDBIMFh2bjVwdVdwQW9wOHVFc2J0VVZ6Qm9qUTJMODAzSDBm?=
 =?utf-8?B?VGgxcUNJeWNLTkQ2QXBOUjBORHZIVHlQUjBIL2pQb3ZVR2Y1ckZBTUQyR0Fq?=
 =?utf-8?B?eklZbnNlbllIN0hFUkJHc1JLTlBwYVdGOXc3QzhTb1BybzRsUmE1Y1VNYjJ1?=
 =?utf-8?B?b3JVOTQ5em5yaGhmQkh2NDJEU2FaNFFqbmcvYmtDUnpnTTdwcERLanhvTUVm?=
 =?utf-8?B?djZvUHZabkYxcjM1Z0FTczh3M1NoanBtbUVnVVF1Q1lkYWdyTklVZU13cmlB?=
 =?utf-8?B?TWJJbWNxRHZhdWdTMXAwM2RGaThXdG40cTU5MCtDYzFhNk5uK3BTOXJVeEd5?=
 =?utf-8?B?T0V1b3NwazZvdjBLMHhDTVE2REV1RkNwTEc5Rm5Vdlh0aVZuMGorUHkrOUZC?=
 =?utf-8?B?V0Q3TkJXSmFRRGU5WHdhT3VlaEJJeHZLMTVINTgrNlFSeGR2cmNwK3pkQ2FU?=
 =?utf-8?B?VjNPd2ZZWUF1cVBNdHVkTGJDaTZadnBna2xTSzdRYXRVQjh6MGhMNWJNQkl2?=
 =?utf-8?B?aVVCQ0VsVXowV21INmhTcFhCdDU3S0l2RWRwa0dUR2RNOUs3TS9ySFJGTDZC?=
 =?utf-8?B?SS82L2VkQVhJNEJEZURSU2k3MGVETnNCUDd1ejl4VjNySnRtS2xsMHNlWXVk?=
 =?utf-8?B?RGcvK3dyUng4VUZXUC85V1NEZFlDLzY3NDFLTWhCODBxVDJyMWtxNXRvVGdW?=
 =?utf-8?B?R040cDh4OVlsNzVUTWZGRDlWRUpZVDlNZWJwZTh5TUtQajZoNUFJYTV6aHpM?=
 =?utf-8?B?WGxYaHBOZDh5TldhQjVZVGZjWHFkcko3bFNGRWVxZ1M4NjBEUFpPUWl0a0k5?=
 =?utf-8?B?U0FwbWhGZk5sZ29HWVVGUjdIMjYrNi9naFRrZmpNaXRubnorY1BDc214RGMx?=
 =?utf-8?B?WVpRek5ncFNQWTk5N3k0RWpFemRUcjlJNkNyL2pKeWNCMUs2TStnMlAwRDB4?=
 =?utf-8?B?Q1pVdysxeWQzVUNGRlp5T2RpNVUrTUhEQ0E4MTFTaUozUjM3dzlQREliU1hh?=
 =?utf-8?B?MFZKQTBCRFJPckxZWGhscXdwWjhRVXZGNm02b1RuWlg2ajRpZ1drYzJHcFJM?=
 =?utf-8?B?Y2JNSlo0NUdyU2xJZmlBR21yNi90dGJDZmlpaEppUlMvMFBvM2pXU3NzL1ky?=
 =?utf-8?B?amZ5Z1ZXeUs3ZlQ5MXdBNkRpeGVLbCszSTdEcE9UN1BHQlgxUVhmbTljd294?=
 =?utf-8?B?S3RSZlBpaGhFZGhaTGRvb1Vma0gyUFdkdTlueUhidG5kZHlURzJ5TitLUFZq?=
 =?utf-8?B?eTFkN1N4eENXRE5CWG14aG5YUjJQbENITERuK3g0dW1NaTZTa0FaQ2JmMW4r?=
 =?utf-8?B?NFM2bmo1ck5IK04xUFNhbFFmQm1aV05LNEErRjBLeEdTSEhBMzhQbnJlS2F5?=
 =?utf-8?B?SXJxZ0RHMjZzQmtKYnlXd0FRdVBSOE9zMFFsQThyUERGY3lYNDJGWUozMU16?=
 =?utf-8?B?b09rRU91QWZOTWJlQ3d1UGdtaUw0RUtXYUdjU0RFTy9sVzNyaXVyckw2blhi?=
 =?utf-8?B?VXIxSHNibE41QjE1OGNYY2IyNkFYcEhLT1k4Rk1aaEdRNjQ2TGwyWlB6NjhZ?=
 =?utf-8?B?L1hoRUtWZDY5STdzOG40OVYra01ES1NXakIwM1FmVGY0TlFZS09iU1RBWkpT?=
 =?utf-8?B?dXpOTngyV0NDQkYwRkFvNVFUeFhBZmo2dG5uMURMbndKOEU0YWxqdHFHRGNQ?=
 =?utf-8?B?aWJJajhJWmp1WS82dmFycExGUzlPMWt1YW5MVHZ4OW5uMGlXMzUwY0N6Tm9Z?=
 =?utf-8?Q?NzSzbXXIR3aBG?=
x-microsoft-antispam-prvs: <SN6PR13MB2429FFC7C49F5133BF44041FB87B0@SN6PR13MB2429.namprd13.prod.outlook.com>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(396003)(39830400003)(376002)(136003)(189003)(199004)(71190400001)(229853002)(2501003)(71200400001)(6436002)(966005)(4744005)(105586002)(478600001)(6486002)(66066001)(106356001)(118296001)(68736007)(36756003)(2906002)(6116002)(3846002)(5660300002)(486006)(97736004)(7736002)(14444005)(76176011)(256004)(81156014)(8676002)(102836004)(316002)(54906003)(2201001)(476003)(6512007)(6306002)(26005)(99286004)(6506007)(11346002)(446003)(2616005)(110136005)(305945005)(6246003)(4326008)(53936002)(6346003)(14454004)(93886005)(86362001)(81166006)(25786009)(186003)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2429;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: hNryoRQmZJofPNKdFotlL6Rm5cSQHnDSVY/6k9xaFT/bRoLgor9RNR3YZfCxQCgrn0X+GnPvZZPGs3h0jWcmDenw1PEqbCGgO/hEyJhZgOlAeVGa/8sJcHz+S7/kmQ4yo2/yN3VMl+KZgH5+PSohDUTxOlQqjX4JqGt3MobPz5A3dgJl5giTTQ5RqC+71010/kzl04P+Jop0JWH/JIMM6Vt7cV96TBjjctWq49NgBIBVpxolbaH3ZPAbtaWkUD8+hbjKDa1U77GVnrx/JkrwScpbR8QMQU7eSOvfYI9gIsavzJHpggLETvCwuM5dobrGTKrQhQcvxbs88jndCHAmHJxADU508kZvGRqRJligNkw7AQodWjkQ2nZo8jSzpDHMNszKq0efqUG74qNTbRc5L7MQLkVDKzloR2EQvJjBOjA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <71D8A23A40C32C4C98213554C5876A8C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1962a2b0-de84-46cc-1522-08d69be8b4c8
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 12:48:28.5682
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2429
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgUmljaywNCg0KT24gVHVlLCAyMDE5LTAyLTI2IGF0IDAzOjIzICswMDAwLCBSaWNrIE1hY2ts
ZW0gd3JvdGU6DQo+IA0KPiBJZiBJIHJlY2FsbCBjb3JyZWN0bHksIHRoZSBMaW51eCBjbGllbnQg
b25seSBkaWQgTGF5b3V0Q29tbWl0cyBhZnRlcg0KPiBDb21taXRzLg0KPiBBcyBzdWNoLCBubyBM
YXlvdXRDb21taXQgd2VyZSBkb25lIGFmdGVyIHdyaXRlcyB0byBhIERTIHRoYXQgd2VyZQ0KPiBG
SUxFX1NZTkMNCj4gKG9yIHN0YWJsZSwgaWYgeW91IHByZWZlcikuIFdpdGhvdXQgdGhlIExheW91
dENvbW1pdCwgdGhlIHBORlMgc2VydmVyDQo+IGRpZG4ndA0KPiBrbm93IHdoZW4gaXQgbmVlZGVk
IHRvIGdldCBhbiB1cCB0byBkYXRlIHNpemUuDQo+IFRoZSBGcmVlQlNEIGNsaWVudCBkb2VzIGEg
TGF5b3V0Q29tbWl0IGFmdGVyIHdyaXRpbmcgdG8gYSBEUyB3aGVuZXZlcg0KPiBpdCBpcyBkb25l
DQo+IHdyaXRpbmcsIHN1Y2ggYXMgYW4gZnN5bmMoKSBvciBjbG9zZSgpIHN5c2NhbGwgb24gdGhl
IGZpbGUgb3IgYW4NCj4gdW5sb2NrIG9mIGEgd3JpdGUgbG9jaw0KPiBvbiB0aGUgZmlsZS4NCj4g
DQoNClBsZWFzZSBzZWUgdGhlIEVycmF0YSBJRCAyNzUxIGh0dHA6Ly93d3cucmZjLWVkaXRvci5v
cmcvZXJyYXRhL2VpZDI3NTENCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVz
dA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVi
dXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
