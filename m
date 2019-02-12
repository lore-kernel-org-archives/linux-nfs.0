Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3118CC282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 20:33:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D315621B68
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 20:33:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="FQ3M++cD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728054AbfBLUdA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 15:33:00 -0500
Received: from mail-eopbgr710042.outbound.protection.outlook.com ([40.107.71.42]:50368
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727218AbfBLUc7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 15:32:59 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WQqbWW1MJUeyrA1Xp3XZgi319qVaKJW7t7WO9P++VqU=;
 b=FQ3M++cDy0dL0Ev5ggRGdp4Gj+DolLGdwZFK/36yODZlAtuZkTh+QtWCvqxTMLYDs2+ryXZKAlFkk5JGCDNGjm02JiryNBKHYVH4PWB3eSviL0DGfrRBcol199n0WUbueIdRAnz+ZoE49i86OGGXeZRMkGAaw5jZhY0urHWIwmI=
Received: from BN8PR06MB6228.namprd06.prod.outlook.com (20.178.217.156) by
 BN8PR06MB6082.namprd06.prod.outlook.com (20.179.136.97) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.19; Tue, 12 Feb 2019 20:32:56 +0000
Received: from BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::d2f:dbea:270:9aea]) by BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::d2f:dbea:270:9aea%3]) with mapi id 15.20.1601.023; Tue, 12 Feb 2019
 20:32:56 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "nmoreychaisemartin@suse.com" <nmoreychaisemartin@suse.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
Thread-Topic: [PATCH v3] xprtrdma: Make sure Send CQ is allocated on an
 existing compvec
Thread-Index: AQHUvXd7jRtZCKrmVEic4q5R0FnjraXcRW6AgABj54A=
Date:   Tue, 12 Feb 2019 20:32:56 +0000
Message-ID: <580bbfcd53b712edb255c3824cb4e1fc0ffa958e.camel@netapp.com>
References: <9d418664-1f67-c705-19a0-80fc9dc5a12b@suse.com>
         <91CC910C-48A1-4234-8347-39D1A710A87C@oracle.com>
         <f9291365-bbb7-f516-cac0-0a8b28fa22ec@suse.com>
