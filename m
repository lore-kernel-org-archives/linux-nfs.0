Return-Path: <SRS0=9XaN=P6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B668C282C3
	for <linux-nfs@archiver.kernel.org>; Tue, 22 Jan 2019 05:24:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 126D020870
	for <linux-nfs@archiver.kernel.org>; Tue, 22 Jan 2019 05:24:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="fyqtL1mI";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="iBjuKjlr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725913AbfAVFVU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 22 Jan 2019 00:21:20 -0500
Received: from esa3.hgst.iphmx.com ([216.71.153.141]:48007 "EHLO
        esa3.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725862AbfAVFVU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2019 00:21:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1548134479; x=1579670479;
  h=from:to:subject:date:message-id:references:in-reply-to:
   content-id:content-transfer-encoding:mime-version;
  bh=tImrK8O7/x1HzvadlUoez2qNF3sCFLBtvqSIfO1CnYk=;
  b=fyqtL1mIFjHjcmPtQ4h5+WwbRtAQiMrvQ9fNk02+99oDxA6/TLUB3oy+
   3yGMfdzAqFVo9k4K9LvNIqVZxfnYuwL21lrqlHQAuEV1kExM3b1hIHWx2
   7NfhP71CXCMeimvOWNT3cedTKI19nvHK6a4TczF68qvlwDUU9U+M5BLag
   OmCCjTK3IbCybvrLjSxdrUftiQLsbwFgmN2nnDtzQH2OOOAJT7AmV5kSw
   jhHySFCJPP0nLPm4NrFunQeH+YdeUPIq4fMeXD2tQmCsMXT48XMCma/5I
   6oRhEh/3bQjAzOUbXxn7nZDpKJhU+bUlr3R9zgEhfhoocjammbdPO+bU9
   Q==;
X-IronPort-AV: E=Sophos;i="5.56,505,1539619200"; 
   d="scan'208";a="104362768"
Received: from mail-by2nam03lp2053.outbound.protection.outlook.com (HELO NAM03-BY2-obe.outbound.protection.outlook.com) ([104.47.42.53])
  by ob1.hgst.iphmx.com with ESMTP; 22 Jan 2019 13:21:19 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector1-wdc-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tImrK8O7/x1HzvadlUoez2qNF3sCFLBtvqSIfO1CnYk=;
 b=iBjuKjlrphwaB8GF0dSTsBuyqm+RGoiDiRXMCiK+kuTmNSqHnjNUCuPUkez+01rOq0+7sttDsa3EU2ScBtAsq25klSXMBjPGhC/c6q/wqFNMIaovNvwiip4JBeU4B7sAQA1uWx7com8qQi/egmcCy8AE/zbdWnO4MitmnoFli5o=
Received: from DM6PR04MB4393.namprd04.prod.outlook.com (20.176.77.146) by
 DM6PR04MB5177.namprd04.prod.outlook.com (20.178.24.86) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.16; Tue, 22 Jan 2019 05:21:17 +0000
Received: from DM6PR04MB4393.namprd04.prod.outlook.com
 ([fe80::6513:bbd2:4fef:4ff0]) by DM6PR04MB4393.namprd04.prod.outlook.com
 ([fe80::6513:bbd2:4fef:4ff0%2]) with mapi id 15.20.1537.031; Tue, 22 Jan 2019
 05:21:17 +0000
From:   Santosh Kumar Pradhan <SantoshKumar.Pradhan@wdc.com>
To:     Laura Abbott <labbott@redhat.com>,
        Dave Jones <davej@codemonkey.org.uk>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at kernel/cred.c:825!
Thread-Topic: kernel BUG at kernel/cred.c:825!
Thread-Index: AQHUpsNeFKa7nd7bAEyfRz0m47soa6WyUF0AgAji54A=
Date:   Tue, 22 Jan 2019 05:21:16 +0000
Message-ID: <FD4A790B-8137-49AC-A8FA-42A0D9B346EC@wdc.com>
References: <20190107191841.nejcug5dcdrt5e3a@codemonkey.org.uk>
 <577c9205-ca83-459e-dd2a-5dfed1d2df25@redhat.com>
In-Reply-To: <577c9205-ca83-459e-dd2a-5dfed1d2df25@redhat.com>
Accept-Language: en-US
Content-Language: en-GB
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [129.253.179.161]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM6PR04MB5177;6:kmt8ceBLVjODc3RhM73ZQDpT0gNTE22YyoH7RXRfSDrpQfgaieW2tuWNcw/QuPZirV8bTGjuJs9mqPF0buu4liZceQoTUa8f2JXlkvhDtG/asbOI7e2selekWaVRHGbCKTqbfd8bOxlXFUIGM9Mvz8tNLVrgmVnazjAY2N/cXQOpA42noLiUDpj0t0tJfj4wdBZx8pHnGZUbVz+lwey+9h0hfzgMg7uDbbICQPuTUSrgEd124I88rz53IH9qO8mUKeydO1CE7pRJ/BxxFTbit1vUAPDn83mHzp9dnNnMAcpDDrfsBp15G73m2HO6ui+kdCl0OmiVrN1f8sMJFeplvBwx5mQrslWzMtYr94huscxkkwRidzURqj1WcWaifn0y/pPOPchVuLTvHqV6zO3Yxp/+tvfsMhsyQRZhkIlcxdJPaLEPr5EdGmlS6W9hCHBIjn46g3WoTvbH9q2/AzX1dA==;5:Ivy5I5/XgpXxwXqaCp+z8ykcKP4lWXsvu5MCjQDFI7uf3C+JP63ltdnC9hMsjblOoC4nqxQ4aOcGrf5bhiO9iuk9PFvCl46v1bLwUUBLsFWBKN9f/qy18lsFRK9dV+NhSYffJ7LAXiKOwI7YTHRl8A4ACFcd6ktSlrRKYlmxDiB2JQieS+i/9PNXI5rFRGiipnhmTY51HUTSIuTC5Fljyg==;7:Kd95u4NHioSmt+uEZuv1+ZMU9U1Zs6KzDSff36sdTBsuDNHQi3SH6Hingi4vxlcmbIvD4prINPgZEhTsiqEGxyFlaQN1UPWtBRECiP63hJGNkHnJe2jmjnSYP73ODqCGhioyIlSb8NgWXnRGtky96A==
x-ms-office365-filtering-correlation-id: dc842216-2c28-4323-0e33-08d680296f96
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(4618075)(2017052603328)(7153060)(7193020);SRVR:DM6PR04MB5177;
x-ms-traffictypediagnostic: DM6PR04MB5177:
wdcipoutbound: EOP-TRUE
x-microsoft-antispam-prvs: <DM6PR04MB517714FD1E4FE2EC78A37F4B97980@DM6PR04MB5177.namprd04.prod.outlook.com>
x-forefront-prvs: 0925081676
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(39860400002)(136003)(346002)(376002)(199004)(189003)(476003)(53546011)(102836004)(53936002)(6506007)(8936002)(6346003)(2501003)(25786009)(71200400001)(71190400001)(478600001)(11346002)(83716004)(33656002)(76176011)(2616005)(82746002)(7736002)(305945005)(226693001)(66066001)(486006)(99286004)(256004)(6116002)(3846002)(105586002)(106356001)(68736007)(86362001)(4744005)(6486002)(446003)(8676002)(36756003)(81166006)(81156014)(229853002)(26005)(6436002)(110136005)(72206003)(316002)(186003)(6512007)(2906002)(14454004)(97736004)(6246003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR04MB5177;H:DM6PR04MB4393.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=SantoshKumar.Pradhan@wdc.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: eMeoJtVO8zhKsrQFSeUDl9+Uif45DjB6uQ4Pf6zHUbmHjG4l1u2Vb0pfpKWLZRDi9FRnwbHfQ1hJJJdTXTEFVFrk5zyVPBJscG2kQIjHbJsQErJZFjYpWuq2mzRWOGXUcudVuo0l2fGfo7uV1SJYQUBZkpQtVfVSWnrQgbw+r18DETm4b6jahIK2JF75u1dZZ900wJbjQEZEBSAt9aQWW6TDhj/E17hr5Zqkm9jAn0grydXMknGvYgneV0iaDgLGhjDAi8ybQCEfkNRj55lr+bkHAv532HCAMCX/FzhbV5G6LqwYjcXy5gHt9dOE+Yy/8l1p9ThqdEnn/Dvf2gnAelIR9FtryBBZz3F1CvUmgZuIM2rB/LXqmD5S6qB34dALHMpP+x1b9QO+/cLznpmDT6QlQQOpeBF88ty/yyY7J4M=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <6DCC592EEF93C64996E5AD5A5AC4B66D@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: dc842216-2c28-4323-0e33-08d680296f96
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Jan 2019 05:21:17.1641
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR04MB5177
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGF1cmEsDQoNCk9uIDE3LzAxLzE5LCAxMjozOSBBTSwgImxpbnV4LW5mcy1vd25lckB2Z2Vy
Lmtlcm5lbC5vcmcgb24gYmVoYWxmIG9mIExhdXJhIEFiYm90dCIgPGxpbnV4LW5mcy1vd25lckB2
Z2VyLmtlcm5lbC5vcmcgb24gYmVoYWxmIG9mIGxhYmJvdHRAcmVkaGF0LmNvbT4gd3JvdGU6DQoN
CiAgICBPbiAxLzcvMTkgMTE6MTggQU0sIERhdmUgSm9uZXMgd3JvdGU6DQogICAgPiBbICAgNTMu
OTgwNzAxXSBORlNEOiBVc2luZyAvdmFyL2xpYi9uZnMvdjRyZWNvdmVyeSBhcyB0aGUgTkZTdjQg
c3RhdGUgcmVjb3ZlcnkgZGlyZWN0b3J5DQogICAgPiBbICAgNTMuOTgxMjE2XSBORlNEOiBzdGFy
dGluZyA0NS1zZWNvbmQgZ3JhY2UgcGVyaW9kIChuZXQgZjAwMDAwOTgpDQogICAgPiBbICAgNTQu
MDA2ODAyXSBDUkVEOiBJbnZhbGlkIGNyZWRlbnRpYWxzDQogICAgPiBbICAgNTQuMDA2ODgwXSBD
UkVEOiBBdCAuL2luY2x1ZGUvbGludXgvY3JlZC5oOjI1Mw0KICAgID4gWyAgIDU0LjAwNjg5OV0g
Q1JFRDogU3BlY2lmaWVkIGNyZWRlbnRpYWxzOiAwMDAwMDAwMDVkYWE0NTI5DQogICAgPiBbICAg
NTQuMDA2OTE2XSBDUkVEOiAtPm1hZ2ljPTAsIHB1dF9hZGRyPSAgICAgICAgICAobnVsbCkNCiAg
ICA+IFsgICA1NC4wMDY5MjddIENSRUQ6IC0+dXNhZ2U9MSwgc3Vic2NyPTANCiAgICA+IFsgICA1
NC4wMDY5MzVdIENSRUQ6IC0+KnVpZCA9IHsgMCwwLDAsMCB9DQogICAgPiBbICAgNTQuMDA2OTQ0
XSBDUkVEOiAtPipnaWQgPSB7IDAsMCwwLDAgfQ0KICAgID4gWyAgIDU0LjAwNjk1NF0gLS0tLS0t
LS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0tDQogICAgPiBbICAgNTQuMDA2OTY0XSBrZXJu
ZWwgQlVHIGF0IGtlcm5lbC9jcmVkLmM6ODI1IQ0KICAgIA0KID4gDQogICAgDQogICAgRmVkb3Jh
IHN0aWxsIHNlZW1zIHRvIGJlIGhpdHRpbmcgdGhpcyBhcyBvZiAtcmMyDQoNClRoZSBGSVggaXMg
bWFkZSBpbnRvIOKAk3JjMy4NCg0KQmVzdCBSLA0KU2FudG9zaA0KICAgIA0KDQo=
