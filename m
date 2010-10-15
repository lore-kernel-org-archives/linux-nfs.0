Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755198Ab0JONmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 09:42:16 -0400
Date: Fri, 15 Oct 2010 09:41:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
Message-ID: <20101015094155.0f498e86@tlielax.poochiereds.net>
In-Reply-To: <4CB8531B.60902@RedHat.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
	<1286903046.24878.13.camel@heimdal.trondhjem.org>
	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
	<20101012151826.76b75f52@corrin.poochiereds.net>
	<1286912649.1956.19.camel@heimdal.trondhjem.org>
	<4CB5EF15.5030003@RedHat.com>
	<20101013141317.66f23906@corrin.poochiereds.net>
	<4CB5FE65.3090409@RedHat.com>
	<20101013145601.468acc2a@corrin.poochiereds.net>
	<4CB6090F.60301@RedHat.com>
	<E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com>
	<4CB63E81.9010100@RedHat.com>
	<1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com>
	<4CB74B90.1050403@RedHat.com>
	<0F7E614A-3450-48DE-BE44-E0D7CC170B66@oracle.com>
	<4CB77502.605@RedHat.com>
	<37D6F414-BDC5-475F-BCC6-27C891D327C0@oracle.com>
	<4CB8531B.60902@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 15 Oct 2010 09:11:55 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> > 
> >>> To summarize: instead of relying on /etc/mtab, also use an NFS-specific 
> >>> place to record the same information.  umount.nfs can use that 
> >>> instead of /etc/mtab.  And by the way, we don't touch this information
> >>> during a remount... heh.  That guarantees that we preserve existing 
> >>> good behaviors of umount.nfs, continue to update /etc/mtab as documented,
> >>> until maybe it goes away, but eliminate our functional dependence on it.
> >>>
> >> If the info in /etc/mntab is not updated on remounts, then what is 
> >> the issue we are talking about? Just curious, will the info in /proc/mounts
> >> be updated on remounts?
> > 
> > /etc/mtab would still be updated on remounts, and would still have the 
> > bug where "remount" would wipe the options.  But we would no longer depend
> > on that destroyed information to perform the umount reliably.
> The remount would wipe out the *original* options, basically overriding
> them with the updated options... As long as we have a mechanism to
> retry the UMNT if the first call fails, I don't see this a being a 
> problem... 
>  

FWIW, I think the only info we really need to worry about preserving
in mtab is the "user=" and "users" options. Without those, you can have
user mountable filesystems that may become un-unmountable by those
users.

This is true whether umount.nfs stays or not.

-- 
Jeff Layton <jlayton@redhat.com>
