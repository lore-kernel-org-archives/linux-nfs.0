From: petter.knutsen@cgi.no
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 17:22:58 +0200
Message-ID: <E1ESyjW-0000eX-TS@mail.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESyjZ-0003xx-VH
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 08:23:05 -0700
Received: from mail09.webhuset.no ([81.27.32.116] helo=mx.webhuset.no)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESyjW-0000eX-TS
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 08:23:05 -0700
To: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
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

> Note that this is not entirely accurate any more. Recent kernels will
> emulate flock() over NFS by using fcntl() locks.

I've gotten fcntl() to work, but it doesn't seem that flock() works between
clients. Do you know which kernel version implemented the emulation? Are we
talking about the latest 2.6.14 rc, or should a 2.6.x be sufficient? Also,
should this emulation be enough to make flock() work between clients?

Thanks for all your help.

--
Petter=


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
