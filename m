From: Gabriel Barazer <gabriel-KSe8qvLY914@public.gmane.org>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 06 Feb 2008 19:24:53 +0100
Message-ID: <47A9FB75.90206@oxeva.fr>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>	 <47A9C620.70106@oxeva.fr> <1202311096.12647.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.reagi.com ([195.60.188.80]:42944 "EHLO mail.reagi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbYBFSZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 13:25:00 -0500
In-Reply-To: <1202311096.12647.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/06/2008 4:18:16 PM +0100, Trond Myklebust 
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2008-02-06 at 15:37 +0100, Gabriel Barazer wrote:
> 
>>> Should I go for NFSv2 (default if I dont change mount options) NFSv3 ? or
>>> NFSv4
>> NFSv2/3 have nearly the same performance
> 
> Only if you shoot yourself in the foot by setting the 'async' flag
> in /etc/exports. Don't do that...
> 
> Most people will want to use NFSv3 for performance reasons. Unlike NFSv2
> with 'async', NFSv3 with the 'sync' export flag set actually does _safe_
> server-side caching of writes.
> 

Oops (tm)! Fortunately I do mostly reads, but maybe the exports(5) man 
page should be updated. According to the man page, I thought that 
although writes aren't commited to the block devices, the server-side 
cache is correctly synchronized (but lost if you pull the plug). Thanks 
for the explanation. Having a battery backed large write cache on the 
server, is there a performance hit when switching from async to sync in 
NFSv3 ?

Off-Topic: maybe the warning when omitting the 'sync' option at export 
should be removed to only be showed when using the 'async' option ? We 
really want to warn people before too many feet are shot :-)

To Jesper: I found out that using the 'nolock' flag at mount time on the 
nfs clients improve the performances but obviously only if don't need 
write locks (and your setup seems to do only intensive reads)

Gabriel
