Return-Path: <SRS0=SG1H=QH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF45DC169C4
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 18:12:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE5F4218AF
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 18:12:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="XqXSw9El"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727237AbfAaSM1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 31 Jan 2019 13:12:27 -0500
Received: from mail-eopbgr750070.outbound.protection.outlook.com ([40.107.75.70]:12320
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725730AbfAaSM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 Jan 2019 13:12:27 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PEcrG3LVnnI+A2wTWLkilK4TnmdJ5Ru51g1wmUSFtYA=;
 b=XqXSw9ElxN7ML6KoD2cOYRhtnaGZqRvgwwbee70/EzNeNN/pkTbE1gjm1bTAwNin4zDfqoTjyYlBWVIQq8rbzOS+hZqhIYF5iiPC+sNf617ltf7ZK24nV3fxLmMdXnCtIm/0CCa4JC79RSkqoUmGUw4NEpEIhQnlH4Ph2E6vxcE=
Received: from BN8PR06MB6228.namprd06.prod.outlook.com (20.178.217.156) by
 BN8PR06MB5746.namprd06.prod.outlook.com (20.179.137.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.18; Thu, 31 Jan 2019 18:12:24 +0000
Received: from BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::f88b:ea19:e85a:ab8]) by BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::f88b:ea19:e85a:ab8%3]) with mapi id 15.20.1558.026; Thu, 31 Jan 2019
 18:12:24 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes for 5.0-rc5
