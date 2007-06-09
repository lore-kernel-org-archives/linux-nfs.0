From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 4/5] gfs2: stop giving out non-cluster-coherent leases
Date: Sat, 9 Jun 2007 09:35:52 -0700
Message-ID: <OF0E226FEB.28B3A3C4-ON882572F5.005A6853-882572F5.005B16B6@us.ibm.com>
References: <1181398687.25918.278.camel@quoit>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1181398687.25918.278.camel@quoit>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is the return code that setlease() currently returns when the lease 
can not be obtained. Although ENOTSUPP would be more accurately describing 
the error it will be a new return code from setlease() that is currently 
not expected by callers to setlease(), but either return code should work.
Marc. 

Steven Whitehouse <swhiteho@redhat.com> wrote on 06/09/2007 07:18:07 AM:

> Hi,
> 
> On Fri, 2007-06-08 at 18:14 -0400, J. Bruce Fields wrote:
> > From: Marc Eshel <eshel@almaden.ibm.com>
> > 
> > Since gfs2 can't prevent conflicting opens or leases on other nodes, 
we
> > probably shouldn't allow it to give out leases at all.
> > 
> > Put the newly defined lease operation into use in gfs2 by turning off
> > lease, unless we're using the "nolock' locking module (in which case 
all
> > locking is local anyway).
> > 
> > Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> 
> In general it looks fine, but EAGAIN seems like an odd error to return
> when we really mean that this function isn't supported in cluster mode.
> Is that really the correct value for that?
> 
> Steve.
> 
> 

