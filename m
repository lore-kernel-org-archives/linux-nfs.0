From: James Pearson <james-p@moving-picture.com>
Subject: Reducing NFSSVC_MAXBLKSIZE between server reboots?
Date: Mon, 05 Jan 2004 17:28:10 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF99EAA.7860959A@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AdYWd-0004H9-2a
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 09:28:23 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AdYWc-0005aT-GF
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 09:28:22 -0800
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1AdYWQ-0004z7-Hk
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 17:28:10 +0000
To: nfs@lists.sourceforge.net
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

If I'm running knfsd with NFSSVC_MAXBLKSIZE set at 32kb and then reboot
the server to use knfsd with NFSSVC_MAXBLKSIZE set to 8kb, what happens
(if anything) to any clients that had previously mounted a file system
with [rw]size set to 32kb?

Is doing this likely to cause problems?

Thanks

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