Thread-Topic: [GIT PULL] Please pull NFS client bugfixes for 5.0-rc5
Thread-Index: AQHUuZCEkru9OA1SZUuEXQsj7W1pSQ==
Date:   Thu, 31 Jan 2019 18:12:24 +0000
Message-ID: <c00eb546108828e6f73a2aeca5efd041f66593a1.camel@netapp.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.4 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [23.28.75.121]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BN8PR06MB5746;6:BWeowFpMBvVoeXdzbu11dkV/mD96eDFJglhjUyuvt44UWIdFgzXWQ2RhsrT78BHEy5CTFuU1i1gYnCsQ1gmxw2Rt+vp0aUSlkZ/9lO6xyeBjrsEoMNadV4vp/qWAoc2OVxHqu1+xVjbHSmTxulYs7AwqqlIfhSkdE6kux0Mf/Oo8x13CPKwpRcfotm0AA6VYghTIiuSj8xjA4cvgcKR6J2NsCaII0eMkbwZcV9POre0NkO2JZ45sSbuwhuhIIokBruc/kFeu3zDH/EIPKVF5nLzrpqkDyREyCo+PMQaLF71VxdtsiF3cv5nCrLHKUSTOym1JdB0KJlpVZ0ryrPpZ8BY3aGeHkwIKXCoJQVSrHOm2DXFx/4q94+7bsrenYW70odMT2jpxPSCEAH8ZrpiG7bQwbt6VP5C+oVqyF1pZYvlPAGySOe9D7V6cLCrqjfXEz2aWwTkapp3YnT0Qc0YEPQ==;5:k3L3lMS7DTIRvIE1H2V1ufNqRWK16t/eUdJRXj+Q/sz4XxNFM0AkC8pWVuL07vcEQj3gAenlpOSwOi27i9KyZBK7lq4XAswYUOJBdMVdKJyP4e9pHbDElCVjksbxJUxAP5GaQwxnTXRijRP+vE08kyALXQg2WlYqEZGQuEJ+KEenN6EPJIsgQ81raV6yEchKe6np0WwOxgz5Ez52ncj0gw==;7:ZiBgCAoL4bauyL086MsLb16nqSXzirpfT/cNAhuyZ2fYh2m99Eazo7E8XFKmYZYYRN4J13L2OgSKGewYEUd80txnHnG4TUB4t0DPhyhpgIH1nipgUAl26165P8pBXAOl8bUyjvNfzunUQVOIRnp9Rw==
x-ms-office365-filtering-correlation-id: 5aa3f2b1-daa0-4c62-f97c-08d687a7a6e0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7193020);SRVR:BN8PR06MB5746;
x-ms-traffictypediagnostic: BN8PR06MB5746:
x-microsoft-antispam-prvs: <BN8PR06MB574612EB6106352B407E2596F8910@BN8PR06MB5746.namprd06.prod.outlook.com>
x-forefront-prvs: 09347618C4
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(346002)(396003)(376002)(39860400002)(136003)(366004)(199004)(189003)(6116002)(68736007)(478600001)(5640700003)(6486002)(72206003)(2906002)(3846002)(6436002)(97736004)(118296001)(14444005)(25786009)(53936002)(14454004)(256004)(4326008)(6512007)(58126008)(316002)(99286004)(54906003)(305945005)(81166006)(86362001)(71190400001)(186003)(81156014)(8936002)(2501003)(66066001)(6916009)(1730700003)(102836004)(26005)(36756003)(8676002)(106356001)(6506007)(105586002)(2351001)(476003)(7736002)(2616005)(71200400001)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:BN8PR06MB5746;H:BN8PR06MB6228.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: YCGek5tjs9OMWjivjnl5+u2a4XFlHm38g9Lr5fRlF/fTyMnegAx5li6pPDwPFe7Xt35y6IZKKfQD51OPT7ubZUSUx95f3E2mReL3fSF6LgtB6wo/6TvpqVnDpiVVsRylIN7tUphqvRPO+Nwy995re75KCOn2/i0tXNWFRpQo0rFkF+ajC07ZpRCmpUlwtZgy9fhjkhrkTJzcAtEuCxnaeFOSPohGmZAROWuooo2rAbO+NDp95V7jAc3JWQZ4sCqtdRbSNecntBSyMGaRmvFuv7bglu3VdkLPQMjsFYNeA4k/U/oPvI+V8PXlEFl+NDKfxWel1kiEznxGkmvaeTAcihdng92zklLOiycxALDh50QOKDEhgvqwyaMWssHnk2WyC2ZqkkbJuD5oJf4P1ePwYlA84AvD/+rimq6ERPJhbeQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <05C165F6FE2A34489D125015EBA9A23D@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5aa3f2b1-daa0-4c62-f97c-08d687a7a6e0
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jan 2019 18:12:24.6222
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR06MB5746
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgZGVhYTVjOTZj
MmY3ZThiOTM0MDg4YTFlNzBhMGZlODc5N2JkMTE0OToNCg0KICBTVU5SUEM6IEFkZHJlc3MgS2Vy
YmVyb3MgcGVyZm9ybWFuY2UvYmVoYXZpb3IgcmVncmVzc2lvbiAoMjAxOS0wMS0xNSAxNTozNjo0
MQ0KLTA1MDApDQoNCmFyZSBhdmFpbGFibGUgaW4gdGhlIEdpdCByZXBvc2l0b3J5IGF0Og0KDQog
IGdpdDovL2dpdC5saW51eC1uZnMub3JnL3Byb2plY3RzL2FubmEvbGludXgtbmZzLmdpdCB0YWdz
L25mcy1mb3ItNS4wLTMNCg0KZm9yIHlvdSB0byBmZXRjaCBjaGFuZ2VzIHVwIHRvIDhmYzc1YmVk
OTZiYjk0ZTIzY2E1MWJkOWJlNGRhZjY1YzU3Njk3YmY6DQoNCiAgTkZTOiBGaXggdXAgcmV0dXJu
IHZhbHVlIG9uIGZhdGFsIGVycm9ycyBpbiBuZnNfcGFnZV9hc3luY19mbHVzaCgpICgyMDE5LTAx
LTI5IA0KMTY6MzM6MjQgLTA1MDApDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NClRoaXMgcHVsbCByZXF1ZXN0IGFkZHJl
c3NlcyB0d28gYnVncywgb25lIGluIHRoZSBlcnJvciBjb2RlIGhhbmRsaW5nIG9mDQpuZnNfcGFn
ZV9hc3luY19mbHVzaCgpIGFuZCBvbmUgdG8gZml4IGEgcG90ZW50aWFsIE5VTEwgcG9pbnRlciBk
ZXJlZmVyZW5jZQ0KaW4gbmZzX3BhcnNlX2Rldm5hbWUoKS4NCg0KVGhhbmtzLA0KQW5uYQ0KDQot
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tDQpUcm9uZCBNeWtsZWJ1c3QgKDEpOg0KICAgICAgTkZTOiBGaXggdXAgcmV0dXJuIHZh
bHVlIG9uIGZhdGFsIGVycm9ycyBpbiBuZnNfcGFnZV9hc3luY19mbHVzaCgpDQoNCllhbyBMaXUg
KDEpOg0KICAgICAgbmZzOiBGaXggTlVMTCBwb2ludGVyIGRlcmVmZXJlbmNlIG9mIGRldl9uYW1l
DQoNCiBmcy9uZnMvc3VwZXIuYyB8IDUgKysrKysNCiBmcy9uZnMvd3JpdGUuYyB8IDkgKysrKyst
LS0tDQogMiBmaWxlcyBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0K
