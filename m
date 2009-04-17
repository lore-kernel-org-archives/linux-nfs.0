From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/11] nfsd: Summary of "Improve NFS server performance"
Date: Fri, 17 Apr 2009 14:46:47 -0400
Message-ID: <20090417184647.GA19990@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>
To: Krishna Kumar <krikku@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54567 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbZDQSqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 14:46:50 -0400
In-Reply-To: <20090325133607.16437.33288.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 07:06:07PM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> 			Patch summary:
> 			--------------
> Change the caching from ino/dev to a file handle model. Advantages:
> 
> 1. Since file handles are unique, this patch removes all dependencies on the
>    kernel readahead parameters and it's implementation; and instead caches
>    files based on file handles.
> 2. Allows the server to not have to open/close a file multiple times when the
>    client reads it, and results in faster lookup times.
> 3. Readahead is automatically taken care of since the file is not closed while
>    it is getting read (quickly) by the client.
> 4. Another optimization is to avoid getting the cache lock twice for each read
>    operation (after the first time it is taken to update the cache).
> 5. (ra_size, ra_depth retain the "ra" prefix for now, since I have not checked
>    whether changing that will break any user programs)

You're referring here to the "ra" line in /proc/net/rpc/nfsd?

--b.
