Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40670 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376Ab0ANWH1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 17:07:27 -0500
Subject: Re: To Automount or to Not Automount?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jon Forrest <jlforrest@berkeley.edu>
Cc: Thomas Haynes <Thomas.Haynes@Sun.COM>, linux-nfs@vger.kernel.org
In-Reply-To: <4B4F8965.8020705@berkeley.edu>
References: <hint4t$gjt$1@ger.gmane.org> <4B4F8575.1010505@sun.com>
	 <4B4F8965.8020705@berkeley.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Jan 2010 17:07:21 -0500
Message-ID: <1263506841.2809.68.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-01-14 at 13:15 -0800, Jon Forrest wrote: 
> One person whom I respect told me that static mounts
> result in more overhead on the server. I didn't
> understand this but I don't claim to be
> an NFS expert.

It depends upon your setup.

As Tom said, cluster bootup times can suffer if everybody is pounding
the server with static mount requests at the same time. However, once
that is done, there is usually very little overhead: if you have no
applications actually using the filesystem, then the client will
disconnect the TCP connection after ~5 minutes idle time (and on NFSv4,
it will stop renewing the NFSv4 leases). Once that is done, there is no
overhead whatsoever on the server.

However, one way in which static mounts can cause the server load to
increase is if you have applications whose behaviour is to follow active
mountpoints. For instance, the 'updatedb' daemon usually won't follow an
inactive automount point, but once the NFS filesystem is actually
mounted, it will traipse through, and index all the files it can find
there. Another application that often causes unnecessary traffic in the
static mount case is 'df'.

So before deciding on automount vs static mount, I'd advise you to do an
audit of your cluster nodes to see what applications are going to be
running and how their behaviour may cause the load to differ.

Cheers
  Trond

