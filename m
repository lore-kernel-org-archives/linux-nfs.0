From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RE: 2.4.19 NFSALL performance oddity
Date: 09 Oct 2002 00:42:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsu1jwblj0.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B91653BD1F@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z33X-0005Wf-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 15:42:23 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B91653BD1F@poexmb3.conoco.net>
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

     > Ok, I applied the new patch, it does not appear to have made
     > any difference in my setup and tests, it also does not appear
     > to break anything.  I am still analyzing the results, but not
     > finding anything obvious about what is going on.  2.2.19
     > appears to make alot better client to a 2.4.19 server than
     > 2.4.1[89][no patch/nfsall] does.  And 2.4.19 with no patches
     > appears to make a better server than 2.4.19 (for the writes)
     > with the NFS patches (using 2.2.19 as a client).

2.4.19-NFS_ALL doesn't touch the server code unless you are also
applying my hacked up version of Neil's experimental NFS-over-TCP
server patches on top of the 'stock NFS_ALL'.

The direct comparison with 2.2.19 is interesting, but only makes sense
if you can follow up and do a binary search of 2.4.x kernels (start
off by testing something like 2.4.9, say) in order to find out where
the performance drop occurs. I simply wouldn't know where to start
looking otherwise...

Note that on my own setups, I'm seeing performance numbers with
2.4.19-NFS_ALL clients against both Linux 2.4.19 servers and Sun
Solaris servers of the same order as your 2.2.19 numbers...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
