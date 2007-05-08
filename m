From: Ian Kent <raven@themaw.net>
Subject: Re: time_after cannot be used alone by NFS code	in
	32bit	architectures
Date: Tue, 08 May 2007 21:07:05 +0800
Message-ID: <1178629625.3918.75.camel@raven.themaw.net>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
	<1178591824.3918.10.camel@raven.themaw.net>
	<17984.5736.617053.65429@notabene.brown>
	<1178627674.25317.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-nfs <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlPPL-0004hF-2Y
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 06:07:13 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HlPPM-0002Tf-Iy
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 06:07:13 -0700
In-Reply-To: <1178627674.25317.2.camel@heimdal.trondhjem.org>
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

On Tue, 2007-05-08 at 08:34 -0400, Trond Myklebust wrote:
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

Of course.
Ha .. why is it so hard to see something so simple!
Thanks Trond

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
