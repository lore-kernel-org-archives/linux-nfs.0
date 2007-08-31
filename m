From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Follow up to: NFS/RPC Hangs after updating time...
Date: Fri, 31 Aug 2007 17:45:51 -0400
Message-ID: <20070831214551.GP11165@fieldses.org>
References: <BD261180E6D35F4D9D32F3E44FD3D90108F975FB@EMPBEDEX.empirix.com>
	<20070822202639.GL20946@fieldses.org>
	<BD261180E6D35F4D9D32F3E44FD3D901091DE759@EMPBEDEX.empirix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "Morrison, Tom" <tmorrison@empirix.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IREJI-0005Df-E8
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 14:45:48 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IREJM-0005an-ME
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 14:45:53 -0700
In-Reply-To: <BD261180E6D35F4D9D32F3E44FD3D901091DE759@EMPBEDEX.empirix.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Aug 31, 2007 at 02:35:19PM -0400, Morrison, Tom wrote:
> This is a follow-up...
> 
> After a huge pain in the rear upgrading from a 
> 2.6.11++ to a 2.6.23-rc3 (I'll give the powerpc
> folks a 'piece' of my mind on that front) - the 
> NFS hang problem that I was experiencing on the 
> older kernel is NOT occurring on this new version.
> 
> Now what do I do?

Well, between the time jump and the rpc debugging output, you've got
some great clues there--given some time I'm sure it would be possible to
completely figure out what's going on.

Unfortunately the people with the most knowledge of the code probably
don't have the time to fix problems on old kernels, so unless somebody
else recognizes the problem immediately, I'm not sure what to suggest.
Obviously, a wholesale upgrade to a more recent kernel would be the one
sure bet....

> Is the net/sunrpc net/nfsx pieces isolated enough 
> from the rest of the kernel that I could fork-lift 
> it back to the 2.6.11 (or is that really a lost cause).

I suspect it's a lost cause.  A lot has happened in the last couple
years.

--b.

> > It hangs after attempting to update the time from a 
> > nonsensical time (e.g.: 2 months ago) - the most significant
> > part of it is that it only hangs IFF it has started 
> > serving its NFS client boards before I attempt to 
> > update the time.
> > 
> > 
> > The most significant output (when turning on 
> > RPC debugging) is from:
> > 
> >   linux/net/sunrpc/cache.c (cache_check) - line 90:
> > 
> >          >> Want update, refage=1800, age=4288285
> > 
> > It continually loops through this method - and the cache
> > never gets updated...even thought with some additional
> > sleuthing (aka: additional debug printks - it thinks 
> > that there is an cache update pending).
> 
> Can you reproduce the problem with the current kernel? (Say 2.6.22 or
> later?)
> 
> --b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
