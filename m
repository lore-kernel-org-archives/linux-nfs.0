From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [PATCH] NFS: nfsaclsvc_encode_getaclres() - Fix potential NULL
 deref and tiny optimization.
Date: Tue, 31 Oct 2006 12:39:22 -0800 (PST)
Message-ID: <Pine.LNX.4.64N.0610311232190.30578@attu4.cs.washington.edu>
References: <200610272316.47089.jesper.juhl@gmail.com>
 <Pine.LNX.4.64N.0610271443500.31179@attu2.cs.washington.edu>
 <200610280001.49272.jesper.juhl@gmail.com> <200610311726.00411.agruen@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1945908AbWJaUjo@vger.kernel.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200610311726.00411.agruen@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 31 Oct 2006, Andreas Gruenbacher wrote:

> > > w should be an unsigned int.
> >
> > Makes sense.
> 
> No, this breaks the while loop further below: with an unsigned int, the loop 
> counter underflows and wraps.
> 

This is not a problem with w being an unsigned int, it's a problem with 
the while loop.  nfsacl_size() returns unsigned int as it should and the 
while loop can be written to respect that since integer division in C 
truncates:

	for (n = w / PAGE_SIZE; n > 0; n--)
		if (!rqstp->rq_respages[rqstp->rq_resused++];
