From: Brian Kerr <kerrboy@gmail.com>
Subject: nfs stale directory listings
Date: Thu, 13 Oct 2005 13:40:02 -0400
Message-ID: <b83c9e30510131040v82885d2r407f5a12be93e30f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQ73w-0000IV-Jz
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 10:40:16 -0700
Received: from xproxy.gmail.com ([66.249.82.196])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EQ73v-0004PD-Df
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 10:40:16 -0700
Received: by xproxy.gmail.com with SMTP id i28so283596wxd
        for <nfs@lists.sourceforge.net>; Thu, 13 Oct 2005 10:40:02 -0700 (PDT)
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

Hi,

We have a mixed environment of several hundred RH boxes running
2.4.20+ and 2.6.11+ kernels that are mounting against netapps and
linux nfsd servers.

We have a problem where sometimes client machines will not see the
latest(newest) files that are created by one client in a particular
directory path until we cd /net/path&&touch foo&&rm -f foo.  After
doing this the problem goes away and everything works fine, but we
have to do this on multiple machines multiple times a day.

On solaris I know the DNLC directory cache is tunable - is this
tweakable on linux?  I've looked around but have not found a solution
to the problem.

This is all nfs v3 over TCP.

Thanks in advance,
Brian


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
