Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38BB8C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:55:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1F9E2064C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:55:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="f/a6uHcT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1F9E2064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728007AbeKBC6w (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 22:58:52 -0400
Received: from mail-eopbgr810117.outbound.protection.outlook.com ([40.107.81.117]:33239
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727417AbeKBC6v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 22:58:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hcYtdtReI1luzarTOcV7r9lYj2mt5hItlg686A8e6Ik=;
 b=f/a6uHcT7hw0LMehsmd9xa7A4EWCO+FSN7TFm3GlIOEA6ijVV3ShbaF/Ke8mfdtOWhCkkQjHoEhy9occ8FAXPI2DOxI5UdpJeWr/bNE9peJEIRI45RBGF79nFPrSPGQKa85gUUiy7SrIl1N8NK5XY4en0zUv3MQ9yoXt56Shq1s=
Received: from MWHSPR00MB117.namprd22.prod.outlook.com (10.175.52.23) by
 MWHPR2201MB1325.namprd22.prod.outlook.com (10.174.162.140) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1273.25; Thu, 1 Nov 2018 17:54:50 +0000
Received: from MWHSPR00MB117.namprd22.prod.outlook.com
 ([fe80::b95a:a3f9:be06:b045]) by MWHSPR00MB117.namprd22.prod.outlook.com
 ([fe80::b95a:a3f9:be06:b045%2]) with mapi id 15.20.1294.024; Thu, 1 Nov 2018
 17:54:50 +0000
From:   Paul Burton <paul.burton@mips.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
CC:     "linux@roeck-us.net" <linux@roeck-us.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jhogan@kernel.org" <jhogan@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "paulus@samba.org" <paulus@samba.org>,
        "mpe@ellerman.id.au" <mpe@ellerman.id.au>,
        "benh@kernel.crashing.org" <benh@kernel.crashing.org>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Thread-Topic: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Thread-Index: AQHUcVNC5jTXGaDPOkOnkxlkE4DPdqU539kAgAAIcYCAABkQgIAADI6AgAEnZwA=
Date:   Thu, 1 Nov 2018 17:54:50 +0000
Message-ID: <20181101175448.sld6krwbs5n7ovak@pburton-laptop>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
In-Reply-To: <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR2201CA0004.namprd22.prod.outlook.com
 (2603:10b6:301:28::17) To MWHSPR00MB117.namprd22.prod.outlook.com
 (2603:10b6:300:10c::23)
user-agent: NeoMutt/20180716
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [4.16.204.77]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;MWHPR2201MB1325;6:sphfPo3E+yvokQfm9L2JT3epAssx6+GoXoQWVmEbJD3eBNrmHRsFlnWHazxO+E5LpdSB95ZSSkS24tR/AYsasqpVMBmIiDBhY+LoeX60WeMWt4YxDxFAWFFRGiRw55tn8SFB4oz6fOsKcmZhxcsFm3hZiANwbZMVulNvrenq3PwTLyFeko7lT83MMQAIWB0BBiG20DY/7Np1HWBi5ILPgPfZbtNEkPx1M7mjCPedEdO959+w1MGBr2PXdYQILrsOVEupbTyTN++q/5DLf6ooIH91G7iohCuH32wxvnwp2qZnXCKoST/dAp1VKlYBPczPKyvWOhpYRmqRuDZuvHIsQrNXudEFbFOEMHBrmia0YuQjxhM9zN2isNERpSl/20fzPuM9ZesSRUYPh9/SCV6KfanFbFAtHp8k0AyZIcIIzjKvc3bgHTIRe4JUYaNeBLJk03Wq/NFsg+JQvho0G5So2g==;5:pX81+2CTXr0knMg7/GAKVat6rOf7MeiEXAtIUdos7DW2JIEfeiEJqXMimQaKxaU0pLKst25NNNHtqloI5gz/56VrJxnnT5HeRCwsH9wYiMNuRIQG8d/rMyzVFQ1lyPjKRyjS/CP9DBd4WRt1i/osRUdFe9G6h2m9ySPM9yxIN3U=;7:GwDWVbnHeMnZEl5cUT6d06GDgBeMJFK0t0ANuc7Xc7b2eP4aZN+bOzOhbxqCptfFHJ072IC1prbQ6vBD6Uk1QbNqVbWgX9ZagcbFzY2gHIbNGiA2SyiciBx6XnIUoZnlYyMASFxTnx50PndXiKg+xQ==
x-ms-office365-filtering-correlation-id: 7a65a882-fdfd-4f18-4240-08d640231e54
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:MWHPR2201MB1325;
x-ms-traffictypediagnostic: MWHPR2201MB1325:
x-microsoft-antispam-prvs: <MWHPR2201MB132540D6ADEFB43DCA55BA61C1CE0@MWHPR2201MB1325.namprd22.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(10201501046)(3002001)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(20161123560045)(20161123564045)(20161123562045)(20161123558120)(2016111802025)(6043046)(201708071742011)(7699051)(76991095);SRVR:MWHPR2201MB1325;BCL:0;PCL:0;RULEID:;SRVR:MWHPR2201MB1325;
x-forefront-prvs: 0843C17679
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(136003)(366004)(39840400004)(346002)(376002)(396003)(199004)(189003)(52254002)(66066001)(42882007)(54906003)(256004)(58126008)(53936002)(93886005)(316002)(446003)(14454004)(6246003)(11346002)(14444005)(6306002)(9686003)(2900100001)(6512007)(186003)(6486002)(476003)(6436002)(305945005)(6346003)(7736002)(26005)(4326008)(44832011)(2906002)(71200400001)(71190400001)(5250100002)(76176011)(8676002)(25786009)(102836004)(6916009)(229853002)(4001150100001)(6116002)(508600001)(3846002)(386003)(486006)(33896004)(6506007)(1076002)(33716001)(99286004)(5660300001)(81156014)(68736007)(52116002)(966005)(8936002)(106356001)(81166006)(97736004)(105586002)(7416002)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1325;H:MWHSPR00MB117.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-microsoft-antispam-message-info: yrmdLIYXw8fwji91kNi00DoE/ToNlDTRAU1dGF7Vgjvh8mXJ3Cjr+w9mC/zaoFTMnEu8AbVwFmE/C1Xq1gB09qk9ykJVWcFPDmeqpoHwB6vXELqHgh/+kYoBHEAAy2WgVvDGb0m5QT39jwNcTD9DzYOwIqhMOw4vQ79eDmaG6TfbhLOXJQkAq2lFajTXC6M46tqksQ4UzTSvyD/7Yh/GwZxcNJeAHcQFzs8RvIjog1f9z/O93hLVFaoJ+CnbTSKWjlqMN4Cqg8xex30KdWlUTWpI9iurUNdznwxcGlAf7Ro5x9PvZ0f5Paq/dLrBvnIKOF6ZBC98++UUurjzrLMf9uVDaWB/r00sl7sojs/Tyhs=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CF3B98CF3394B54E933F2B98E3776DB7@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7a65a882-fdfd-4f18-4240-08d640231e54
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Nov 2018 17:54:50.0518
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1325
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On Thu, Nov 01, 2018 at 12:17:31AM +0000, Trond Myklebust wrote:
> On Wed, 2018-10-31 at 23:32 +0000, Paul Burton wrote:
> > In this particular case I have no idea why
> > net/sunrpc/auth_gss/gss_krb5_seal.c is using cmpxchg64() at all. It's
> > essentially reinventing atomic64_fetch_inc() which is already
> > provided
> > everywhere via CONFIG_GENERIC_ATOMIC64 & the spinlock approach. At
> > least
> > for atomic64_* functions the assumption that all access will be
> > performed using those same functions seems somewhat reasonable.
> >=20
> > So how does the below look? Trond?
>=20
> My one question (and the reason why I went with cmpxchg() in the first
> place) would be about the overflow behaviour for atomic_fetch_inc() and
> friends. I believe those functions should be OK on x86, so that when we
> overflow the counter, it behaves like an unsigned value and wraps back
> around.  Is that the case for all architectures?
>=20
> i.e. are atomic_t/atomic64_t always guaranteed to behave like u32/u64
> on increment?
>=20
> I could not find any documentation that explicitly stated that they
> should.

Based on other replies it seems like it's at least implicitly assumed by
other code, even if not explicitly stated.

From a MIPS perspective where atomics are implemented using load-linked
& store-conditional instructions the actual addition will be performed
using the same addu instruction that a plain integer addition would
generate (regardless of signedness), so there'll be absolutely no
difference in arithmetic between your gss_seq_send64_fetch_and_inc()
function and atomic64_fetch_inc(). I'd expect the same to be true for
other architectures with load-linked & store-conditional style atomics.

In any case, for the benefit of anyone interested who I didn't copy on
the patch submission, here it is:

    https://lore.kernel.org/lkml/20181101175109.8621-1-paul.burton@mips.com=
/

Thanks,
    Paul
