From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Tue, 17 Apr 2007 13:32:02 +0200
Message-ID: <200704171332.03490.olaf.kirch@oracle.com>
References: <17950.44333.118970.276558@notabene.brown>
	<200704171208.51797.olaf.kirch@oracle.com>
	<200704170721.27869.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdlvi-0006Cn-Ns
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 04:33:02 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hdlvi-00079K-Je
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 04:33:05 -0700
In-Reply-To: <200704170721.27869.vapier@gentoo.org>
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

On Tuesday 17 April 2007 13:21, Mike Frysinger wrote:
> seems like that sort of security is hopelessly outdated in today's networking 
> world ... if the authentication tuple is {ip,port}, then spoofing would 
> certainly already be the source of DoS attacks on portmap

No, pmap_register/unregister must originate from 127.0.0.1, so
this is actually some degree of security.

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
