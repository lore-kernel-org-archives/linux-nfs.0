From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS server does not update mtime on setattr
	request
Date: Wed, 7 Jun 2006 11:42:58 -0400
Message-ID: <20060607154258.GA22335@fieldses.org>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost>
	<4486E662.5080900@redhat.com> <20060607151754.GB23954@fieldses.org>
	<4486F020.3030707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fo0Be-00075z-9x
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:43:14 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fo0Bd-0001gY-TV
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:43:14 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4486F020.3030707@redhat.com>
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

On Wed, Jun 07, 2006 at 11:26:24AM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
> >What's the basis for that interpretation?  The language seems extremely
> >clear:
> >
> >	"On successful completion, if the file size is changed, these
> >	functions will mark for update the st_ctime and st_mtime fields
> >	of the file, and if the file is a regular file, the S_ISUID and
> >	S_ISGID bits of the file mode may be cleared."
> >
> >Why are you concerned about this?  Do you have an actual application
> >that breaks?
> 
> Yes, there is a customer who is quite unhappy that the semantics over Linux
> client NFS are different than those of BSD, Solaris, and local file system
> access on Linux itself.  The basis for my work is based on a bugzilla from
> this customer.

OK; just out of curiosity, what's the url/bug number/whatever?

> My interpretation is based on looking at the local behavior on Linux, which
> changes mtime/ctime even if the file size does not change, and SunOS, which
> changes mtime/ctime even if the file size does not change and is very
> heavily SUSv3 compliant.

Fair enough.

> In this case, "changed" does not mean "made different".  It simply means
> that the file size is set to the new value.

That's ridiculous, though; that's just not what "changed" means, and
that renders the "if" clause redundant.  Better just to say "SUS is
wrong, and this is what everybody actually does...."

--b.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
