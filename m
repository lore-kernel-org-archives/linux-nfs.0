Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:30858 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab2CLV2D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 17:28:03 -0400
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87mx7lms1y.fsf@inspiron.ap.columbia.edu>
Date: Mon, 12 Mar 2012 17:27:37 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <683A9678-14CF-4F27-8CC9-DD569722EE39@oracle.com>
References: <878vj7x6mj.fsf@vostro.rath.org> <87pqchn64e.fsf@inspiron.ap.columbia.edu> <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org> <20120312201505.GC7203@fieldses.org> <87mx7lms1y.fsf@inspiron.ap.columbia.edu>
To: Nikolaus Rath <Nikolaus@rath.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2012, at 5:24 PM, Nikolaus Rath wrote:

> Alright, it seems that this was the problem. With correct clientaddr, I
> haven't been able to produce any freezes for the last 15 minutes
> (usually it happens in ~20 seconds).
> 
> The weird thing is that I cannot reproduce the wrong clientaddr
> autodetection when I mount the NFS volumes from the command line. It
> seems to happen only when the mounting is done by mountall during the
> boot sequence.
> 
> In other words, this fstab entry results in freezes and a clientaddr of 0.0.0.0:
> 
> spitzer:/opt /opt        nfs4    bg 0  0
> 
> While this one, followed by a "mount /opt" on the console as soon as I'm
> able to log in, works just fine (and has a correct cliendaddr):
> 
> spitzer:/opt /opt        nfs4    noauto 0  0

That's almost certainly because networking isn't up during boot.  The "bg" option keeps trying the mount until it succeeds, but the system started the mount process before there was a source address on the system.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




