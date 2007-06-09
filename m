From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH 4/5] gfs2: stop giving out non-cluster-coherent leases
Date: Sat, 09 Jun 2007 15:18:07 +0100
Message-ID: <1181398687.25918.278.camel@quoit>
References: <20070607170557.GA14463@fieldses.org>
	 <11813408953536-git-send-email->  <11813408952518-git-send-email->
	 <11813408951909-git-send-email->  <11813408954053-git-send-email->
	 <11813408951694-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Robert Rappaport <robert.rappaport@gmail.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11813408951694-git-send-email->
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

On Fri, 2007-06-08 at 18:14 -0400, J. Bruce Fields wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Since gfs2 can't prevent conflicting opens or leases on other nodes, we
> probably shouldn't allow it to give out leases at all.
> 
> Put the newly defined lease operation into use in gfs2 by turning off
> lease, unless we're using the "nolock' locking module (in which case all
> locking is local anyway).
> 
> Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>

In general it looks fine, but EAGAIN seems like an odd error to return
when we really mean that this function isn't supported in cluster mode.
Is that really the correct value for that?

Steve.


