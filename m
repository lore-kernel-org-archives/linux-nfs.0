From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20+NFS_ALL mount hanging, procs stuck in D state
Date: 16 Jan 2003 13:57:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshec9p7zs.fsf@charged.uio.no>
References: <Pine.LNX.4.40.0301151111380.23407-200000@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Z9aj-0000tY-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 04:57:53 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <Pine.LNX.4.40.0301151111380.23407-200000@bolt.sonic.net>
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

     > Although I am seeing a large number of "hw tcp v4 csum failed"
     > errors on this host (running e100 driver), I have also seen
     > smaller numbers of these errors on another host, same kernel,
     > running the tg3 network driver and not experiencing this
     > hang. Still, this looks like an NFS client problem.

I disagree: it looks like a hardware problem. From what I can see from
your RPC dump, the NFS client is treating what it is getting from the
server as if it were junk data. This is what I would expect to occur
if the server and client RPC streams are getting desynchronized due to
data corruption.

Try using the eepro100 driver and/or a different card.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
