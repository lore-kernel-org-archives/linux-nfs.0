From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Mon, 10 Jul 2006 20:28:26 -0400
Message-ID: <20060711002826.GB1440@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<B0F5507F-A317-44F7-B6A3-A5005542A631@Sun.COM>
	<20060710141541.GA978@fieldses.org>
	<200607110201.43319.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@sun.com>, nfsv4@ietf.org,
	Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0675-0002Ci-93
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:28:31 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G0674-00046K-9u
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:28:31 -0700
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200607110201.43319.agruen@suse.de>
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

On Tue, Jul 11, 2006 at 02:01:42AM +0200, Andreas Gruenbacher wrote:
> The issue is that you sometimes want to give the owning group fewer perissions 
> than say, user:bfields in the above example. You can only do that by 
> separating the owning group and mask permissions.
> 
> For this aspect of the problem (actually for all aspects except for those that 
> the DENY entries cause because they are sometimes difficult or impossible to 
> uniquely tell from other "ordinary" entries) it is totally irrelevant whether 
> the mask is represented as a mask:: acl entry as in POSIX ACLs, as a series 
> of DENY ACL entries, or as NFSv4 attributes.
> 
> (POSIX ACLs only need one mask entry because they can never grant more than 
> rwx permissions anyway, and so the owner and other permissions are always 
> identical to the owner and other file mode permission bits. That's no longer 
> true with POSIX ACLs, and so there we also need mask entries for the owner 
> and for others.)

So you need this if and only if you want to be able to set OWNER@
permissions other than read, write, or execute, *and* want to be able to
recover from a chmod?

The argument for the reversibility of chmod seems a lot stronger when
the information that could be lost is a long list of users and
permissions than when it's just a few bits for the owner.

--b.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
