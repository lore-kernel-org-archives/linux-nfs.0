From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 17:56:19 -0500
Message-ID: <20090121225619.GI4295@fieldses.org>
References: <4970B451.4080201@RedHat.com> <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> <497757D1.7090908@RedHat.com> <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com> <49777988.6010401@RedHat.com> <A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com> <4977A385.8000406@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59923 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbZAUW4U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 17:56:20 -0500
In-Reply-To: <4977A385.8000406-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2009 at 09:36:53AM +1100, Greg Banks wrote:
> Chuck Lever wrote:
> >
> >
> > I think we need to visit this issue on a case-by-case basis.   
> > Sometimes dprintk is appropriate.  Sometimes printk(KERN_ERR).   
> > Sometimes a performance metric.
> Well said.
> 
> > Trond has always maintained that dprintk() is best for developers, but  
> > probably inappropriate for field debugging,
> It's not a perfect tool but it beats nothing at all.
> >  and I think that may also  
> > apply to trace points.  
> It depends on whether distros can be convinced to enable it by default,
> and install by default any necessary userspace infrastructure.   The
> most important thing for field debugging is Just Knowing that you have
> all the bits necessary to perform useful debugging without having to
> find some RPM that matches the kernel that the machine is actually
> running now, and not the one that was present when the machine was
> installed.

On the mount case specifically: How far are we from the idea of a mount
program that can identify most problems itself?  I know its error
reporting has gotten better....

I suppose the main feedback mount gets right now is an error code from
the mount system call, and that may be too narrow an interface to cover
most problems.  Is there some way we can give mount a real interface it
can use to find out this stuff instead of just dumping more strings into
the logs?

My main obstacle to judging a solution is that I don't have in mind a
good list of (say) the top 10 problems that can cause the first mount to
fail.  Hm:

	- dns lookup of the server fails
	- server isn't reachable
	- server isn't running nfs
	- requested path isn't known to server or isn't exported
	- export is there, but requires more security
	- user doesn't have gss credentials
	- file permissions on the export are wrong
	...

--b.
