From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Fix umount.nfs exit status
Date: Mon, 16 Jul 2007 10:59:27 +1000
Message-ID: <18074.49903.229173.242771@notabene.brown>
References: <20070714091848.GA23409@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAEw2-0005qA-2w
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 17:59:34 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAEw4-00062G-J7
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 17:59:37 -0700
In-Reply-To: message from Steinar H. Gunderson on Saturday July 14
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

On Saturday July 14, sesse@debian.org wrote:
> Hi,
> 
> As per a bug report from a user:
> 
> mount.c seems to assume that nfsumount() uses standard C true/false
> return values, and inverts them for the exit status (where 0 is
> traditionally considered success). However, nfsumount() consistently
> seems to use 0 for success, and thus a success gets returned as exit
> status 1 and a failure as exit status 0. This confuses at least
> the GNOME drive manager applet, and probably others as well.
> 
> Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

Thanks.  Applied.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
