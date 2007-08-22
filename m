From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS/RPC Hangs after updating time...
Date: Wed, 22 Aug 2007 16:26:39 -0400
Message-ID: <20070822202639.GL20946@fieldses.org>
References: <BD261180E6D35F4D9D32F3E44FD3D90108F975FB@EMPBEDEX.empirix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	"Rushton,  Matt" <Mrushton@empirix.com>
To: "Morrison, Tom" <tmorrison@empirix.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INwmm-0008Cx-So
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 13:26:40 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INwmq-0008AW-1L
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 13:26:45 -0700
In-Reply-To: <BD261180E6D35F4D9D32F3E44FD3D90108F975FB@EMPBEDEX.empirix.com>
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