In-Reply-To: <f9291365-bbb7-f516-cac0-0a8b28fa22ec@suse.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.5 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [73.145.169.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 48f32e3b-2fc1-45fd-ba9b-08d69129459d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7193020);SRVR:BN8PR06MB6082;
x-ms-traffictypediagnostic: BN8PR06MB6082:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCTjhQUjA2TUI2MDgyOzIzOkY2S1VxWjVCVUs0Um9NNU1sb0w2OXVsVGtR?=
 =?utf-8?B?cjVlZUplYlo3ODd6OFFiUzhqWnpRMWdvcFd6d1dtTUNQNUlUOS9jcitmVDdQ?=
 =?utf-8?B?QmJMczVSeTFTWEFWY0VFOXB1cGpZZXMvcGRoQ0c0TVBuUXp5RStGVDl6V0Jk?=
 =?utf-8?B?eWdZZ2dEOWVDcTN1ZzZDN01ac1pWWmpyTmhFR2wwVjFoSHc2WUlWN1BTSWly?=
 =?utf-8?B?a0w0T2dpaitCbWVXKzl1ek82QW5vRXp3QlhadGxIY3NOV3plZVNGaTdPR3Bn?=
 =?utf-8?B?STBmUWJ3ZUdJcEhuZ3MvS3dOSVNrdi9XaElEa1paK0VpU0djcUNLU2J3WE5I?=
 =?utf-8?B?NGlVUW9wZ2FQY01yclQvYU1kNDkvb3NrdDJqQ2xnUjJHYmpyYTJYanJUamh3?=
 =?utf-8?B?UmdBVlNSSzd4YmE3aldFT2JLQUQ2dWtobGtlWWV5VHAxbzNJNDE2MmV5R0xz?=
 =?utf-8?B?RHRUNXczQlNReGM5Sy9tczdhSktmc1Z3VkJNQlJGNmR5OTNSQmh0M3ZXaGk4?=
 =?utf-8?B?dndlVytWRUdtTGZQNkpjM2VYN1VnZnkwcjQvTEUyTStWLzZiOS9FMWhUWFZE?=
 =?utf-8?B?bEx3STBXSDVrS0VybmRLUlR1dTRGTWd5YnF4MUluTXJnOUFPZUFBaW42aE9K?=
 =?utf-8?B?UjBjbHErU2lpSUlTRG13SjZPdDh4WTVqTXRSN2J1MS93a3I1NUZ0T1kyMEtm?=
 =?utf-8?B?azdPTWFTZGIzZFdPVytWMVltR2l4TmRaQ3JTQjFlZHIwZDFIU1FZQ1p3Vitn?=
 =?utf-8?B?SmowTzAzengvYkZyT3hCa2g3ZFBJR1VoQ1hHd1dtWndqc3BPM2xvU2JjL1I3?=
 =?utf-8?B?by9LaTA1QlRDbC9QTnZzWlZwaDhCaVV3aFJFRFBnTnZwRUFHOHJNcDM0Uk52?=
 =?utf-8?B?VitrTXZXYUNsb0taMVNXOTh5WWtibWxvd2pWNm9NM2x2K1g1UXJ2eFloa2lP?=
 =?utf-8?B?aHdsRnpUNGtERzBJeGhmS1FYd3VVcWpCWCt4WHJyRFNHbHMzZndzREUzMkgx?=
 =?utf-8?B?WFYyTndGZHczdGNVVzBDa0NPR0lRNVhDcEZWSEozVm9kRUJlcjlCZEU0TUxS?=
 =?utf-8?B?WHRGV2ZxUitXUUFOWElwZUduV0tnZFlFTmVwZ2ViSnkyZTJLeEFieHJXbUxk?=
 =?utf-8?B?TUUzTUhBRG5LeHVlTXJZWjlqUnpYRThiMjZtb0tlMjN4UjR5a0V0TkFpSTVu?=
 =?utf-8?B?Qk5WeVMrY0VpR0VLZzZxSk5OMXFaeWxiMGNqZmg4NEhnSm5vRXYzZkJRek9H?=
 =?utf-8?B?cW0xMWk4dU9TWkdMbEZuNzhuWEppUnRCZlR0TXRMbUtXZkVsOTdPdHRXYVdH?=
 =?utf-8?B?aElpbVpXdmhNSXJ2TG9CQk5tS2twNVBBV0NPUEtkcThVMVFjaUYrSUVHT1hP?=
 =?utf-8?B?aUFEUit3SWpEYVpSTmQ2SUMxejlEaU5POGRIWjF5UFJDRGM3aFBpS1J5eWlZ?=
 =?utf-8?B?UExLdEg5SUhHN1FyMVJtN1E2aUNEUUhIRXJiWUxKakRheGtQK2Rud2lHNFdw?=
 =?utf-8?B?UStzSnZTSERjN3ZtRE5hS3dNM29uaElYU2QweVdjL0FsL1YvUXVlRHNhY1l1?=
 =?utf-8?B?ck90OEVJbGFDbExweG9sWEdTQzg3QTdySGRrRTdtL1YzZjZCdTFROTBDZzBw?=
 =?utf-8?B?Q2lrWGZWaHg0WFZwQmhGN2lVTkg4Rnp4VnZqdW5GaC9hVzZyY0pkTm5wb1lG?=
 =?utf-8?B?VXNTL3RJZXZEdndBWlJBS0ZPbmlxMXNvaHRqQjg0dGFkaVRvSHVHU1QrR3NK?=
 =?utf-8?B?YXYzQ0MvelpFbkZaQ0NPUURXYjNkeWhLQ01xZlo0VndNTm9WbVlsVVFvVTg1?=
 =?utf-8?Q?ybyAGfES1SAEa?=
