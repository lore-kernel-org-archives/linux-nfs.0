Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48579 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833Ab2JSVLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Oct 2012 17:11:45 -0400
Date: Fri, 19 Oct 2012 17:11:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
Message-ID: <20121019211143.GC2320@fieldses.org>
References: <1348508341-19642-1-git-send-email-bjschuma@netapp.com>
 <20121019193951.GA30593@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092851AD@SACEXCMBX04-PRD.hq.netapp.com>
 <20121019210121.GB2320@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909285321@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909285321@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2012 at 09:05:08PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Friday, October 19, 2012 5:01 PM
> > To: Myklebust, Trond
> > Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org; stable@vger.kernel.org
> > Subject: Re: [PATCH] SUNRPC: Set alloc_slot for backchannel tcp ops
> > 
> > On Fri, Oct 19, 2012 at 08:23:05PM +0000, Myklebust, Trond wrote:
> > >
> > > Et tu Bruce?
> > >
> > > Not yet, because if you check, neither has commit f39c1bfb5a (SUNRPC: Fix
> > a UDP transport regression). I figured it is better to send them both together
> > as a single patch.
> > 
> > I'm confused, I thought I did check.  Looking again...  It's in 3.6:
> > 
> > 	$ git log v3.6..f39c1bfb5a
> > 	$
> 
> Yes. 3.6 still has the original patch+problem.
> 
> > and cc'd to stable:
> > 
> > 	$ git show f39c1bfb5a|grep stable
> > 	    Cc: stable@vger.kernel.org [>= 3.1]
> > 
> > so presumably it's already on its way to older stable branches too.
> 
> No. See attachment... 

OK.  As long as it makes it to 3.6.x one way or another, I'm happy....

--b.
