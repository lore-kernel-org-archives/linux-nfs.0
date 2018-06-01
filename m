Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:31855 "EHLO
        mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbeFAI4P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 04:56:15 -0400
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
        by mailout2.samsung.com (KnoxPortal) with ESMTP id 20180601085613epoutp020cf2c86e452939f17e357b9af85d4cc6~z-XP-Ew3C2812928129epoutp02u
        for <linux-nfs@vger.kernel.org>; Fri,  1 Jun 2018 08:56:13 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH 1/1] Fix memory leak in kernfs_security_xattr_set
 and kernfs_security_xattr_set
Reply-To: chandan.vn@samsung.com
From: CHANDAN VN <chandan.vn@samsung.com>
To: Tejun Heo <tj@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>
CC: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>,
        "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>
In-Reply-To: <1ced6bce-92cc-7e0c-fab4-0aaa3d03b82f@schaufler-ca.com>
Message-ID: <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
Date: Fri, 01 Jun 2018 14:26:09 +0530
Content-Type: text/plain; charset="utf-8"
References: <1ced6bce-92cc-7e0c-fab4-0aaa3d03b82f@schaufler-ca.com>
        <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
        <20180531153943.GR1351649@devbig577.frc2.facebook.com>
        <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
        <20180531161107.GV1351649@devbig577.frc2.facebook.com>
        <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p5>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi
