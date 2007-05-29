From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: fix uninitialized variable
Date: Mon, 28 May 2007 23:00:50 -0400
Message-ID: <20070529030050.GB20631@fieldses.org>
References: <20070527103442.GA10594@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HsrxA-0004Ul-HI
	for nfs@lists.sourceforge.net; Mon, 28 May 2007 20:00:56 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HsrxC-00015x-BL
	for nfs@lists.sourceforge.net; Mon, 28 May 2007 20:00:59 -0700
In-Reply-To: <20070527103442.GA10594@havoc.gtf.org>
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

On Sun, May 27, 2007 at 06:34:42AM -0400, Jeff Garzik wrote:
> 
> Unlike many of the bogus warnings spewed by gcc, this one actually
> complains about a real bug:

No, the calls to posix_acl_valid() in nfs4_acl_posix_to_nfsv4() ensure
that the passed-in acl has ACL_USER_OBJ, ACL_GROUP_OBJ, and ACL_OTHER
entries, and hence that these fields will always be initialized.

But I don't want anyone else wasting their time on this.  Should we cave
in and add the initialization here just to shut up gcc?  Or would a
comment here help?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
