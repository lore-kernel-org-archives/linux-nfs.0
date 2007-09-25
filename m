From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/14] Prepare for fallback and fg/bg support in
	text mounts
Date: Tue, 25 Sep 2007 11:52:48 +1000
Message-ID: <18168.27120.983628.71275@notabene.brown>
References: <20070924152541.3804.77498.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZzbe-00054d-BE
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 18:52:58 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZzbd-0004So-Rx
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 18:53:03 -0700
In-Reply-To: message from Chuck Lever on Monday September 24
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

On Monday September 24, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Here's a refresh of the patch series to prepare nfs-utils for introducing
> support for version/protocol fallback and fg/bg to text-based NFS mounts.
> 
> This series addresses some minor memory leaks, adds comments and new error
> reporting functions, and fixes a handful of umount misbehaviors.

Thanks.  all applied.

I still don't think there is any point calling "free" just before
"exit" (patches 5 and 6) but it doesn't hurt....

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
