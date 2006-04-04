From: Chris Osicki <osk@admin.swisscom-mobile.ch>
Subject: Q: NFS server cluster, again
Date: Tue, 4 Apr 2006 15:39:50 +0200
Message-ID: <20060404153950.4006897a@mwdsp001>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQllF-0002Z8-Bs
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 06:39:57 -0700
Received: from outmail2.swisscom.com ([138.190.3.29] helo=mrp.swissptt.ch)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FQllD-0001Sl-Or
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 06:39:57 -0700
Received: from mwdsp001.swissptt.ch (mwdsp001.swissptt.ch [10.221.40.203])
	by mrp.swissptt.ch with ESMTP id k34DdqQa027258
	(using TLSv1/SSLv3 with cipher EDH-RSA-DES-CBC3-SHA (168 bits) verified NO)
	for <nfs@lists.sourceforge.net>; Tue, 4 Apr 2006 15:39:53 +0200 (MEST)
Received: from mwdsp001 (localhost [127.0.0.1])
	by mwdsp001.swissptt.ch (8.13.4/8.13.4) with ESMTP id k34Ddog7011524
	for <nfs@lists.sourceforge.net>; Tue, 4 Apr 2006 15:39:50 +0200
To: nfs@lists.sourceforge.net
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


Hello

In my previous posting I described the setup of a NFS cluster I built
and some problems I had.
Now everything looks OK. My main concern however is cluster fail-over
when a process is writing to a file on a NFS-mounted directory.
Up to now my NFS-clients have always been able to "recover" even if 
sometimes it takes up to five minutes until I see again data on the server.

My question: am I just lucky now but asking for problems or is it an
expected behaviour?

Is anybody of you reading this list running a Linux NFS cluster
and willing to share his/her experiences? Any success/horror stories?

Servers are RedHat EL 4, kernel: 2.6.9-11.ELsmp
Clients are Solaris9 and 10.

Thanks for your time.

Regards,
Chris


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
