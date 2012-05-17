Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759475Ab2EQKaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 06:30:06 -0400
Date: Thu, 17 May 2012 12:29:58 +0200
From: Karel Zak <kzak@redhat.com>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Cannot unmount nfs4 sec=krb5 mount if network is down
Message-ID: <20120517102958.GA9844@x2.net.home>
References: <loom.20120510T222025-23@post.gmane.org>
 <loom.20120516T233017-710@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <loom.20120516T233017-710@post.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 16, 2012 at 09:34:27PM +0000, Orion Poplawski wrote:
> Orion Poplawski <orion@...> writes:
> > 
> > See https://bugzilla.redhat.com/show_bug.cgi?id=820707
> >
> > If the network is disconnected it is impossible to unmount, even if no
> > processes are accessing the mount.  umount -f and umount -l both hang on
> > readlink("/home/orion"). 
> 
> umount needs to canonicalize the path so it does a readlink on the path given to
> it. 

It seems that the canonicalization is unnecessary (already fixed in libmount
upstream code). https://bugzilla.redhat.com/show_bug.cgi?id=820707

> This appears to wait forever.  This pretty much makes it impossible to use krb5
> nfs4 with laptops where the network can disappear.

Is it possible to interrupt this "wait" by signal? ... then we can add alarm()
to critical sections in programs like umount or lsof. 

Now for example lsof resolves this problem by fork() and timeout in
parent.. that's pretty nasty solution :-(

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
