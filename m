From: Fredric Isaman <iisaman@citi.umich.edu>
Subject: Re: pynfs and server attributes?
Date: Mon, 10 Dec 2007 16:45:57 -0500 (EST)
Message-ID: <Pine.BSO.4.64.0712101633470.15300@citi.umich.edu>
References: <475DAFF9.3090206@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47907 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754271AbXLJWG0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 17:06:26 -0500
In-Reply-To: <475DAFF9.3090206@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Dec 2007, Jeff Garzik wrote:

> Is there a pynfs list somewhere?
>

Not that I know of.


> The pynfs tests for too-long strings, too-long reads and writes do not seem 
> to take into account maxname, maxread and maxwrite attributes.
>
> I actually have to _increase_ the python "longname" test variable in order 
> for the test to behave properly on my server :)
>
> 	Jeff


The fixed (but easily changeable) "longname" was intentional in order to 
avoid test dependencies on GETATTR, and non-mandatory attributes at that.

Would making the length of longname a command line option be useful?

>
>
> P.S.  Thanks to all who contributed to pynfs, it's been a great help.
>
>

I'm glad it is useful.

 	Fred

