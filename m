From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: 05 Oct 2002 01:46:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy99ddayi.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xc9I-0006L3-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 16:46:24 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Roger A Heflin <Heflin> writes:

     > I have noticed that the IO rates (writes) start slowly (about
     > 1.5MB/second) and slowly build up to a peak of 2.5MB/second
     > over several minutes, with the test averaging 2.32 MB/second
     > over a 2GB file write.  This is with a server with Gigabit
     > copper and the client with 100BT ethernet.  No packets are
     > being lost from what I can tell, on either the server or the
     > client, both machines are dual cpu with 2GB of ram and
     > otherwise unloaded.

Have you enabled CONFIG_HIGHMEM? If so, could you please try disabling
it.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
