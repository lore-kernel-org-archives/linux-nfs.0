From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] QA Notice: for net-fs/nfs-utils-1.1.3
Date: Mon, 2 Feb 2009 11:18:08 -0500
Message-ID: <AB884612-494D-409A-996E-D83061A7F123@oracle.com>
References: <200902021139.26340.toralf.foerster@gmx.de>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:46083 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbZBBQST convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2009 11:18:19 -0500
In-Reply-To: <200902021139.26340.toralf.foerster@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hallo-

On Feb 2, 2009, at 5:39 AM, Toralf F=F6rster wrote:

> Hello,
>
> I get this during installation under a stable Gentoo system:
>
> * QA Notice: Package has poor programming practices which may compile
> *            fine but exhibit random runtime failures.
> * mount_xdr.c:306: warning: dereferencing type-punned pointer will =20
> break
> strict-aliasing rules
>
> * Please do not file a Gentoo bug and instead report the above QA
> * issues directly to the upstream developers of this software.
> * Homepage: http://nfs.sourceforge.net/

mount_xdr.c is created mechanically by the rpcgen tool.  The problem =20
is most likely in rpcgen and not in nfs-utils.  We have -Wall enabled =20
in nfs-utils makefiles to catch problems in code that actual humans =20
wrote, but it also reports issues in the machine-generated source files=
=2E

We haven't had any firm reports of run-time problems in this area.  Do =
=20
you (or does GenToo) have any reproducers that expose a run-time =20
problem?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com