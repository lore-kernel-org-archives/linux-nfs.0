From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RPC: Unable to allocate ...
Date: 24 Mar 2003 15:09:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadfksvor.fsf@charged.uio.no>
References: <3E7EDCCA.8060904@dotcom.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xSdr-00061d-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Mar 2003 06:09:35 -0800
To: myciel <myciel@dotcom.pl>
In-Reply-To: <3E7EDCCA.8060904@dotcom.pl>
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

>>>>> " " == myciel  <myciel@dotcom.pl> writes:

     > Hi ocasionally (once or twice daily) I get hundreds of warnings
     > during few seconds saying:

     > "RPC: Unable to allocate resbuf from cache!"

     > I've found in list archive suggestion to put more memory on
     > server, but my machine has already 1GB of ram. I run 2.4.18 +
     > nfsall patches, 2 nfs filesystems of size 620GB and 420GB on
     > top of reiserfs,

     >  80% filled with small files (average size 25kb) - any hints?

Just disable the warning. The above should be harmless, since the NFS
client will automatically retry.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
