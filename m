From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] NFS: nfsaclsvc_encode_getaclres() - Fix potential NULL deref and tiny optimization.
Date: Thu, 2 Nov 2006 16:07:46 +0100
Message-ID: <200611021607.46373.agruen@suse.de>
References: <200610272316.47089.jesper.juhl@gmail.com> <200610311726.00411.agruen@suse.de> <Pine.LNX.4.64N.0610311232190.30578@attu4.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751302AbWKBPHF@vger.kernel.org>
To: David Rientjes <rientjes@cs.washington.edu>
In-Reply-To: <Pine.LNX.4.64N.0610311232190.30578@attu4.cs.washington.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tuesday 31 October 2006 21:39, David Rientjes wrote:
> On Tue, 31 Oct 2006, Andreas Gruenbacher wrote:
> > > > w should be an unsigned int.
> > >
> > > Makes sense.
> >
> > No, this breaks the while loop further below: with an unsigned int, the
> > loop counter underflows and wraps.
>
> This is not a problem with w being an unsigned int, it's a problem with
> the while loop.  nfsacl_size() returns unsigned int as it should and the
> while loop can be written to respect that since integer division in C
> truncates:
>
> 	for (n = w / PAGE_SIZE; n > 0; n--)
> 		if (!rqstp->rq_respages[rqstp->rq_resused++];

Assuming that PAGE_SIZE = 4096 and w = 100, the original loop iterates once, 
while your proposed version iterates zero times -- the current code does the 
right thing. So the proposed change is still bad, sorry.

Andreas
