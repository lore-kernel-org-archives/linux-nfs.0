From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 02:48:37 +0200
Message-ID: <200607110248.37374.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607110201.43319.agruen@suse.de>
	<20060711002826.GB1440@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G06TA-0005Rj-2S
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:51:20 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G06T8-0008Ot-U5
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:51:20 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060711002826.GB1440@fieldses.org>
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

On Tuesday, 11. July 2006 02:28, J. Bruce Fields wrote:
> On Tue, Jul 11, 2006 at 02:01:42AM +0200, Andreas Gruenbacher wrote:
> > The issue is that you sometimes want to give the owning group fewer
> > perissions than say, user:bfields in the above example. You can only do
> > that by separating the owning group and mask permissions.
> >
> > For this aspect of the problem (actually for all aspects except for those
> > that the DENY entries cause because they are sometimes difficult or
> > impossible to uniquely tell from other "ordinary" entries) it is totally
> > irrelevant whether the mask is represented as a mask:: acl entry as in
> > POSIX ACLs, as a series of DENY ACL entries, or as NFSv4 attributes.
> >
> > (POSIX ACLs only need one mask entry because they can never grant more
> > than rwx permissions anyway, and so the owner and other permissions are
> > always identical to the owner and other file mode permission bits. That's
> > no longer true with POSIX ACLs, and so there we also need mask entries
> > for the owner and for others.)
>
> So you need this if and only if you want to be able to set OWNER@
> permissions other than read, write, or execute, *and* want to be able to
> recover from a chmod?

I think I have answered this exhaustively in:

Subject: Re: [NFS] [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
         draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 02:44:30 +0200
Message-Id: <200607110244.31010.agruen@suse.de>

Andreas

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
