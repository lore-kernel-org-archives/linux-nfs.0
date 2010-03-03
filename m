From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3/NFSv4 problem.
Date: Wed, 3 Mar 2010 10:45:17 -0500
Message-ID: <20100303154517.GD24586@fieldses.org>
References: <D27EC8DD-AD1C-432D-99FD-E4AB6C26D189@gmail.com> <20100302171614.GH5553@fieldses.org> <0A63A1BA-F749-4CFF-B77D-98AEFC531035@gmail.com> <20100302175257.GI5553@fieldses.org> <F4A02563-59B0-4A9B-B773-4FCF5FD2A8D4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Anton Starikov <ant.starikov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40116 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab0CCPoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Mar 2010 10:44:05 -0500
In-Reply-To: <F4A02563-59B0-4A9B-B773-4FCF5FD2A8D4@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 02, 2010 at 07:05:08PM +0100, Anton Starikov wrote:
> 
> On Mar 2, 2010, at 6:52 PM, J. Bruce Fields wrote:
> 
> >> 
> >>> That's pretty old kernel; I'd file a bug with CentOS.
> >> 
> >> Unfortunately, with newer kernels this setup is even more problematic. :)
> > 
> > Any details?
> > 
> > As a rule, this list is probably going to be a better place to handle
> > bugs with the latest upstream kernels, and your distributor is more
> > likely to be useful for their kernels.
> 

> I submitted that to this list about year ago. It seems that one of the
> biggest issues that with NFS3 root, and NFS4 /home idmapd get
> deadlocked. To resolve NFS4 credentials it need to access NFS3. which
> is blocked by waiting final of NFS4 operation. I tried to move a lot
> of stuff to tmpfs, but it didn't resolve situation, if root still
> NFS3.

Do you have a pointer to the previous discussion?

--b.

> 
> My general observation is that there is trend: newer kernel, faster
> you get deadlock with this setup :)
> 
> Anton.
> 
> 
> 
> 
