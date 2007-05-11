From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils: have mountd hold open etab
	file	to	force inode number to change
Date: Fri, 11 May 2007 13:34:25 +1000
Message-ID: <17987.58433.702253.343439@notabene.brown>
References: <20070509141931.GC26568@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HmLuQ-00078l-CB
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 20:35:10 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HmLuR-0000Us-S8
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 20:35:13 -0700
In-Reply-To: message from Jeff Layton on Wednesday May 9
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

On Wednesday May 9, jlayton@redhat.com wrote:
> Hadn't heard anything on this patch in a week or so, so resending it...
> 

I really thought I had applied that.

I have now.

Thanks.

NeilBrown

> This patch was suggested by Neil. It changes mountd to hold the etab file open
> so that when it's changed by exportfs, the inode number should change. We then
> change auth_reload to reload the file based on whether st_ino is different from
> the last time it was checked. It also changes auth_reload to maintain a static
> counter value and return it instead of a timestamp and fixes up get_exportlist
> accordingly. Finally, it adds some comments to xtab_write to warn people about
> editing the etab in place.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
