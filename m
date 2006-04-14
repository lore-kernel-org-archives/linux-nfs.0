From: "Gabor Z. Papp" <gzp@papp.hu>
Subject: Re: ANNOUNCE: nfs-utils 1.0.8 (final)
Date: Fri, 14 Apr 2006 17:31:45 +0200
Message-ID: <x6ek0018da@gzp>
References: <17468.29136.672049.677855@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUQH6-000540-BB
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 08:31:56 -0700
Received: from odpn1.odpn.net ([212.40.96.53])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FUQH2-0002r9-Ou
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 08:31:56 -0700
To: Neil Brown <neilb@suse.de>
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

* Neil Brown <neilb@suse.de>:

| I have made a final release of  nfs-utils 1.0.8

I'm trying to compile it on Linux 2.4.32 using gcc 3.4.5, glibc 2.2.5

Probably my glibc is outdated, but works well. ;-)

rmtcall.c:40:21: ifaddrs.h: No such file or directory
rmtcall.c: In function `reset_my_name':
rmtcall.c:112: warning: implicit declaration of function `getifaddrs'
rmtcall.c:113: error: dereferencing pointer to incomplete type
rmtcall.c:114: error: dereferencing pointer to incomplete type
rmtcall.c:117: error: dereferencing pointer to incomplete type
rmtcall.c:118: error: dereferencing pointer to incomplete type
rmtcall.c:120: error: dereferencing pointer to incomplete type
rmtcall.c:123: error: dereferencing pointer to incomplete type
rmtcall.c:124: error: dereferencing pointer to incomplete type
make[3]: *** [rmtcall.o] Error 1

http://gzp.hu/tmp/nfs-utils-1.0.8/log.configure
http://gzp.hu/tmp/nfs-utils-1.0.8/log.make
http://gzp.hu/tmp/nfs-utils-1.0.8/config.log


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
