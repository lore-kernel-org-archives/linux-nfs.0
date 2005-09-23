From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs-utils 2 of 10 - Incorporate some clean up
	code from Ulrich Drepper
Date: Fri, 23 Sep 2005 11:52:58 -0400
Message-ID: <1127490778.8328.6.camel@lade.trondhjem.org>
References: <433414D0.8030905@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIpra-0000VW-82
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 08:53:26 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIprU-0001Zp-PN
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 08:53:26 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <433414D0.8030905@RedHat.com>
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

Hmm... There seems to be a lot of duplicated code snippets here. Things
like

	DIR *dir = opendir("/proc/self/fd");
	if (dir != NULL) {
		int dfd = dirfd(dir);
		struct dirent *d;

		while ((d = readdir(dir)) != NULL) {
			char *endp;
			long n = strtol(d->d_name, &endp, 10);
			if (*endp == '\0' && n > 2 && n != dfd)
				(void) close(n);
		}
		closedir(dir);
	} else {
		int fd = sysconf (_SC_OPEN_MAX);
		while (--fd > 2)
			(void) close(fd);
	}

 Why not clean that up further by putting it into a simple library
function that takes an argument consisting of the pipes you do not want
it to close?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
