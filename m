From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS server does not update mtime on setattr
	request
Date: Wed, 7 Jun 2006 11:17:54 -0400
Message-ID: <20060607151754.GB23954@fieldses.org>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost>
	<4486E662.5080900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fnznq-0005CU-0W
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:18:38 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fnznq-0007h1-25
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:18:38 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FnznK-0004Zy-0z
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:18:08 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4486E662.5080900@redhat.com>
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

On Wed, Jun 07, 2006 at 10:44:50AM -0400, Peter Staubach wrote:
> I saw that wording too and assumed what I think that you assumed.  I
> assumed that that meant that if the new size is equal to the old size,
> then nothing should be changed.  However, that does not seem to be how
> those words are to be interpreted.  They are to be interpreted as "if
> the new length of the file can be successfully set, then the
> mtime/ctime should be changed".

What's the basis for that interpretation?  The language seems extremely
clear:

	"On successful completion, if the file size is changed, these
	functions will mark for update the st_ctime and st_mtime fields
	of the file, and if the file is a regular file, the S_ISUID and
	S_ISGID bits of the file mode may be cleared."

Why are you concerned about this?  Do you have an actual application
that breaks?

--b.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
