From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils, umount -l, and unmount requests
Date: Fri, 21 Nov 2008 06:08:29 -0500
Message-ID: <492696AD.8040905@RedHat.com>
References: <E1L2wsc-0004Rs-2I@mendel.bio.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: David Mathog <mathog-7GExONQZ6ZKVc3sceRu5cw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34967 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbYKULKa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2008 06:10:30 -0500
In-Reply-To: <E1L2wsc-0004Rs-2I-Mlb+9xX7RBA8OKIjkCRLjtKIQNXEaThN@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Mathog wrote:
> 
> 	if (mc) {
> 		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
> 			/* We ignore the error from do_nfs_umount23.
> 			 * If the actual umount succeeds (in del_mtab),
> 			 * we don't want to signal an error, as that
> 			 * could cause /sbin/mount to retry!
> 			 */
> 			do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
> 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
> 	} else if (*spec != '/') {
> 		if (!lazy)
> 			ret = do_nfs_umount23(spec, "tcp,v3");
> 	} else
> 		ret = del_mtab(NULL, spec);
> 	return ret;
> 
> Removing the first "!lazy &&" resolved my immediate problem.  What I
> don't understand is why it, and the latter "!lazy", were there in
> the first place. 
To quote from the umount(8) man page:
 
       -l     Lazy unmount. Detach the filesystem from the filesystem  hierar-

              chy now, and cleanup all references to the filesystem as soon as

              it is not busy anymore.  (Requires kernel 2.4.11 or later.)

Which means in an NFS context that no RPC calls (i.e. call to the server)
can be made that could possibility hang 


> The do_nfs_umount23() routine seems to be relatively
> harmless, it either sends the message or it doesn't, but either way it
> doesn't seem to do anything to the mount information on the local node.
> So why is it not run if "-l" (lazy) is set?
Take a closer look... nfs_call_umount() makes a clnt_call() which 
would hang if the server is down, which is the reason its not called. 

I hope this helps....

steved.
