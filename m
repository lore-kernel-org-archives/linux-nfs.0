From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20+NFS_ALL mount hanging, procs stuck in D state
Date: Tue, 25 Feb 2003 18:13:49 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15963.42061.837369.881024@charged.uio.no>
References: <shshec9p7zs.fsf@charged.uio.no>
	<Pine.LNX.4.40.0301161226270.26507-100000@bolt.sonic.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18nieT-000365-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Feb 2003 09:13:58 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <Pine.LNX.4.40.0301161226270.26507-100000@bolt.sonic.net>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > According to subsequent messages in this thread, bad network
     > data can sometimes hang TCP mounts, but I got the same effect
     > on UDP. Which shouldn't happen, right? That would imply that
     > something isn't right in the linux NFS client.

That depends. The UDP client emulates the TCP congestion control (with
exponential backoff etc), so of course it can end up hanging. If
indeed your problem was a bad switch, then lost packets can quickly
end up slowing throughput to a trickle (which would appear to the user
as if the NFS client is hanging)

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