x-microsoft-antispam-prvs: <BN8PR06MB60823270295CDE5D77FF7A58F8650@BN8PR06MB6082.namprd06.prod.outlook.com>
x-forefront-prvs: 0946DC87A1
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(366004)(346002)(136003)(39860400002)(376002)(396003)(51914003)(199004)(189003)(71200400001)(72206003)(6246003)(97736004)(2501003)(4744005)(2906002)(305945005)(256004)(8936002)(14444005)(229853002)(8676002)(14454004)(7736002)(81166006)(81156014)(110136005)(76176011)(5024004)(71190400001)(53936002)(6512007)(6486002)(68736007)(316002)(54906003)(478600001)(58126008)(53546011)(6436002)(486006)(66066001)(36756003)(2616005)(86362001)(476003)(6506007)(186003)(102836004)(26005)(6116002)(3846002)(4326008)(99286004)(446003)(25786009)(105586002)(106356001)(118296001)(11346002);DIR:OUT;SFP:1101;SCL:1;SRVR:BN8PR06MB6082;H:BN8PR06MB6228.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Pj9E/zT8lEKi3bUXXC2+WYpy1SHT12oSdWocuV7u9hcGSLhih8PHsPk3o72yNx25K6P0Q/mVrIZSEQsbdjJ7I+yqGUBUu8Wg++cq/K8V2PJrPmQ8Nwzy0gau8UdBAcVf57soANFMkX1LE0B7uhbEYvLQlcDMXGIVeRMksn6W93LUSBdVNomjZH1SGqwihu0mw9PiZpe8PIkjEvJj26NIkH5h7EbgWzYPfXwNzYEJw8zIdiVsrpplu32RSUBRMGL3l4aNNvHzErt4QzgTakdg/FgioO1BkfzIPscBNzGazIZXFuETlYDK9dTm78XKA0GO3cEPYyx1wgRg13TyuhGRFp/pY/wyh2CxuAg4gjsrApnWpG4yWCFiTYL4XzHULNVRcC6ek39/b0mHLhl1cO/69+DORxdJBOtcOYxI3RCyqG0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B33990FBEE740A4B9BF199165186E1B4@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 48f32e3b-2fc1-45fd-ba9b-08d69129459d
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Feb 2019 20:32:56.6214
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR06MB6082
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAyLTEyIGF0IDE1OjM1ICswMTAwLCBOaWNvbGFzIE1vcmV5LUNoYWlzZW1h
cnRpbiB3cm90ZToNCj4gTmV0QXBwIFNlY3VyaXR5IFdBUk5JTkc6IFRoaXMgaXMgYW4gZXh0ZXJu
YWwgZW1haWwuIERvIG5vdCBjbGljayBsaW5rcyBvciBvcGVuDQo+IGF0dGFjaG1lbnRzIHVubGVz
cyB5b3UgcmVjb2duaXplIHRoZSBzZW5kZXIgYW5kIGtub3cgdGhlIGNvbnRlbnQgaXMgc2FmZS4N
Cj4gDQo+IA0KPiANCj4gDQo+IE9uIDIvNS8xOSA2OjIzIFBNLCBDaHVjayBMZXZlciB3cm90ZToN
Cj4gPiA+IE9uIEZlYiA1LCAyMDE5LCBhdCAxMjoyMSBQTSwgTmljb2xhcyBNb3JleS1DaGFpc2Vt
YXJ0aW4gPA0KPiA+ID4gbm1vcmV5Y2hhaXNlbWFydGluQHN1c2UuY29tPiB3cm90ZToNCj4gPiA+
IA0KPiA+ID4gTWFrZSBzdXJlIHRoZSBkZXZpY2UgaGFzIGF0IGxlYXN0IDIgY29tcGxldGlvbiB2
ZWN0b3JzDQo+ID4gPiBiZWZvcmUgYWxsb2NhdGluZyB0byBjb21wdmVjIzENCj4gPiA+IA0KPiA+
ID4gRml4ZXM6IGE0Njk5ZjU2NDdmMyAoeHBydHJkbWE6IFB1dCBTZW5kIENRIGluIElCX1BPTExf
V09SS1FVRVVFIG1vZGUpDQo+ID4gPiBTaWduZWQtb2ZmLWJ5OiBOaWNvbGFzIE1vcmV5LUNoYWlz
ZW1hcnRpbiA8bm1vcmV5Y2hhaXNlbWFydGluQHN1c2UuY29tPg0KPiA+IFJldmlld2VkLWJ5OiBD
aHVjayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gPiANCj4gPiBBbm5hLCBjYW4g
eW91IHNlZSB0aGF0IHRoaXMgZml4IGdldHMgaW50byB2NS4wLXJjID8gVGhhbmtzIQ0KPiA+IA0K
PiA+IA0KPiBQaW5nLg0KPiANCj4gSGF2ZW4ndCBzZWVuIHRoaXMgdXBzdHJlYW0gbm9yIGluIHRo
ZSBuZnMgcmVwbyAobWF5YmUgSSdtIG5vdCBjaGVja2luZyB0aGUNCj4gcmlnaHQgb25lIDopICkN
Cj4gQW55IGNoYW5jZSB0aGlzIGdldHMgcGlja2VkIHVwIGZvciA1LjAgPw0KDQpUaGFua3MgZm9y
IHRoZSByZW1pbmRlciEgIEknbGwgcGxhbiBvbiBwdXNoaW5nIGl0IG91dCBmb3IgNS4wIHRoaXMg
d2Vlay4NCg0KVGhhbmtzLA0KQW5uYQ0KPiANCj4gTmljb2xhcw0K
