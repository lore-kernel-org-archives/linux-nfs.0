From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] mount problems with Acopia and OpenVZ
Date: Mon, 25 Aug 2008 18:29:03 -0400
Message-ID: <20080825182903.2d86036b@tleilax.poochiereds.net>
References: <57bc13580808251454l168e68f1g43f6ad137eb68b35@mail.gmail.com>
	<1219703180.7665.67.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Greg Bradner <greg.bradner@gmail.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59405 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384AbYHYWcA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2008 18:32:00 -0400
In-Reply-To: <1219703180.7665.67.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 25 Aug 2008 18:26:20 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Mon, 2008-08-25 at 14:54 -0700, Greg Bradner wrote:
> > I have a problem with mount options under an OpenVZ container through
> > an Acopia.  I don't have the same problem on the master where the
> > containers live.
> > 
> > I try to mount the file system at 32k wsize/rsize.  It only mounts a 8k.
> > 
> > >From fstab:
> > acopia01:/ac  /ac  nfs
> > rw,vers=3,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=2
> > 0 0
> > 
> > After mount:
> > acopia01:/ac on /ac type nfs
> > (rw,vers=3,rsize=8192,wsize=8192,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys)
> > 
> > 
> > I have looked at an strace of mount and don't see anything.  I have
> > looked a ethereal dump and don't see anything.
> > 
> > What am I'm missing?  What can I try?
> > 
> > Thanks for any help.
> > 
> > 
> > # cat /etc/issue
> > CentOS release 5.1 (Final)
> > 
> > # uname -ar
> > Linux  2.6.18-53.1.19.el5.028stab053.14 #1 SMP Thu May 8 16:29:13 MSD
> > 2008 x86_64 x86_64 x86_64 GNU/Linux
> 
> Known regression with kernels starting with 2.6.19, and fixed in 2.6.23
> (the RHEL-5/CentOS-5 kernel was based on the 2.6.19 code).
> 

RHEL5 is based on 2.6.18 actually, it may have been that this issue was pulled in before the 5.0 release though...

> Basically the problem is that if you have the same NFS partition mounted
> somewhere else, then the NFS client will reuse those mount options.
> I can't remember for certain if the fix has been backported to
> RHEL-5.2/CentOS-5.2, but it is worth trying.
> 

To my knowledge, this is fixed in 5.2.
-- 
Jeff Layton <jlayton@redhat.com>
