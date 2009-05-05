From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Do not display the setting of the "intr" mount
 option
Date: Tue, 05 May 2009 08:22:36 -0400
Message-ID: <1241526156.5174.32.camel@heimdal.trondhjem.org>
References: <20090501163402.25637.67939.stgit@ingres.1015granger.net>
	 <alpine.LFD.2.00.0905021010320.19638@maggie.lkpg.cendio.se>
	 <382F5CF6-4D1A-4B1E-8E17-B6426CFC3A03@oracle.com>
	 <1241455743.5754.10.camel@heimdal.trondhjem.org>
	 <alpine.LFD.2.00.0905050832340.6736@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46623 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684AbZEEMWj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2009 08:22:39 -0400
In-Reply-To: <alpine.LFD.2.00.0905050832340.6736-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-05-05 at 08:36 +0200, Peter =C3=85strand wrote:
> On Mon, 4 May 2009, Trond Myklebust wrote:
>=20
> >> Since 2.6.25, the behavior of the NFS client has been a mix of the
> >> two.  I believe the current behavior is that SIGKILL can terminate=
 an
> >> NFS operation, but all other signals are deferred until pending NF=
S
> >> operations complete.
>=20
> I guess this means that commands cannot be terminated using Ctrl-C, s=
ince=20
> that generates a SIGINT? If so, this is a change for the worse.

The *_killable() behaviour is to exit on all fatal signals. The
definition of a fatal signal is any signals that is not blocked, that
does not have a handler, and that is not listed in the
SIG_KERNEL_IGNORE_MASK or SIG_KERNEL_STOP_MASK (see the definition of
sig_fatal() in include/linux/signal.h) and that won't result in a core
dump (see the definition of complete_signal() in kernel/signal.c).

An unhandled and unblocked SIGINT should therefore result in the sleep
being interrupted.

> >> The mount command continues to accept both options, but neither ha=
ve
> >> any effect on the client's behavior (both options are no-ops).
> >
> > Note that this behaviour is true of local filesystems too, since
> > generic_file_read() has been changed to call lock_page_killable()
> > instead of the uninterruptible lock_page().
>=20
> I see. However, it's much more common with unreachable network server=
s=20
> than unreachable local block devices.

There are plenty of networked block devices these days (iSCSI,
=46CoE, ...).



