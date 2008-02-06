From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Wed, 6 Feb 2008 14:16:36 -0800
Message-ID: <20080206141636.1001b1c5.akpm@linux-foundation.org>
References: <476CEC5E.9070002@abinetworks.biz>
	<838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc>
	<476E47F5.4090807@abinetworks.biz>
	<20071225140431.9264970a.akpm@linux-foundation.org>
	<199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com>
	<4791EE99.3030802@abinetworks.biz>
	<5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com>
	<479C744A.6020207@abinetworks.biz>
	<12964A18-350B-443F-B15A-D78B3723C89A@oracle.com>
	<479F2463.2040704@abinetworks.biz>
	<4AAA3DAF-898C-4ED5-BD07-4FD2B5CEEF16@oracle.com>
	<Pine.LNX.4.64.0801291851110.4820@maggie.lkpg.cendio.se>
	<7EE4B02B-3359-41C0-BFED-0947DF9F5F5A@oracle.com>
	<479F8377.6090704@abinetworks.biz>
	<1201638661.7969.7.camel@heimdal.trondhjem.org>
	<F7BFE847-A3C3-44E5-A238-5C69ED3EE1C4@oracle.com>
	<47A0704D.7080808@abinetworks.biz>
	<AB6DF303-5C5B-453C-9992-DAF826FF02CE@oracle.com>
	<47A9FB91.2040304@abinetworks.biz>
	<C18DF7CB-3641-4A23-8BEB-63A161503DDD@oracle.com>
	<47AA2CB6.9070908@abinetworks.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47922 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754635AbYBFWRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 17:17:41 -0500
In-Reply-To: <47AA2CB6.9070908-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 06 Feb 2008 22:55:02 +0100
Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org> wrote:

> I finally got it. Problem and solution have been found from 6 month but 
> nobody cared...up to now those servers have not been mantained, this 
> problem is not discussed anywhere else than the following link.
> The bug (userspace server side i would say at this point) is well 
> described from the author of an nfs-user-server patch which has not been 
> managed yet. The magic hint to find it on google was 'nfs server 
> utimensat' :-)
> 
> http://marc.info/?l=linux-nfs&m=118724649406144&w=2

This is pretty significant.  We have on several occasions in recent years
tightened up the argument checking on long-standing system calls and it's
always a concern that this will break previously-working applications.

And now it has happened.

If we put buggy code into the kernel then we're largely stuck with it: we
need to be back-compatible with our bugs so we don't break things like
this.

> I have already prepared a working patch for cfsd based upon the one ive 
> listed. The nfs patch is of course waiting for commit since august, 
> 2007. Ill submit it to debian cfsd mantainers, hoping to have more 
> chance than my predecessor.
> It doesnt seem to me that there was any kernel related issue.
> 
> Thanks a lot again, sorry for the lots of noise i have done. I will try 
> to be more appropriate next time.

That wasn't noise - it was quite valuable.  Thanks for all the work you did
on this.


Given that our broken-by-unbreaking code has been out there in several
releases there isn't really any point in rebreaking it to fix this - the
offending applications need to be repaired so they'll work on 2.6.22 and
2.6.23 anyway.

