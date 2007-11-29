From: Eric Paris <eparis@redhat.com>
Subject: Re: 2.6.24-rc3 unable to mount something which should use nohide
Date: Thu, 29 Nov 2007 13:03:13 -0500
Message-ID: <1196359393.2912.61.camel@localhost.localdomain>
References: <1196354699.2912.57.camel@localhost.localdomain>
	 <1196358095.7808.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763553AbXK2SDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2007 13:03:25 -0500
In-Reply-To: <1196358095.7808.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2007-11-29 at 12:41 -0500, Trond Myklebust wrote:
> On Thu, 2007-11-29 at 11:44 -0500, Eric Paris wrote:
> > 
> > [root@dhcp231-145 ~]# mount paris:/export/storage/kernel /storage/kernel
> > mount.nfs: Stale NFS file handle
> > 
> > Same thing.  Nothing in dmesg or /var/log/messages.  I know this worked
> > not long ago....
> 
> Yep. I think the following patch ought to fix it.
> 
> Cheers
>   Trond

Worked like a charm, thanks!

-Eric

