Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:40369 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab0ENJ4X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 May 2010 05:56:23 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4E9uLBr025933
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Fri, 14 May 2010 11:56:21 +0200
Received: from mail2.itwm.fhg.de ([131.246.191.79]:56106)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail2.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1OCrcz-0007NT-5z
	for linux-nfs@vger.kernel.org; Fri, 14 May 2010 11:56:21 +0200
Message-ID: <4BED1E44.4020708@itwm.fraunhofer.de>
Date: Fri, 14 May 2010 11:56:20 +0200
From: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
To: linux-nfs@vger.kernel.org
Subject: Re: permission denied with >= ~2.6.25
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de>
In-Reply-To: <4BE93940.5070804@itwm.fraunhofer.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


> Hello,
>
> I tested 2.6.34-rc7 now and it has the problem too.
> Then I checked 2.6.24.7 which has the problem,
> but 2.6.23.1 looks fine.

Hello,

I searched a bit more in the git tree, when the "Permission denied"
problems does occur first(for me).
I'm no expert in git. I used git bisect visualize to find a commit
which should build and then tested if it works/works not.

The first commit which introduced the "Permission denied" problem,
was:

1-run:
>commit 77a55a1fe8f26f7d022986a599b68002e21d968a
>NFS: Eliminate nfs_renew_times()
>svn: Can't change perms of file
>'Kernel-pxe3-1.h2cuuZBQlF/arch/h8300/platform/h8
>s/.svn/log.1': Permission denied

When I go back one commit, the "Permission denied" disappears, but
now I get an "Input/output error".

5-run:
>commit 92f6c178250170222f6d80c8ae725400765aa7a4
>"Don't call nfs_renew_times() in nfs_dentry_iput()"
>svn: Can't read file
>'Kernel-pxe3-5.HQikkhUNHk/drivers/usb/storage/.svn/log': Input/output error

Thus it looks that the problem is now "I/O Error" instead of
permission denied. And that I have to search when the I/O Error
disappears?

Maybe someone has an idea what went wrong here?

All I can say that I have reproduced a similar svn problem with
2.6.33 as server/client and with 2.6.34-rc7 as client.
And that on my system does not go away with sync, tcp, udp, noac,
nosharecache.

But I cannot say that the problem in the 2.6.33 (server/client)
combination is the same.
Because with this the svn error is "No such file or directory".
The problem never existed on my 2.6.16 kernel from SLES10, but now
every kernel >= 2.6.24 seems to be affected.


regards,

Martin
