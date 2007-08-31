From: "Morrison, Tom" <tmorrison@empirix.com>
Subject: Follow up to: NFS/RPC Hangs after updating time...
Date: Fri, 31 Aug 2007 14:35:19 -0400
Message-ID: <BD261180E6D35F4D9D32F3E44FD3D901091DE759@EMPBEDEX.empirix.com>
References: <BD261180E6D35F4D9D32F3E44FD3D90108F975FB@EMPBEDEX.empirix.com>
	<20070822202639.GL20946@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRBLm-000396-0O
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 11:36:10 -0700
Received: from empbedex1.empirix.com ([12.38.203.54])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IRBLq-0002PE-04
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 11:36:14 -0700
In-Reply-To: <20070822202639.GL20946@fieldses.org>
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

This is a follow-up...

After a huge pain in the rear upgrading from a 
2.6.11++ to a 2.6.23-rc3 (I'll give the powerpc
folks a 'piece' of my mind on that front) - the 
NFS hang problem that I was experiencing on the 
older kernel is NOT occurring on this new version.

Now what do I do?

Is the net/sunrpc net/nfsx pieces isolated enough 
from the rest of the kernel that I could fork-lift 
it back to the 2.6.11 (or is that really a lost cause).

Thanks for any/all feedback on this front!


-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Wednesday, August 22, 2007 4:27 PM
To: Morrison, Tom
Cc: nfs@lists.sourceforge.net; linux-kernel@vger.kernel.org; Rushton,
Matt
Subject: Re: NFS/RPC Hangs after updating time...

On Wed, Aug 22, 2007 at 02:37:22PM -0400, Morrison, Tom wrote:
> I am working with a 2.6.11++ kernel on an embedded 
> server platform that is NFS serving Linux rootfs 
> for other embedded NFS Client boards.
> 
> Everything works fine when the system time on the 
> server board is relatively synchronized with the real-time. 
> 
> It hangs after attempting to update the time from a 
> nonsensical time (e.g.: 2 months ago) - the most significant
> part of it is that it only hangs IFF it has started 
> serving its NFS client boards before I attempt to 
> update the time.
> 
> 
> The most significant output (when turning on 
> RPC debugging) is from:
> 
>   linux/net/sunrpc/cache.c (cache_check) - line 90:
> 
>          >> Want update, refage=1800, age=4288285
> 
> It continually loops through this method - and the cache
> never gets updated...even thought with some additional
> sleuthing (aka: additional debug printks - it thinks 
> that there is an cache update pending).

Can you reproduce the problem with the current kernel? (Say 2.6.22 or
later?)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
