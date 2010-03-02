From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3/NFSv4 problem.
Date: Tue, 2 Mar 2010 12:52:57 -0500
Message-ID: <20100302175257.GI5553@fieldses.org>
References: <D27EC8DD-AD1C-432D-99FD-E4AB6C26D189@gmail.com> <20100302171614.GH5553@fieldses.org> <0A63A1BA-F749-4CFF-B77D-98AEFC531035@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Anton Starikov <ant.starikov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50810 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab0CBRvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 12:51:48 -0500
In-Reply-To: <0A63A1BA-F749-4CFF-B77D-98AEFC531035@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 02, 2010 at 06:20:43PM +0100, Anton Starikov wrote:
> 
> On Mar 2, 2010, at 6:16 PM, J. Bruce Fields wrote:
> 
> > On Mon, Mar 01, 2010 at 04:01:42PM +0100, Anton Starikov wrote:
> >> Hi, 
> >> 
> >> 
> >> my config is diskless NFSv3 nfsroot (+ some extra NFDSv3 mounts) and NFSv4 /home/* automount.
> >> Centos 5.4, kernel 2.6.18-164.11.1.el5.
> > 
> > That's the client?  What's the server?
> 
> Server is Opensolaris.
> 
> > That's pretty old kernel; I'd file a bug with CentOS.
> 
> Unfortunately, with newer kernels this setup is even more problematic. :)

Any details?

As a rule, this list is probably going to be a better place to handle
bugs with the latest upstream kernels, and your distributor is more
likely to be useful for their kernels.

--b.

> 
> >> 
> >> What kind of information I have to collect from system to figure out what it real problem?
> > 
> > Is there any server-side logging?
> > Can you see any interesting network traffic after the hang?
> 
> It always unfortunate, but last couple of days I can't get a hang :) Although nothing changed in setup, so it will happen anyway.
> 
> 
> Anton.
> 
