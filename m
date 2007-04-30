From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: flock and lockf over NFS and the 'pid' in lockd requests.
Date: Mon, 30 Apr 2007 00:11:03 -0400
Message-ID: <46356C57.1040601@redhat.com>
References: <17973.19011.690165.95878@notabene.brown>	<1177899233.6400.58.camel@heimdal.trondhjem.org>
	<17973.26166.844328.279844@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiN41-0006mL-S5
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 21:00:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiN44-00022p-8L
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 21:00:40 -0700
In-Reply-To: <17973.26166.844328.279844@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Neil Brown wrote:

>On Sunday April 29, trond.myklebust@fys.uio.no wrote:
>  
>
>>??? On the contrary. Genuine conflicts are currently resolved by the
>>server and the server alone. We do admittedly call do_vfs_lock() with
>>the ACCESS flag set, but that doesn't set a lock. 
>>
>Oh bother, I didn't notice the ACCESS setting.  Thanks for that.
>  
>

Tons of people, including me, missed that flag when they first looked at 
this code.

> Indeed... can it be fixed I wonder.
>
>[snip]
>
> - massive rewrite of the lockd code so that the client doesn't depend
>   on the server for local arbitration,
>
I "like" this (think about performance gain).

>
>What would you think of an "noflock" option to allow people to choose
>the old practice of not supporting flock???
>  
>
Ha! Take easy way out ? (sorry, can't resist this :) ).

-- Wendy


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
