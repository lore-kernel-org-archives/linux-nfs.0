From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20rc1 NFS V3 UDP client problems
Date: 14 Nov 2002 20:47:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptt83pct.fsf@helicity.uio.no>
References: <3DD3DF5F.854AD688@amis.com> <3DD3E796.46E4F4AC@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CPy2-0006Wb-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 11:47:58 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3DD3E796.46E4F4AC@amis.com>
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

>>>>> " " == Eric Whiting <ewhiting@amis.com> writes:

     > I disabled jumbo frames and I'm seeing 70M/s reads (with a
     > clean cache)..

     > There must be a UDP or NFS client problem with the 9000 mtu
     > packets.

NFS neither knows nor cares what the MTU is: all it knows is that it
has a socket. I've suspected a bug in the UDP layer for a long time as
you are far from being the first person to report this problem when
enabling jumbo frames.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
