Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:16535 "EHLO
        mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbeFEHEx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2018 03:04:53 -0400
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
        by mailout1.samsung.com (KnoxPortal) with ESMTP id 20180605070452epoutp01a4e173147d9582cd4e074e4263508679~1MbKt9V_e2361623616epoutp01R
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 07:04:52 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH] Smack: Fix memory leak in smack_inode_getsecctx
Reply-To: chandan.vn@samsung.com
From: CHANDAN VN <chandan.vn@samsung.com>
To: Tejun Heo <tj@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>
CC: "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <20180604212704.GC1351649@devbig577.frc2.facebook.com>
Message-ID: <20180605070449epcms5p317013469ed52cc50878011c428bd12aa@epcms5p3>
Date: Tue, 05 Jun 2018 12:34:49 +0530
Content-Type: text/plain; charset="utf-8"
References: <20180604212704.GC1351649@devbig577.frc2.facebook.com>
        <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
        <20180531153943.GR1351649@devbig577.frc2.facebook.com>
        <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
        <20180531161107.GV1351649@devbig577.frc2.facebook.com>
        <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
        <20180601162913epcms5p7737f5b4376d8865af1eae119aa866550@epcms5p7>
        <5b0b157a-0e8c-d8f5-901e-836d545a8e4c@schaufler-ca.com>
        <fa278910-5c99-11dc-c9cb-b88a97592e53@schaufler-ca.com>
        <b6cc4bd5-8d79-bbc2-373f-ea0bf0806884@schaufler-ca.com>
        <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p3>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=C2=A0=0D=0A=0D=0A>On=C2=A0Mon,=C2=A0Jun=C2=A004,=C2=A02018=C2=A0at=C2=A002=
:01:34PM=C2=A0-0700,=C2=A0Casey=C2=A0Schaufler=C2=A0wrote:=0D=0A>>=C2=A0On=
=C2=A06/1/2018=C2=A010:45=C2=A0AM,=C2=A0Casey=C2=A0Schaufler=C2=A0wrote:=0D=
=0A>>=C2=A0>=C2=A0Fix=C2=A0memory=C2=A0leak=C2=A0in=C2=A0smack_inode_getsec=
ctx=0D=0A>>=C2=A0>=0D=0A>>=C2=A0>=C2=A0The=C2=A0implementation=C2=A0of=C2=
=A0smack_inode_getsecctx()=C2=A0made=0D=0A>>=C2=A0>=C2=A0incorrect=C2=A0ass=
umptions=C2=A0about=C2=A0how=C2=A0Smack=C2=A0presents=C2=A0a=C2=A0security=
=0D=0A>>=C2=A0>=C2=A0context.=C2=A0Smack=C2=A0does=C2=A0not=C2=A0need=C2=A0=
to=C2=A0allocate=C2=A0memory=C2=A0to=C2=A0support=0D=0A>>=C2=A0>=C2=A0secur=
ity=C2=A0contexts,=C2=A0so=C2=A0=22releasing=22=C2=A0a=C2=A0Smack=C2=A0cont=
ext=C2=A0is=C2=A0a=C2=A0no-op.=0D=0A>>=C2=A0>=C2=A0The=C2=A0code=C2=A0made=
=C2=A0an=C2=A0unnecessary=C2=A0copy=C2=A0and=C2=A0returned=C2=A0that=C2=A0a=
s=C2=A0a=0D=0A>>=C2=A0>=C2=A0context,=C2=A0which=C2=A0was=C2=A0never=C2=A0f=
reed.=C2=A0The=C2=A0revised=C2=A0implementation=0D=0A>>=C2=A0>=C2=A0returns=
=C2=A0the=C2=A0context=C2=A0correctly.=0D=0A>>=C2=A0>=0D=0A>>=C2=A0>=C2=A0S=
igned-off-by:=C2=A0Casey=C2=A0Schaufler=C2=A0<casey=40schaufler-ca.com>=0D=
=0A>>=C2=A0=0D=0A>>=C2=A0Tejun,=C2=A0does=C2=A0this=C2=A0pass=C2=A0your=C2=
=A0tests?=0D=0A=C2=A0=0D=0A>Oh,=C2=A0I'm=C2=A0not=C2=A0the=C2=A0one=C2=A0wh=
o=C2=A0reported.=C2=A0=C2=A0Chandan?=0D=0ALooks=20good=20to=20me.=20Leak=20=
not=20found.
