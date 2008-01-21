From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Mutex Hang on GC in lockd for 2.6.22-14
Date: Mon, 21 Jan 2008 16:03:57 -0500
Message-ID: <20080121210357.GP17468@fieldses.org>
References: <479427C5.8020203@spiderfan.org> <18324.11227.8442.938224@notabene.brown> <47942CA4.1060700@spiderfan.org> <20080121183121.GJ17468@fieldses.org> <47950544.2080205@spiderfan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jonathan Couper <jonathan-3c88B9b11vOEi8DpZVb4nw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49177 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781AbYAUVD7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 16:03:59 -0500
In-Reply-To: <47950544.2080205-3c88B9b11vOEi8DpZVb4nw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 22, 2008 at 09:49:08AM +1300, Jonathan Couper wrote:
> Heya,
>
> 	What's the path for that getting rolled back into the 2.6.22 chain?  In  
>  generally I'm happy with my 2.6.22 kernel.  Is Jeff submitting those  
> fixes to the 2.6.22 release at some stage, do you know?

There appear to be two separate problems here with two fixes:

	- the possibility of multiple lockd's at once, fixed by Jeff's
	  patches.
	- the double-lock problem, fixed by Trond's two patches.

It sounds like the latter may actually be what you're more in need of?
They're probably easier to backport in any case.

I don't know if those are in 2.6.22, or if 2.6.22 is still open.  I'd
add pointers to those two patches to the bugzilla report for the ubuntu
people to look at.

--b.