=C2=A0=0D=0A=0D=0A>On=C2=A05/31/2018=C2=A09:11=C2=A0AM,=C2=A0Tejun=C2=A0Heo=
=C2=A0wrote:=0D=0A>=C2=A0On=C2=A0Thu,=C2=A0May=C2=A031,=C2=A02018=C2=A0at=
=C2=A009:04:25AM=C2=A0-0700,=C2=A0Casey=C2=A0Schaufler=C2=A0wrote:=0D=0A>>>=
=C2=A0On=C2=A05/31/2018=C2=A08:39=C2=A0AM,=C2=A0Tejun=C2=A0Heo=C2=A0wrote:=
=0D=0A>>>>=C2=A0(cc'ing=C2=A0more=C2=A0security=C2=A0folks=C2=A0and=C2=A0co=
pying=C2=A0whole=C2=A0body)=0D=0A>>>>=0D=0A>>>>=C2=A0So,=C2=A0I'm=C2=A0sure=
=C2=A0the=C2=A0patch=C2=A0fixes=C2=A0the=C2=A0memory=C2=A0leak=C2=A0but=C2=
=A0API=C2=A0wise=C2=A0it=C2=A0looks=0D=0A>>>>=C2=A0super=C2=A0confusing.=C2=
=A0=C2=A0Can=C2=A0security=C2=A0folks=C2=A0chime=C2=A0in=C2=A0here?=C2=A0=
=C2=A0Is=C2=A0this=C2=A0the=C2=A0right=0D=0A>>>>=C2=A0fix?=0D=0A>>>>=C2=A0s=
ecurity_inode_getsecctx()=C2=A0provides=C2=A0a=C2=A0security=C2=A0context.=
=C2=A0Technically,=0D=0A>>>>=C2=A0this=C2=A0is=C2=A0a=C2=A0data=C2=A0blob,=
=C2=A0although=C2=A0both=C2=A0provider=C2=A0provide=C2=A0a=C2=A0null=C2=A0t=
erminated=0D=0A>>>>=C2=A0string.=C2=A0security_inode_getsecurity(),=C2=A0on=
=C2=A0the=C2=A0other=C2=A0hand,=C2=A0provides=C2=A0a=0D=0A>>>>=C2=A0string=
=C2=A0to=C2=A0match=C2=A0an=C2=A0attribute=C2=A0name.=C2=A0The=C2=A0former=
=C2=A0releases=C2=A0the=C2=A0security=0D=0A>>>>=C2=A0context=C2=A0with=C2=
=A0security_release_secctx(),=C2=A0where=C2=A0the=C2=A0later=C2=A0releases=
=C2=A0the=0D=0A>>>>=C2=A0string=C2=A0with=C2=A0kfree().=0D=0A>>>>=0D=0A>>>>=
=C2=A0When=C2=A0the=C2=A0Smack=C2=A0hook=C2=A0smack_inode_getsecctx()=C2=A0=
was=C2=A0added=C2=A0in=C2=A02009=0D=0A>>>>=C2=A0for=C2=A0use=C2=A0by=C2=A0l=
abeled=C2=A0NFS=C2=A0the=C2=A0alloc=C2=A0value=C2=A0passed=C2=A0to=0D=0A>>>=
=C2=A0smack_inode_getsecurity()=C2=A0was=C2=A0set=C2=A0incorrectly.=C2=A0Th=
is=C2=A0wasn't=C2=A0a=0D=0A>>>=C2=A0major=C2=A0issue,=C2=A0since=C2=A0label=
ed=C2=A0NFS=C2=A0is=C2=A0a=C2=A0fringe=C2=A0case.=C2=A0When=C2=A0kernfs=0D=
=0A>>>=C2=A0started=C2=A0using=C2=A0the=C2=A0hook,=C2=A0it=C2=A0became=C2=
=A0the=C2=A0issue=C2=A0you=C2=A0discovered.=0D=0A>>>=0D=0A>>>=C2=A0The=C2=
=A0reason=C2=A0that=C2=A0we=C2=A0have=C2=A0all=C2=A0this=C2=A0confusion=C2=
=A0is=C2=A0that=C2=A0SELinux=0D=0A>>>=C2=A0generates=C2=A0security=C2=A0con=
texts=C2=A0as=C2=A0needed,=C2=A0while=C2=A0Smack=C2=A0keeps=C2=A0them=0D=0A=
>>>=C2=A0around=C2=A0all=C2=A0the=C2=A0time.=C2=A0Releasing=C2=A0an=C2=A0SE=
Linux=C2=A0context=C2=A0frees=C2=A0memory,=0D=0A>>>=C2=A0while=C2=A0releasi=
ng=C2=A0a=C2=A0Smack=C2=A0context=C2=A0is=C2=A0a=C2=A0null=C2=A0operation.=
=0D=0A>>=C2=A0Any=C2=A0chance=C2=A0this=C2=A0detail=C2=A0can=C2=A0be=C2=A0h=
idden=C2=A0behind=C2=A0security=C2=A0api?=C2=A0=C2=A0This=C2=A0looks=0D=0A>=
>=C2=A0pretty=C2=A0error-prone,=C2=A0no?=0D=0A=C2=A0=0D=0A>>It=C2=A0*is*=C2=
=A0hidden=C2=A0behind=C2=A0the=C2=A0security=C2=A0API.=C2=A0The=C2=A0proble=
m=C2=A0is=C2=A0strictly=0D=0A>>within=C2=A0the=C2=A0Smack=C2=A0code,=C2=A0w=
here=C2=A0the=C2=A0implementer=C2=A0of=C2=A0smack_inode_getsecctx()=0D=0A>>=
made=C2=A0an=C2=A0error.=0D=0A=0D=0AI=20agree=20that=20the=20fix=20can=20be=
=20done=20simply=20by=20using=20=22false=22=20for=20=0D=0Asmack_inode_getse=
curity(),=20but=20what=20happens=20with=20kernfs_node_setsecdata()=0D=0Aand=
=20smack_inode_notifysecctx().=20kernfs_node_setsecdata()=20is=20probably=
=20ignorable=0D=0Abut=20smack_inode_notifysecctx()=20is=20sending=20the=20=
=22ctx=22=20to=20smack_inode_setsecurity()=0D=0Aand=20since=20=22ctx=22=20w=
ould=20be=20NULL=20because=20we=20used=20=22false=22,=20smack_inode_setsecu=
rity()=0D=0Abecomes=20dummy.=0D=0A=0D=0A
