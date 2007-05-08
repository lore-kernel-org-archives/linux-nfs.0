From: Neil Brown <neilb@suse.de>
Subject: Re: time_after cannot be used alone by NFS code	in
	32bit	architectures
Date: Tue, 8 May 2007 23:18:05 +1000
Message-ID: <17984.30861.472106.751930@notabene.brown>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
	<1178591824.3918.10.camel@raven.themaw.net>
	<17984.5736.617053.65429@notabene.brown>
	<1178627674.25317.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>,
	Ian Kent <raven@themaw.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlPaJ-0005zI-Ug
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 06:18:32 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlPaM-00068T-Bw
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 06:18:34 -0700
In-Reply-To: message from Trond Myklebust on Tuesday May 8
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

On Tuesday May 8, trond.myklebust@fys.uio.no wrote:
> 
> We can pretty trivially fix that scenario. See below.
> 
> Trond
> 
> ------------------------------------------
> commit 6d9b786c6c9b5daf8b20927c7495e42e1c7fde6a
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon May 7 22:41:18 2007 -0400
> 
>     NFS: Fix a jiffie wraparound issue
>     
>     dentry verifiers are always set to the parent directory's
>     cache_change_attribute. There is no reason to be testing for anything other
>     than equality when we're trying to find out if the dentry has been checked
>     since the last time the directory was modified.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Neat-o!!
It pays to have someone around who really knows the code well, doesn't
it :-)

Looks good to me!

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
