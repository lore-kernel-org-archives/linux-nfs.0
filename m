From: Frank Cusack <fcusack@fcusack.com>
Subject: Re: nfs_refresh_inode: inode number mismatch (bug)
Date: Mon, 2 Jun 2003 02:46:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030602024625.A19179@google.com>
References: <20030602013731.B18730@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-239-45-4.google.com ([216.239.45.4])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Mlth-0001sJ-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Jun 2003 02:46:33 -0700
To: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
In-Reply-To: <20030602013731.B18730@google.com>; from fcusack@fcusack.com on Mon, Jun 02, 2003 at 01:37:31AM -0700
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

On Mon, Jun 02, 2003 at 01:37:31AM -0700, Frank Cusack wrote:
> I've found an issue with nfs_rmdir(), at least that's where I think it is.

A little more info ...

This seems related to nfs3, and I'm going to guess readdirplus.  If
I mount as nfsv2, I don't see the problem.

It just struck me that there are a lot of readdirplus-related logs just
before the "bug".  I didn't think anything of it (because, *of course*
there is a bunch of activity there) but in a rare moment of clarity I
figured I should try v2.

I'll continue to look at this tomorrow, but I'm sure Trond or one of
the wizards here will instantly know where the problem is. :-)

/fc


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
