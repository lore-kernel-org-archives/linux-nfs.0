From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH linux-2.6.36-rc7] sunrpc/xprtrdma: clean up workqueue
 usage
Date: Thu, 21 Oct 2010 11:16:21 -0400
Message-ID: <20101021151621.GA8738@fieldses.org>
References: <4CB87807.7050108@kernel.org>
 <20101015171132.GA18869@fieldses.org>
 <4CB89393.6000207@opengridcomputing.com>
 <4CB8A745.5020206@kernel.org>
 <4CBF1331.70107@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Tom Tucker <tom@ogc.us>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36823 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920Ab0JUPQZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 11:16:25 -0400
In-Reply-To: <4CBF1331.70107@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 20, 2010 at 11:05:05AM -0500, Tom Tucker wrote:
>  On 10/15/10 2:11 PM, Tejun Heo wrote:
> >On 10/15/2010 07:46 PM, Tom Tucker wrote:
> >>  On 10/15/10 12:11 PM, J. Bruce Fields wrote:
> >>>Tom, could you take a look?
> >>>
> >>This looks reasonable to me.
> >>
> >>My bet is that it wasn't tested though due to hardware
> >>availability. I'll test it this weekend and let you know how it
> >>goes.
> >Yeap, only compile tested.  Testing would be much appreciated.
> >
> Tejun,
> 
> I've tested this now with iozone etc... works like a charm ;-)

Applied, thanks!

--b.
