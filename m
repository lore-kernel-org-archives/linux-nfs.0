Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757799Ab2EJJO7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 05:14:59 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120509002420.GL5091@dastard>
References: <20120509002420.GL5091@dastard> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <16281.1336508382@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: dhowells@redhat.com, adilger@dilger.ca, bfields@fieldses.org,
        smfrench@gmail.com, ben@decadent.org.uk, Trond.Myklebust@netapp.com,
        roland@hack.frob.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Date: Thu, 10 May 2012 10:14:11 +0100
Message-ID: <13791.1336641251@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave Chinner <david@fromorbit.com> wrote:

> > Also, do Dave Chinner's ideas for indicating five I/O parameters want to be
> > 32-bit numbers?  Larger?  Smaller?  Can they be log2?
> 
> Definitely 32 bit, IMO, as it's not uncommon to see optimal IO sizes
> in the tens of megabytes on large, high bandwidth storage systems.
> As for being log2 - that's just making it more complex to use and
> making code ugly - we'd have to convert to log2 in kernel, then
> convert back in every single application....

ilog2() in the kernel uses the CPU's bit-scan instruction if it has one and
converting back is just a bitshift operator.

But let's go with 32-bit fields for the moment.  I presume we aren't worried
about a driver that wants to do a 4GB transfer...

David
