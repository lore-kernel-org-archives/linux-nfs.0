From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	server 192.168.0.1 with error
	121
Date: Mon, 17 Sep 2007 13:07:41 -0400
Message-ID: <1190048861.6700.105.camel@heimdal.trondhjem.org>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: jonas@websystem.se
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXK4a-0005PQ-Sr
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 10:07:51 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IXK4d-0007AF-Fe
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 10:07:53 -0700
In-Reply-To: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
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

On Sun, 2007-09-16 at 19:45 +0200, Jonas Jonsson wrote:

> Then the ls process hangs and the syslog starts to flodd with
> 
> Error: state recovery failed on NFSv4 server 192.168.0.1 with error 121

Error 121 is EREMOTEIO. That basically means that the server is sick and
there is little the client can do other than retry in the hope that it
eventually gets better.

What kernel are you using on the server?

> Error: state recovery failed on NFSv4 server 192.168.0.1 with error 2

ENOENT. That means that a file you were reading on the server has
disappeared while the server was incommunicado.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
