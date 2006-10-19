From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] VFS: Make d_materialise_unique() enforce
	directory	uniqueness
Date: Thu, 19 Oct 2006 17:00:38 -0400
Message-ID: <1161291638.5506.9.camel@lade.trondhjem.org>
References: <20061019171113.8593.8585.stgit@lade.trondhjem.org>
	<E1GaerI-0007Af-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: torvalds@osdl.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gaf0S-0000F3-Qc
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 14:00:49 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gaf0R-0002AX-Mw
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 14:00:49 -0700
To: Miklos Szeredi <miklos@szeredi.hu>
In-Reply-To: <E1GaerI-0007Af-00@dorka.pomaz.szeredi.hu>
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

On Thu, 2006-10-19 at 22:51 +0200, Miklos Szeredi wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > If the caller tries to instantiate a directory using an inode that already
> > has a dentry alias, then we attempt to rename the existing dentry instead
> > of instantiating a new one. Fail with an ELOOP error if the rename would
> > affect one of our parent directories.
> > 
> > This behaviour is needed in order to avoid issues such as
> > 
> >   http://bugzilla.kernel.org/show_bug.cgi?id=7178
> >
> 
> This looks like a stale patch.  You posted one on -fsdevel that did
> i_mutex locking as well.

Argh! Thanks for spotting that Miklos... I had forgotten to update my
'fixes' stgit branch with the newer version. Please discard the previous
version of this patch, Linus. I'll resend...

Cheers,
  Trond

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
