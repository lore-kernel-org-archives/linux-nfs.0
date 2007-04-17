From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Tue, 17 Apr 2007 12:14:35 +0200
Message-ID: <200704171214.35952.olaf.kirch@oracle.com>
References: <17950.44333.118970.276558@notabene.brown>
	<200704122055.12223.vapier@gentoo.org>
	<17950.57188.878877.547112@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdkj4-0006Vj-6m
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 03:15:54 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hdkj6-0002IJ-E8
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 03:15:56 -0700
In-Reply-To: <17950.57188.878877.547112@notabene.brown>
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

On Friday 13 April 2007 03:39, Neil Brown wrote:
> > if that's true, then we could at least rewrite the socket code to bind to 
> > ports that do not appear in /etc/services (via getservbyport()) ... that'd 
> > allow admins to easily prevent things like mountd/statd from hijacking 
> > reserved ports ...
> 
> I had thought of that too.  I'll probably implement it.  Your code (in
> subsequent email) is a little more complicated than needed.  Just
> repeatedly call bindresvport, closing if you don't like it.  The port
> number tried increments each time.

The glibc shipped with Suse has a file called /etc/bindresvport.blacklist
that you can add ports to. I thought something similar had found its
way upstream by now, but unfortunately I can't find it.

ALTLinux seems to have this patch too.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
