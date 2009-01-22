From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 10:30:57 -0500
Message-ID: <1232638257.7589.16.camel@heimdal.trondhjem.org>
References: <4970B451.4080201@RedHat.com>
	 <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	 <497757D1.7090908@RedHat.com>
	 <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	 <1232566140.7692.64.camel@heimdal.trondhjem.org>
	 <49777E4C.2020501@RedHat.com>
	 <1232569427.7692.70.camel@heimdal.trondhjem.org>
	 <49786F9F.7030400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:49335 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228AbZAVPbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2009 10:31:10 -0500
In-Reply-To: <49786F9F.7030400-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-01-22 at 08:07 -0500, Steve Dickson wrote:
> > I think it might be a good idea to flesh out a bit what you mean by
> > "debugging" here. Since you mentioned it in conjunction with the two
> > words "administrators" and "scripts", I assume that you are not talking
> > about kernel code debugging?
> I'm talking debugging for both admins and kernel people...
> 
> With trace points and systemtap you can do both.

Yes, but we still need to figure out details of what each type of user
is expecting/wants.

I suspect that when we get down to cases, we will find that a lot of the
tracepoints that administrators find useful will want to be put in the
VFS rather than in the filesystems themselves. If you have tracepoints
in sys_stat() and sys_fstat(), why would you also need a tracepoint in
nfs_getattr()? AFAICS, that would just make scripting ugly...

Cheers
  Trond

