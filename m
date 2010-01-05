From: Peter Staubach <staubach@redhat.com>
Subject: Re: Proper way to request async from NFS server?
Date: Tue, 05 Jan 2010 10:39:22 -0500
Message-ID: <4B435D2A.7040009@redhat.com>
References: <20100105075610.GA435@esri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Ray Van Dolson <rvandolson-v48TKWNzwFw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754797Ab0AEPj1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 10:39:27 -0500
In-Reply-To: <20100105075610.GA435-v48TKWNzwFw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ray Van Dolson wrote:
> RHEL 5.4 NFSv3 client accessing a Solaris 10 NFS export.
> 
> Solaris 10 does not offer a way to specify whether a given share is
> async or sync as the Linux NFS server does.  As far as I understand it,
> its NFS server will honor whatever the connecting NFS client requests.
> 
> I'm mounting a Solaris NFS share with -o async (or using async in the
> options field in fstab).  Though this completes without complaint, I
> don't see "async" listed in the mount options under /proc/mounts and
> when I do a snoop on the Solaris side, all the write requests are FSYNC
> instead of ASYNC.
> 
> Am I doing something wrong?  What's the correct way to get the Linux
> NFS client to request asynchronous operation?
> 
> This is with nfs-utils 1.0.9 and of course, the RHEL5 kernel
> 2.6.18-164.6.1.el5.
> 

Simply mounting with no specific options should cause the
client to generate WRITE requests with the appropriate setting.
When it can, the client generates UNSTABLE requests followed
by COMMIT operations.  When it is required to, the client
generates FSYNC requests.

If you are only seeing FSYNC requests over the wire, then I
might suggest checking the application to see how it opens
the file.

		ps
