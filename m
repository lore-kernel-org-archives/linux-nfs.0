Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756291Ab1BCNki (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 08:40:38 -0500
Date: Thu, 3 Feb 2011 08:40:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nix <nix@esperi.org.uk>
Cc: George Spelvin <linux@horizon.com>, linux-nfs@vger.kernel.org
Subject: Re: persistent, quasi-random -ESTALE at mount time
Message-ID: <20110203134035.GA18325@fieldses.org>
References: <20110203034844.GA30641@fieldses.org>
 <20110203042814.6364.qmail@science.horizon.com>
 <20110203044010.GC30641@fieldses.org>
 <87zkqdo6yv.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87zkqdo6yv.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 03, 2011 at 08:30:48AM +0000, Nix wrote:
> On 3 Feb 2011, J. Bruce Fields stated:
> 
> > Ouch.  I do test that regularly, and haven't seen problems.  Again, if
> > you have reproduceable problem, I'd appreciate details.--b.
> 
> I can give you a packet dump from my (completely reproducible) failure
> with the same symptoms, if you like. (Again, it is fixed by running
> exportfs repeatedly, each time fixing another few mounts: currently,
> I have to run it six times.)

That would be great, thanks.  And could you collect the contents of
/proc/net/rpc/{nfsd.fh,nfsd.export}/content at the same time?  (I think
you already sent some; but I'd be curious to match them up with the
packet trace.)  Also, the output of "blkid" might help diagnose any
problems with uuid's.

(Also, I think it's probably a totally different problem, but I found a
problem yesterday with out-of-date uuid information that appears to be
due to selinux preventing rpc.mountd from opening block devices; are you
using selinux, and if so does turning it off (setenforce 0) help?)

--b.
