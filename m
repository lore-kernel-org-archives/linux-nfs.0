From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: directory attribute cache on NFS4 client
Date: Tue, 2 Sep 2008 16:11:29 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0809021610460.7435@citi.umich.edu>
References: <loom.20080829T132559-688@post.gmane.org> <loom.20080901T163528-489@post.gmane.org>
 <20080902175047.GA10855@fieldses.org> <loom.20080902T195042-521@post.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Ricardo Santos <xscorpionbr-/E1597aS9LRfJ/NunPodnw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:3552 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076AbYIBUhJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2008 16:37:09 -0400
In-Reply-To: <loom.20080902T195042-521-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2 Sep 2008, Ricardo Santos wrote:

> Has anyway to disable delegations on Linux NFS Server ?

	yes, you can echo 0 to /proc/sys/fs/leases-enable

	note that that disables all leases (atop which NFS delegations are 
implemented).

	d
	.

> 
> Thanks for help
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
