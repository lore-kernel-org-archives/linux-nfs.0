From: Olaf Kirch <okir@suse.de>
Subject: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 16:40:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040429144012.GA15361@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJClF-0002fr-8u
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 07:43:37 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BJClB-00038u-6m
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 07:43:33 -0700
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 5C3C8507D7B
	for <nfs@lists.sourceforge.net>; Thu, 29 Apr 2004 16:40:12 +0200 (CEST)
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

Hi,

I've been debugging a strange problem with kmail on an NFS mounted
home directory. Attaching files to an outgoing message would cause
the mail to fail. For instance, after opening the file selection
dialog, kmail was no longer able to read the outbox.
This was 100 % reproduceable

The problem was caused by the following:

 -	a KDE component would invoke some silly setuid
 	helper program prior to displaying the file
	selection dialog. This helper would receive all
	open file descriptors, including those of the
	open mail boxes.

 -	the helper program itself did not access any of
 	these files, but for some reason, we still ended
	up calling revalidate_inode on the open files.
	I haven't quite found out why.

 -	nfs_revalidate_inode would do a GETATTR call to
 	the server (running the 2.4.22 kernel), using
	uid 0.

	The file system was exported with root_squash
	and subtree_check.

	fh_verify did the subtree check, and found that
	~/Mail was mode 700, and hence user nobody didn't
	have x permissions on the directory. So it would
	return ESTALE to the client.

 -	The client marks the file handle as STALE

 -	The next attempt to read from the file fails because
 	of this.

How should we fix this? I asked the KDE folks to mark their mail box
file descriptor FD_CLOEXEC, but that is just a workaround, as other
application may exhibit similar problems.

I think it's wrong to mark the file handle STALE for everyone; whether
GETATTR reports NFSERR_STALE can depend on the process doing the call.

What is the rationale behind making the stale-ness information sticky?
Can we safely get rid of the NFS_INO_STALE flag?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
