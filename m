From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 18:37:14 -0800
Message-ID: <m1r63fzvs5.fsf@frodo.ebiederm.org>
References: <20090106200229.GA17031@us.ibm.com>
	<1231274682.20316.65.camel@heimdal.trondhjem.org>
	<20090106215831.GE18147@us.ibm.com>
	<m1eizg11fy.fsf@frodo.ebiederm.org>
	<1231283734.8041.6.camel@heimdal.trondhjem.org>
	<20090106233238.GD13785@fieldses.org>
	<1231284943.8041.8.camel@heimdal.trondhjem.org>
	<1231287607.11487.0.camel@heimdal.trondhjem.org>
	<20090107002608.GK13785@fieldses.org>
	<1231288706.11487.15.camel@heimdal.trondhjem.org>
	<20090107014422.GA17913@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44824 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197AbZAGCrn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 21:47:43 -0500
In-Reply-To: <20090107014422.GA17913@fieldses.org> (J. Bruce Fields's message
	of "Tue, 6 Jan 2009 20:44:22 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

> If people seem to think they can do live process and container
> migration:
>
> 	http://ols.fedoraproject.org/OLS/Reprints-2008/mirkin-reprint.pdf
>
> then moving the NFS state strikes me as not the greatest of their
> troubles.
>
> I'm not volunteering!

Reasonable.  There are a lot easier cases than NFS, and migration is
not the biggest use case.

A lot of this work we can do incrementally and simply not support
doing everything in a container.  Which is where we are today.

The whole hostname in NFS packets isn't something that makes much sense
to me in the first place, so I can't comment on a good use case for that.

Sorting out the details so we can get NFS working in multiple network namespaces
makes a lot of sense to me.   It allows things like VPNing into work isolating the
VPN process in a network namespace, and still being able to use all of the kernel
networking including NFS like normal sounds fun to me.

There may also be some fun things you can do with testing having both an NFS
server and the client on the same box and not go through the loopback device.

Eric
