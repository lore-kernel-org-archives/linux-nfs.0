From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS server does not update mtime on
	setattr	request
Date: Wed, 07 Jun 2006 11:39:02 -0400
Message-ID: <1149694742.26188.6.camel@localhost>
References: <4485C3FE.5070504@redhat.com>
	<1149658707.27298.10.camel@localhost> <4486E662.5080900@redhat.com>
	<20060607151754.GB23954@fieldses.org>  <4486F020.3030707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fo085-0006ii-Eo
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:39:33 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fo081-0000n3-LM
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 08:39:30 -0700
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

On Wed, 2006-06-07 at 11:26 -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
> 
> >On Wed, Jun 07, 2006 at 10:44:50AM -0400, Peter Staubach wrote:
> >  
> >
> >>I saw that wording too and assumed what I think that you assumed.  I
> >>assumed that that meant that if the new size is equal to the old size,
> >>then nothing should be changed.  However, that does not seem to be how
> >>those words are to be interpreted.  They are to be interpreted as "if
> >>the new length of the file can be successfully set, then the
> >>mtime/ctime should be changed".
> >>    
> >>
> >
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
> >
> 
> Yes, there is a customer who is quite unhappy that the semantics over Linux
> client NFS are different than those of BSD, Solaris, and local file system
> access on Linux itself.  The basis for my work is based on a bugzilla from
> this customer.
> 
> My interpretation is based on looking at the local behavior on Linux, which
> changes mtime/ctime even if the file size does not change, and SunOS, which
> changes mtime/ctime even if the file size does not change and is very
> heavily SUSv3 compliant.
> 
> In this case, "changed" does not mean "made different".  It simply means
> that the file size is set to the new value.
> 
> I would have chosen different words or a different interpretation too,
> but all of the evidence suggests that the semantics are as I stated.

We've already fixed this to be SuSv3 compliant for both create and
truncate. Your "safe" suggestion would break truncate again. That is why
it is being vetoed.

Cheers,
  Trond



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
