Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176Ab0HQVtW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 17:49:22 -0400
Message-ID: <4C6B03DE.5040105@RedHat.com>
Date: Tue, 17 Aug 2010 17:49:18 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Guillaume Rousse <Guillaume.Rousse@inria.fr>
CC: linux-nfs@vger.kernel.org
Subject: Re: [patch] fix description of nfsversion mount option
References: <4C66ADF2.9030700@inria.fr>
In-Reply-To: <4C66ADF2.9030700@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/14/2010 10:53 AM, Guillaume Rousse wrote:
> Hello list.
> 
> Here is a first patch trying to update a little bit nfs-utils
> documentation. I'd like also to change the constant opposition of 'nfs'
> vs 'nfs4' filesystems in this man page, but I have no clue if the plan
> is to remove 'nfs4' filesystem completly, or to keep for compatibility
> purpose. In the first case, I'd just remove any occurence of it in the
> man page, in the second case, I'm less sure about what to do.
In the future please use the proper Signed-off-by: line in 
your patch... Its cool for this time, since the change is a 
minor one... 
> 
> Also, I really think NEWS and ChangeLOG files should be either dropped,
> or merged and updated.
I believe those are needed for all the autoconf scripts we have...
but, in my copious spare time ;-) , I'll take a look at them..

steved.
