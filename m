From: redfuture <redfuture.dlut@gmail.com>
Subject: Is this a nfs bug?
Date: Mon, 24 Sep 2007 08:00:50 +0000
Message-ID: <92d9a9f20709240100i32c6ec3yee82bf646936391b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, redfuture.dlut@gmail.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZis3-00032L-Fw
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 01:00:47 -0700
Received: from qb-out-0506.google.com ([72.14.204.231])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZis8-0000ta-Bh
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 01:00:52 -0700
Received: by qb-out-0506.google.com with SMTP id c8so1240371qbc
	for <nfs@lists.sourceforge.net>; Mon, 24 Sep 2007 01:00:51 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,

I found a problem like that,ls -l command hang (from another term of
the same client)when copying a large from a nfs client to nfs server
.It returns only after the copy completed or aborted.

And this problem only occurs on higher version nfs clients.

When using lower version,for example RHEL4(nfs-utils-1.0.6-80.EL4 )
doesn't have this problem.

Is this problem a bug?

Thank you!

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
