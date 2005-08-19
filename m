From: Alex Deucher <alexdeucher@gmail.com>
Subject: Strange problems with Solaris NFS client
Date: Fri, 19 Aug 2005 11:49:30 -0400
Message-ID: <a728f9f905081908496136c6d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E697c-0006Hg-FV
	for nfs@lists.sourceforge.net; Fri, 19 Aug 2005 08:49:32 -0700
Received: from rproxy.gmail.com ([64.233.170.202])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E697b-0004e4-D2
	for nfs@lists.sourceforge.net; Fri, 19 Aug 2005 08:49:32 -0700
Received: by rproxy.gmail.com with SMTP id a41so568392rng
        for <nfs@lists.sourceforge.net>; Fri, 19 Aug 2005 08:49:30 -0700 (PDT)
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

I have a linux 2.6 kernel NFS server serving Solaris 8 NFS clients.=20
It's a read-only export.  What's odd is that everything starts out
fine when I mount the volume, but very quickly certain directories
become inaccessible (permission denied errors), sometimes they come
back and others become inaccessible.  remounting fixes the problem for
a bit then it happens again.  Solaris boxes is are SUN V240s  Linux
box is Debian, running 2.6.8.  This is the only box that seems to be
causing problems.  I'm running lots of other Linux boxes with no NFS
problems.

Any ideas?

Thanks,

Alex


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
