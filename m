From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: (no subject)
Date: Fri,  8 Jun 2007 18:14:50 -0400
Message-ID: <18750.2763852992$1181340939@news.gmane.org>
References: <20070607170557.GA14463@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Teigland <teigland@redhat.com>,
	Robert Rappaport <robert.rappaport@gmail.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwmjS-0007px-TB
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 15:14:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwmjU-0002pV-E6
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 15:15:02 -0700
In-Reply-To: <20070607170557.GA14463@fieldses.org>
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


J. Bruce Fields <bfields@fieldses.org> wrote:
> OK, good.  I'll revise and post a new series.  (Do people prefer
> another mailbomb or a git url?)

OK, I went for the former; if you'd rather get this out of git, you can

	git clone http://www.linux-nfs.org/~bfields/linux.git
	git checkout server-cluster-lease-api

The changes from the last version seem pretty trivial, but I've
compile-tested this only for now.

I'm ignoring the problem of breaking leases on unlink and rename.  I
think we should go ahead and do this part now--it's adequate for the
current lease semantics, and even more so for our current application
(just turning off leases selectively on some filesystems)--but I'd
really like to solve that problem eventually.

That's probably not going to happen until we get a cluster filesystem
with real lease support into the kernel....

Changes:
	- do away with the break_lease method.
	- rename __setlease to setlease, setlease to vfs_setlease, and
	  make sure it's setlease (the one that doesn't call into the
	  filesystem) that's exported.
	- rename ->set_lease to ->setlease.  (I don't really care which
	  we go with, it just seemed confusing when everything else was
	  already named without the underscore.)
	- Add a trivial patch that disables leases on nfs (as suggested
	  by a patch elsewhere from Peter Staubach)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
