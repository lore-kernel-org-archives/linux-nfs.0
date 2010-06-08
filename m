From: Neil Brown <neilb@suse.de>
Subject: Re: Problem using exportfs in an active-active nfs cluster
Date: Wed, 9 Jun 2010 07:54:25 +1000
Message-ID: <20100609075425.7ec4ccd9@notabene.brown>
References: <4C0E6ED0.60200@miamammausalinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44941 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755406Ab0FHVyc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 17:54:32 -0400
In-Reply-To: <4C0E6ED0.60200-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 08 Jun 2010 18:24:48 +0200
RaSca <rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org> wrote:

> Hi all,
> I'm trying to use a resource agent named exportfs for my active-active 
> nfs cluster configuration.
> The resource agent works using the exportfs command. I have an instance 
> of nfs-kernel-server for each node and exportfs dynamically remove or 
> append the export to the node (obviously I've got also a shared storage).
> The problem comes when the export is mounted by a client and this client 
> is writing on it: if the node switches, then the migration fails. The 
> sequence is this one:
> 
> - The resource exportfs stops correctly (the Resource Agent launch 
> exportfs -u)
> - The Filesystem resource tries to unmount the exported filesystem, 
> doing an fuser to see if some processes are locking the fs.
> - fuser doesn't return anything, but the filesystem is still locked. 
> This happens because the kernel process nfsd is locking the FS.
> - The migration fails.
> 
> The only way to make thing work again is to restart the 
> nfs-kernel-daemon on the node which the resource reside and then cleanup 
> the resource.
> 
> Now, after many discussions on the Linux-ha Mailing List, I'm here to 
> ask if this problem is about the exportfs command. Why a filesystem 
> remains locked to the nfsd kernel process even if I (or the resource 
> agent) have done an "exportfs -u" command?
> 
> What can else I do to free the exported filesystem? Note that I've tried 
> to mount from the client with "nolock" option and also the exported 
> filesystem is mounted with "noatime".
> 
> Thanks a lot,
> 

Try 
  exportfs -f

NeilBrown
