From: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
Subject: Re: [PATCH] kNFSd - 4 of 6 - Make sure nfs/tcp socket only gets
 closed once.
Date: Thu, 4 Sep 2003 15:53:09 -0300 (BRT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309041553000.2521-100000@logos.cnet>
References: <Pine.LNX.4.44.0309040952040.2616-100000@logos.cnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NeilBrown <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19uzDA-0003lO-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 11:52:04 -0700
Received: from mikonos.cyclades.com.br ([200.230.227.67] helo=firewall.cyclades.com.br)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19uzD4-0002Ql-NU
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 11:51:58 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
In-Reply-To: <Pine.LNX.4.44.0309040952040.2616-100000@logos.cnet>
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



On Thu, 4 Sep 2003, Marcelo Tosatti wrote:

> 
> 
> On Thu, 4 Sep 2003, NeilBrown wrote:
> 
> > 
> > It is possible for svc_delete_socket to be called multiple times,
> > which can cause problems.  This patch uses SK_DEAD to make sure it
> > only has any effect the first time, and uses SK_DEAD in a few other
> > places to make sure nothing is done on a deleted socket.
> 
> Can you please send me this patch attached instead inlined? Its not
> applying correctly due to some issue in email transport.

Nevermind, it was a local problem.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
