From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS server does not update mtime on setattr
	request
Date: Wed, 07 Jun 2006 01:38:26 -0400
Message-ID: <1149658707.27298.10.camel@localhost>
References: <4485C3FE.5070504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fnql4-0003vr-5R
	for nfs@lists.sourceforge.net; Tue, 06 Jun 2006 22:39:10 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fnql4-0002QI-36
	for nfs@lists.sourceforge.net; Tue, 06 Jun 2006 22:39:10 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fnql2-0006Ij-QY
	for nfs@lists.sourceforge.net; Tue, 06 Jun 2006 22:39:10 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4485C3FE.5070504@redhat.com>
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

On Tue, 2006-06-06 at 14:05 -0400, Peter Staubach wrote:

> On the NFS client side, there was an optimization added which attempted
> to avoid an over the wire call if the size of the file was not going to
> change.  This would be great, except for the side effect of the mtime
> on the file needing to change anyway.  The solution is just to issue the
> over the wire call anyway, which, as a side effect, updates the mtime and
> ctime fields.

Vetoed!

The current code gets it quite right: if someone calls open(O_TRUNC),
then may_open() calls do_truncate() with the ATTR_MTIME|ATTR_CTIME flags
set. That will cause the client to do the right thing _regardless_ of
the size optimisation.

> On the NFS server side, there was a change to the routine, inode_setattr(),
> which now relies upon the caller to set the ATTR_MTIME and ATTR_CTIME
> flags in ia_valid in addition to the ATTR_SIZE.  Previously, this routine
> would force these bits on if the size of the file was not changing.  Now,
> this routine relies upon the caller to specify all of the fields which need
> to be updated.

Also wrong.

This change causes the server to do entirely the wrong thing for
truncate()/ftruncate() calls: in the SuSv3 spec, a call that fails to
change the file length is supposed to leave the file entirely unchanged:
that includes mtime/ctime as well as suid/sgid bits.

Cheers,
  Trond



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
