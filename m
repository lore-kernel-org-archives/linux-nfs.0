From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 001 of 2] Set meaningful value for
	fattr->time_start in	readdirplus results.
Date: Mon, 16 Apr 2007 11:23:08 -0400
Message-ID: <1176736988.6761.50.camel@heimdal.trondhjem.org>
References: <20070306163710.8128.patches@notabene> <1070306054025.8345@suse.de>
	<1176588819.6089.14.camel@heimdal.trondhjem.org>
	<17954.46783.532806.874084@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdT32-0003ez-M1
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 08:23:21 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/LNDm6WY90uc4tHQSBPispKiCBEYkT7yg=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdT32-0006iW-IK
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 08:23:23 -0700
In-Reply-To: <17954.46783.532806.874084@notabene.brown>
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

On Mon, 2007-04-16 at 09:35 +1000, Neil Brown wrote:
> > 
> > One solution might be to detect if find_dirent_page called
> > nfs_readdir_filler, and then to have dir_decode() set NFS_ATTR_FATTR
> > only if we're reading a fresh page?
> 
> That probably works well enough.  If the app is doing very small
> getdirents call, the first few entries from each page will have the
> readdir_plus info honoured and the remainder will have it ignored.  I
> doubt that is a problem in real-life.... unless it means the d_type
> field doesn't get set properly.
> 
> Anyway, here is an updated patch that uses the above idea and has been
> tested to solve the particular symptom.

This looks better. I'm putting it into testing with a view to inclusion
in 2.6.22.

Thanks
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
