From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: filetimes after creat()
Date: Sun, 30 Sep 2007 10:47:08 -0400
Message-ID: <1191163628.6705.2.camel@heimdal.trondhjem.org>
References: <f36b08ee0709300356o2256a044lbf518034a303138@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Yakov Lerner <iler.ml@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ic04n-0004fH-NC
	for nfs@lists.sourceforge.net; Sun, 30 Sep 2007 07:47:21 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ic04r-0007ob-I5
	for nfs@lists.sourceforge.net; Sun, 30 Sep 2007 07:47:26 -0700
In-Reply-To: <f36b08ee0709300356o2256a044lbf518034a303138@mail.gmail.com>
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

On Sun, 2007-09-30 at 12:56 +0200, Yakov Lerner wrote:
> Assume the GMT time on server != GMT time on the client.
> I do creat() then stat(). Which filetimes I am supposed to see:
> server time or client time ? 

Server time.

> Is the answer same for atime, mtime, and ctime ?

Yes.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
