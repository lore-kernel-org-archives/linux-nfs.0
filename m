From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Retransmissions over TCP ...
Date: 11 Sep 2003 18:42:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs7k4fhrqx.fsf@charged.uio.no>
References: <20030910200444.49715.qmail@web21104.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xa8s-0002LL-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 15:42:22 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19xa8r-0006GE-CC
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 15:42:21 -0700
To: Amey Inamdar <amey_inamdar@yahoo.com>
In-Reply-To: <20030910200444.49715.qmail@web21104.mail.yahoo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Amey Inamdar <amey_inamdar@yahoo.com> writes:

     > Is it because NFS server may drop the requests/connection at
     > its end?

That is correct... Neither NFSv2 nor NFSv3 offer any guarantee that
the server won't drop requests if resources are scarce.

For NFSv4, there is a special error to indicate that the server has
run out of resources, and so retransmission should only be necessary
if/when the TCP connection is broken.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
