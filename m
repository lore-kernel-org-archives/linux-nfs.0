From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Insane permissions problem :)
Date: Thu, 18 Jul 2002 14:25:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15670.46011.421512.863931@charged.uio.no>
References: <20020717225841.GC4853@netlocal.com.br>
	<shsy9c9bcp6.fsf@charged.uio.no>
	<15670.39323.156232.887895@notabene.cse.unsw.edu.au>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Franco =?iso-8859-1?q?Guzm=E1n?= <joel.franco@3WT.com.br>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17VALv-0006mA-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Jul 2002 05:25:51 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15670.39323.156232.887895@notabene.cse.unsw.edu.au>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > Trond: is there a good reason why the client cannot make sure
     > the groupid of a file is sorted first when accessing that file?
     > It would solve 99% of these problems in a very simple way and
     > should (says he who hasn't looked at the code) not be too hard
     > to achieve.

It could be done, but doing so might break attempts to provide optimal
reordering of groups by hand. The latter is needed in order to solve
the remaining 1% of problems if, for instance, uid/gid mapping is
being used on the server.

I'm also reluctant to implement a solution that would involve giving
the NFS code intimate knowledge of the details of the RPC auth
handling. After all, the problem+solution you outline only effects
AUTH_SYS (a.k.a. AUTH_UNIX).

The workaround if one can't mess with /etc/groups in order to optimize
the user's group membership at login is to use the 'newgrp' command.




Note: I believe Frank van Marseveen once implemented a solution in
which membership of > 16 groups would result in the RPC code
reordering the groups and then retrying requests that fail with
EACCES. I don't know if he still maintains that code, but he did claim
that it worked for his case.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
