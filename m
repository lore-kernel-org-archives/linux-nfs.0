Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A72CBC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 11:58:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5D9012176F
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 11:58:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YmP+YA4G"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729720AbeLTL6K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 06:58:10 -0500
Received: from mail-eopbgr730135.outbound.protection.outlook.com ([40.107.73.135]:53856
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729103AbeLTL6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 06:58:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HV73zBydlu9ijYT4Oc0/pUmmbJBdAX2YRkZA6M6rM8o=;
 b=YmP+YA4GX7iCCYGXVp5bkQSVzPYYzLK0oc2hj4RydFlD2aBDsB2DyPTT0L7oUEznEceMbKsoQbIlbFw79NDdg3nfHiILj/iGSd7BxS3Dau50bNT1xS+lNpCFu6J9IrNz9XVjvcgqJx84j7frsvT4gi4R7kn+o61AvqS7ogtxudU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2416.namprd13.prod.outlook.com (52.135.94.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.15; Thu, 20 Dec 2018 11:58:05 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1471.011; Thu, 20 Dec 2018
 11:58:05 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "vvs@virtuozzo.com" <vvs@virtuozzo.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Topic: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwCAAFXvAIAAC0AAgAD2awCAAO6fgIAABX+AgAB+KwCAAClHAA==
Date:   Thu, 20 Dec 2018 11:58:04 +0000
Message-ID: <8cd0f4191c4a98d5f27ba15f78ea1b9b990ab0f1.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
         <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
         <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
         <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
         <eef084b9-4f1e-99e7-4d1a-a6e88b61d564@virtuozzo.com>
         <48844583b23fbbac600dfc86c49a7c71c5db36eb.camel@hammerspace.com>
         <d0b35e30-2eae-123e-19c6-fcd3cd93ab86@virtuozzo.com>
         <2459cc18-3c14-fb68-def6-eb09fc096613@virtuozzo.com>
         <76d71f3412b3104b917aa836eede3447db35bda0.camel@hammerspace.com>
         <11b7dec4-cd81-cb23-68f9-d56b5df79337@virtuozzo.com>
In-Reply-To: <11b7dec4-cd81-cb23-68f9-d56b5df79337@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [77.241.229.232]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2416;6:apyb6nDHRxcXoXg/nuM+Cx/WmHbE5+IMFfg/V8Umwjluhdy7mgi7TDrFRiraUWgADOsNITSerQ7v00UzDQJaMnMKLZZTKaC63eRxrFD0t15S+uO3qFjAnPJlwhE8fT4DdrnEYK3Y9zHwBDx34CE10+56aMQghwBif6XRXMd7RMCd+bVREPU41B7r827U+n14yzcuBkwg4xmMw1tMBqmcT2LBCdthZbmnacZ00L1tMn7mKku0lcDZQ8fbnMOeA1a3Yhdo1mCJExzFdHehw0tVQ/OecDTVdNWxgb3VJzL+i5cD+9Icas5tG3bgcVneC8FXhan2n4Bl3HSV5QYzgbp4f8VkiQL5wTwKDkU74O/gOrHNXOCt6+cOl2Z9l9up0W/B4flrAjuBykF9vUWUMvd5t50DWjzf96YS9BbQ7WVAm5mNbBJVahHSYEMAS/OYmc2RLbiebBWuXWiAvzsRiSca4w==;5:u6vNmAEjwToG42yatFuLWT23Jt/zuDF9V43lKRx8lxCqLh84U0B3iIcf15LeDus3z8nC15jM21snUEttQVbuIQ4yKv8N4y2qGhxazWX7bSQEUta2X0H9Wsc9XJ1w1/oPu0MCyWaK46JrqiYKaL2Ckv5lJ3HBXPmoUadXKzOkRjU=;7:qqSh7nctNV6i+pa9xU6q1ENcaA93KRCU+C3CYTGBMUdnLjRgSwjEisRwCcdxONNGkJFpN/zLTRu/Hb1hc7J5+rwjdBcM5SSqPnWrWd8kR3A8sPzEqpX3ypCN1XAYqzP0Y+aI34e9BCdY0fcfC/Orxg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 0dec507f-ddfc-4915-1346-08d66672667c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2416;
x-ms-traffictypediagnostic: SN6PR13MB2416:
x-microsoft-antispam-prvs: <SN6PR13MB24165D072A683A5584FE7FCDB8BF0@SN6PR13MB2416.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(5005026)(6040522)(2401047)(8121501046)(10201501046)(3002001)(3231475)(944501520)(52105112)(93006095)(93001095)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123558120)(20161123560045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2416;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2416;
x-forefront-prvs: 0892FA9A88
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(376002)(366004)(136003)(346002)(39830400003)(199004)(189003)(76176011)(15974865002)(6306002)(11346002)(6512007)(256004)(14444005)(8936002)(66066001)(54906003)(7736002)(99286004)(2616005)(106356001)(2906002)(316002)(446003)(105586002)(2501003)(110136005)(6506007)(6116002)(8676002)(3846002)(86362001)(36756003)(93886005)(478600001)(6246003)(102836004)(186003)(966005)(6486002)(53546011)(14454004)(25786009)(5660300001)(26005)(68736007)(53936002)(486006)(81156014)(81166006)(97736004)(71190400001)(71200400001)(229853002)(4326008)(476003)(305945005)(4001150100001)(118296001)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2416;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: x+VcNzkrhAx3DZYyb+sIhbPUOfW2NndaVETkbAnAn4G7En3Xd7xOzrb4Bs7JZaDnmLuKh7wDza/dkCmitCoeidAz6BuyMNrWDB0xfQvV5bUNvY06T0yXWdj9cO360nUi0rXvbh9B5W8NLhq1KhE/BnUuV2BnGAnQRXS5SwDOihzlT+2qODCK1yqgqQXC9vEOF38OvlV3R9ouwN0TM2v07jwQZEfuJMXAAVY04OBxijCSoF8e1Rv0ETr9dtaU//vGS8CcEf+nzWO+zj3GxOrLyKJnLbFJynr59VOne8O2RclcG48VEgJDzcGBSuF/c71x
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <889241F21E653D479942F06BF2FEFEC6@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0dec507f-ddfc-4915-1346-08d66672667c
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Dec 2018 11:58:04.9655
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2416
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTEyLTIwIGF0IDEyOjMwICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8yMC8xOCA0OjU4IEFNLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gT24gVGh1
LCAyMDE4LTEyLTIwIGF0IDA0OjM5ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0KPiA+ID4g
RGVhciBUcm9uZCwNCj4gPiA+IFJlZCBIYXQgc2VjdXJpdHkgYmVsaWV2ZXMgdGhlIHByb2JsZW0g
aXMgcXVpdGUgaW1wb3J0YW50IHNlY3VyaXR5DQo+ID4gPiBpc3N1ZToNCj4gPiA+IGh0dHBzOi8v
YWNjZXNzLnJlZGhhdC5jb20vc2VjdXJpdHkvY3ZlL2N2ZS0yMDE4LTE2ODg0DQo+ID4gPiANCj4g
PiA+IEZpeCBzaG91bGQgYmUgYmFja3BvcnRlZCB0byBhZmZlY3RlZCBkaXN0cmlidXRpb25zLg0K
PiA+ID4gDQo+ID4gPiBDb3VsZCB5b3UgcGxlYXNlIGFwcHJvdmUgbXkgZmlyc3QgcGF0Y2ggYW5k
IHB1c2ggaXQgdG8gc3RhYmxlQCA/DQo+ID4gPiBGcm9tIG15IFBvViBpdCBpcyBjb3JyZWN0bHkg
Zml4ZXMgdGhlIHByb2JsZW0sIGl0IGJyZWFrcyBub3RoaW5nDQo+ID4gPiBhbmQNCj4gPiA+IGVh
c3kgZm9yIGJhY2twb3J0cywNCj4gPiA+IGxpZ2h0bHkgbW9kaWZpZWQgaXQgY2FuIGJlIGV2ZW4g
bGl2ZS1wYXRjaGVkLg0KPiA+ID4gDQo+ID4gPiBPdGhlciBwYXRjaGVzIGluY2x1ZGluZyBzd2l0
Y2ggdG8gdXNpbmcgZW1wdHkgcnFzdC0+cnFfeHBydCBjYW4NCj4gPiA+IHdhaXQuDQo+ID4gPiAN
Cj4gPiANCj4gPiBUaGF0IHBhdGNoIGlzIG5vdCBhY2NlcHRhYmxlIGZvciB1cHN0cmVhbS4NCj4g
DQo+IEluIHRoaXMgY2FzZSBob3cgYWJvdXQgbXkgaW5pdGlhbCBwbGFuIEIgLS0gbWFrZSBzdmNf
c2VydiBwZXIgbmV0LQ0KPiBuYW1lc3BhY2U/DQo+IEl0IGV4ZWN1dGVzIGFkZGl0aW9uYWwgcGVy
LW5ldG5zIG5mc3Y0IGNhbGxiYWNrIHRocmVhZHMgDQo+IGJ1dCBkb2VzIG5vdCByZXF1aXJlIGFu
eSBjaGFuZ2VzIGluIGV4aXN0aW5nIHN1bnJwYyBjb2RlPw0KDQpDYW4gd2UgcGxlYXNlIGZpeCB0
aGlzIGlzc3VlIHByb3Blcmx5IHdpdGhvdXQgYWRkaW5nIG1vcmUgaGFja3M/IFRoZQ0KaGFja3Mg
YXJlIHdoYXQgaGFzIGNhdXNlZCB0aGUgcHJvYmxlbSBpbiB0aGUgZmlyc3QgcGxhY2UuDQoNClRo
ZSBzZXJ2ZXIgdHJhbnNwb3J0IGNvZGUgaXMgY29tcGxldGVseSBpcnJlbGV2YW50IHRvIHRoZSBj
bGllbnQNCmJhY2tjaGFubmVsIGFuZCBzbyBhbnl0aGluZyBpbiB0aGUgYmFja2NoYW5uZWwgY29k
ZSBwYXRoIHRoYXQgcmVsaWVzIG9uDQp0ZXN0cyBvciBjaGVja3Mgb2YgdGhlICJzZXJ2ZXIgdHJh
bnNwb3J0IHN0YXRlIiBpcyBnb2luZyB0byBiZSBicm9rZW4uDQoNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpDVE8sIEhhbW1lcnNwYWNlIEluYw0KNDMwMCBFbCBDYW1pbm8gUmVhbCwgU3VpdGUgMTA1
DQpMb3MgQWx0b3MsIENBIDk0MDIyDQp3d3cuaGFtbWVyLnNwYWNlDQoNCg0K
