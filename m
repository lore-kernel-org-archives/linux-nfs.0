From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: broken umount -f
Date: 14 Jan 2003 20:06:09 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8yxn5z6m.fsf@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D551E8@black.eng.netapp.com>
	<20030114170755.GA18952@questra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWO7-0006yT-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:06:15 -0800
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030114170755.GA18952@questra.com>
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

>>>>> " " == Scott Mcdermott <smcdermott@questra.com> writes:

     > Lever, Charles on Tue 14/01 07:56 -0800:
    >> however, if there are no outstanding RPCs on the client, but
    >> the server is not available, umount -f works as advertised.

     > I think his point was that Solaris will allow root to umount -f
     > in any case.

     > Right now I have to reboot my Linux NFS clients remotely with a
     > "sync; reboot -f" if they are stuck on a stale mount.  `init 6'
     > will time out forever trying to unmount NFS filesystems (and
     > yes, the init scripts use `-f'), and by that time my sshd is
     > killed so I have to drive out to the colo site.

Linux will not allow you to unmount without killing those processes,
and I'd be opposed to any patch that tries to kill active processes
from within the filesystem.
This is something that needs to be resolved in userland.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
