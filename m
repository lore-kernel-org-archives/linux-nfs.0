From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 900985: fix nohide export option for nfsv3
Date: Mon, 13 Oct 2003 16:17:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16266.17267.491587.121802@notabene.cse.unsw.edu.au>
References: <3F7CF147.B778D07B@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A8w1R-0002qc-00
	for <nfs@lists.sourceforge.net>; Sun, 12 Oct 2003 23:17:37 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A8w1P-00059V-9C
	for nfs@lists.sourceforge.net; Sun, 12 Oct 2003 23:17:35 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Mon, 13 Oct 2003 16:17:28 +1000
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Friday October 3
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday October 3, gnb@melbourne.sgi.com wrote:
> G'day,
> 
> SGI bug 900985.
> 
> The "nohide" export option fails over NFSv3 because the client gets
> as a side effect of READDIRPLUS file handles for server-side mountpoints 
> which haven't gone through the nohide logic in LOOKUP and thus refer
> to the underlying directory instead the covering one.
...
> 
> 
> --- /usr/tmp/TmpDir.24872-0/linux/linux/fs/nfsd/nfs3xdr.c_1.23	Fri Sep 19 20:12:50
> 2003
> +++ linux/linux/fs/nfsd/nfs3xdr.c	Fri Sep 19 20:09:25 2003
> @@ -721,6 +721,8 @@
>  			dchild = lookup_one_len(name, dparent,namlen);
>  		if (IS_ERR(dchild))
>  			goto noexec;
> +		if (d_mountpoint(dchild))
> +			goto noexec;
>  		if (fh_compose(&fh, exp, dchild, cd->dirfh) != 0 || !dchild->d_inode)
>  			goto noexec;
>  		p = encode_post_op_attr(cd->rqstp, p, &fh);
> 

This looks OK.  Thanks.

> --- /usr/tmp/TmpDir.24872-0/linux/linux/fs/nfsd/vfs.c_1.47	Fri Sep 19 20:12:50 2003
> +++ linux/linux/fs/nfsd/vfs.c	Fri Sep 19 20:08:03 2003
> @@ -86,7 +86,7 @@
>   * accepted as it stands and the mounted directory is
>   * returned. Otherwise the covered directory is returned.
>   * NOTE: this mountpoint crossing is not supported properly by all
> - *   clients and is explicitly disallowed for NFSv3
> + *   clients.
>   *      NeilBrown <neilb@cse.unsw.edu.au>

This isn't quite right.  What the comment *Should* say is:
 ... and RFC1813 explicitly dis-allows it for NFSv3 (See section 3.3.3).

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
