From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 21 Nov 2005 14:55:17 -0500
Message-ID: <1132602917.8011.2.camel@lade.trondhjem.org>
References: <4382252E.4000602@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeHlW-0005Bc-LJ
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 11:55:50 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EeHlT-000622-Bp
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 11:55:50 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <4382252E.4000602@google.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, 2005-11-21 at 11:51 -0800, Vince Busam wrote:
> I posted this last week.  Here's an official style patch.

I've already put a fix into the latest NFS_ALL. See

http://client.linux-nfs.org/Linux-2.6.x/2.6.15-rc2/linux-2.6.15-06-rpc_pipe_fix_cleanup.dif

Thanks!
  Trond




-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
