From: Olaf Kirch <okir@suse.de>
Subject: maybe a svcsock.c/sv_lock deadlock?
Date: Tue, 27 Jul 2004 16:14:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040727141433.GB11023@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpSj0-0001BW-En
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 07:14:38 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpSiz-0003XI-SI
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 07:14:38 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 60F2D95E4EE
	for <nfs@lists.sourceforge.net>; Tue, 27 Jul 2004 16:14:34 +0200 (CEST)
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

I have a somewhat unclear bug report against the 2.6 kernel, where
the sysrq output seems to indicate there's a deadlock on sv_lock
somewhere. There is a stuck process is in tcp_data_ready, but
unfortunately the sysrq output is not complete, so I don't know what
the other CPUs were doing at the time.

Looking at the code, I did notice however that some new code was
added recently (svc_defer, svc_revisit) that uses spin_lock instead of
spin_lock_bh when grabbing the sv_lock.

So it seems there's potential for deadlock if TCP data arrives while
one of these new functions hold sv_lock.

Comments?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
