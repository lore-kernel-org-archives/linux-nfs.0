Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24370 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745Ab1ARTpd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 14:45:33 -0500
Subject: Re: 4.1 no-pnfs mount option?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Daniel Muntz <Daniel.Muntz@emc.com>, rees@umich.edu,
        androsadamson@gmail.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <559269113.92.1295379350636.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <559269113.92.1295379350636.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 18 Jan 2011 14:45:16 -0500
Message-ID: <1295379916.3746.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-18 at 14:35 -0500, Matt W. Benjamin wrote: 
> Hi,
> 
> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
> > "Why would an administrator never want to do this?" is not a helpful
> > question.
> > 
> > A more useful question is "what reason would you possibly have for
> > overriding the server's request that you do pNFS when your client has
> > pNFS support?" What makes pNFS so special that we must allow
> > administrators to do this on a per-mount basis?
> 
> Well, I phrased my question the other way because I suspect such cases will be found, but I may not have found all of them.  
> 
> Some thoughts on why I might wish to take a hand in the decision:
> 
> 1. the client doing pnfs might behave badly due to a misconfiguration or outage, yet behave acceptably using ordinary nfsv4?

The client should be automatically falling back to non-pNFS mode when
this sort of thing happens (and, yes, we are already testing that kind
of scenario).
In what cases do we expect the administrator to be able to detect that
the client is misbehaving without the client itself being able to detect
it and thus take action?

> 2. restricting the client to ordinary nfsv4 might be desirable for non-developer troubleshooting or other configuration work?

That is the one-off testing case. You already have the option of
removing and disabling the pNFS module to do your testing.

> I apologize if neither is compelling.
> 
> > 
> > Throwing more and more knobs into the kernel is easy. The difficult
> > bit
> > is to figure out which are useful knobs, and that is why I want real
> > use
> > cases... 
> > 
> > Trond
> > 
> 
> Matt
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

