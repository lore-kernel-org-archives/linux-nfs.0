From: Frank van Maarseveen <F.vanMaarseveen@inter.NL.net>
Subject: Re: Insane permissions problem :)
Date: Fri, 19 Jul 2002 01:13:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020719011355.B2781@iapetus.localdomain>
References: <20020717225841.GC4853@netlocal.com.br> <shsy9c9bcp6.fsf@charged.uio.no> <15670.39323.156232.887895@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Joel_Franco_Guzm=E1n?= <joel.franco@3WT.com.br>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from grootstal.nijmegen.internl.net ([217.149.192.7])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17VKTf-0006UV-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Jul 2002 16:14:31 -0700
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <15670.39323.156232.887895@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Thu, Jul 18, 2002 at 08:34:03PM +1000
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Thu, Jul 18, 2002 at 08:34:03PM +1000, Neil Brown wrote:
> 
> Nah.. the server just believes the groups in the RPC credential.
> The problem is that Joel is in more than 16 groups, and RPC only knows
> about the first 16.

Correct. A solution is to use my linux client side patch, see:

	http://web.inter.nl.net/users/fvm/

-- 
Frank


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
