From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: v3 client generates too many "access" requests
Date: Tue, 10 Dec 2002 03:38:07 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.40.0212100327350.20026-100000@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Istvan Marko <mi@imarko.dhs.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a.smtp-out.sonic.net ([208.201.224.38])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18LiiI-0002If-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Dec 2002 03:38:10 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
> In 2.4.x, the NFSv3 ACCESS call is not fully implemented: it lacks the
ability
> to cache results. For this reason it is only used to check for root
squashing
> and for those specific cases where the kernel tries to override the
standard
> UNIX mode permission checks.
>

Last week when I reported slowness on 2.4.20+NFS_ALL's TCP client you said
that it was "probably a consequence of the ACCESS patch". It seems like
the ACCESS patch should make the client run faster. Can you clarify a bit
under which conditions the client would run faster and which it would run
slower if the ACCESS patch is installed? In particular is it a benefit to
run the ACCESS patch if you are mounting without root_squash and
performing a lot of actions as the root (or perhaps any other) user? I'm
sure it depends on workload but perhaps there are some general guidelines.
Thanks!


andrew



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
