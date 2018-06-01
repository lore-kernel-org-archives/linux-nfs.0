Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:45603 "EHLO
        mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752943AbeFAQ3S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 12:29:18 -0400
Received: from epcas5p2.samsung.com (unknown [182.195.41.40])
        by mailout4.samsung.com (KnoxPortal) with ESMTP id 20180601162916epoutp0490e827346760a50ab45aac5165eb3ab4~0Fi0HiwZ_2121021210epoutp04h
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jun 2018 16:29:16 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH 1/1] Fix memory leak in kernfs_security_xattr_set
 and kernfs_security_xattr_set
Reply-To: chandan.vn@samsung.com
From: CHANDAN VN <chandan.vn@samsung.com>
To: "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>
CC: Tejun Heo <tj@kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>,
        Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <02d9878e-65bf-5de8-9658-cf0f692f358c@schaufler-ca.com>
Message-ID: <20180601162913epcms5p7737f5b4376d8865af1eae119aa866550@epcms5p7>
Date: Fri, 01 Jun 2018 21:59:13 +0530
Content-Type: text/plain; charset="utf-8"
References: <02d9878e-65bf-5de8-9658-cf0f692f358c@schaufler-ca.com>
        <1ced6bce-92cc-7e0c-fab4-0aaa3d03b82f@schaufler-ca.com>
        <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
        <20180531153943.GR1351649@devbig577.frc2.facebook.com>
        <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
        <20180531161107.GV1351649@devbig577.frc2.facebook.com>
        <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
        <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p7>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>=C2=A0I=C2=A0agree=C2=A0that=C2=A0the=C2=A0fix=C2=A0can=C2=A0be=C2=A0done=
=C2=A0simply=C2=A0by=C2=A0using=C2=A0=22false=22=C2=A0for=C2=A0=0D=0A>>=C2=
=A0smack_inode_getsecurity(),=C2=A0but=C2=A0what=C2=A0happens=C2=A0with=C2=
=A0kernfs_node_setsecdata()=0D=0A>>=C2=A0and=C2=A0smack_inode_notifysecctx(=
).=C2=A0kernfs_node_setsecdata()=C2=A0is=C2=A0probably=C2=A0ignorable=0D=0A=
>>=C2=A0but=C2=A0smack_inode_notifysecctx()=C2=A0is=C2=A0sending=C2=A0the=
=C2=A0=22ctx=22=C2=A0to=C2=A0smack_inode_setsecurity()=0D=0A>>=C2=A0and=C2=
=A0since=C2=A0=22ctx=22=C2=A0would=C2=A0be=C2=A0NULL=C2=A0because=C2=A0we=
=C2=A0used=C2=A0=22false=22,=C2=A0smack_inode_setsecurity()=0D=0A>>=C2=A0be=
comes=C2=A0dummy.=0D=0A=C2=A0=0D=0A>Thank=C2=A0you=C2=A0for=C2=A0pointing=
=C2=A0this=C2=A0out.=C2=A0You're=C2=A0right,=C2=A0there's=C2=A0more=0D=0A>a=
t=C2=A0issue=C2=A0here=C2=A0than=C2=A0changing=C2=A0the=C2=A0alloc=C2=A0fla=
g=C2=A0will=C2=A0fix.=C2=A0I=C2=A0think=0D=0A>that=C2=A0calling=C2=A0smack_=
inode_getsecurity()=C2=A0from=C2=A0smack_inode_getsecctx()=0D=0A>is=C2=A0ma=
king=C2=A0the=C2=A0code=C2=A0more=C2=A0complicated=C2=A0than=C2=A0it=C2=A0n=
eeds=C2=A0to=C2=A0be.=C2=A0I=C2=A0will=0D=0A>have=C2=A0a=C2=A0patch=C2=A0sh=
ortly.=0D=0A=0D=0AIf=20you=20think=20the=20patch=20would=20take=20time=20or=
=20is=20complicated,=20I=20suggest=20that=20the=20kfree()=20fix=20should=20=
go=0D=0Ato=20fix=20the=20leaks=20for=20now.=C2=A0=0D=0A=C2=A0=0D=0A=C2=A0=
=0D=0A=C2=A0
