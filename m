From: Peter Staubach <staubach@redhat.com>
Subject: Re: Configuration for NFSv3 only?
Date: Mon, 25 Jul 2005 17:47:37 -0400
Message-ID: <42E55DF9.50609@redhat.com>
References: <20050725204047.82740.qmail@web33907.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxAqa-0004MN-Dq
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 14:50:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxAqX-0001mT-71
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 14:50:52 -0700
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20050725204047.82740.qmail@web33907.mail.mud.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Bill Johnstone wrote:

>Hello all.
>
>What I would like to do is configure my server and clients to use NFSv3
>only.  I'm running recent 2.6 kernels, e.g. 2.6.12 .  I have read the
>FAQ on nfs.sourceforge.net .
>
>My kernel on the server is configured for Providing NFS3 client and
>server support.  My kernel on the test client is configured for NFS3
>client support.
>
>My init script on the server is giving rpc.mountd the "-N 1 -N 2"
>command-line options.
>
>Running "rpcinfo -p" on the server gives:
>
>    100000    2   tcp    111  portmapper
>    100000    2   udp    111  portmapper
>    100024    1   udp  32768  status
>    100024    1   tcp  32769  status
>    100003    2   udp   2049  nfs
>    100003    3   udp   2049  nfs
>    100003    2   tcp   2049  nfs
>    100003    3   tcp   2049  nfs
>    100021    1   udp  32770  nlockmgr
>    100021    3   udp  32770  nlockmgr
>    100021    4   udp  32770  nlockmgr
>    100021    1   tcp  32770  nlockmgr
>    100021    3   tcp  32770  nlockmgr
>    100021    4   tcp  32770  nlockmgr
>    100005    3   udp    687  mountd
>    100005    3   tcp    690  mountd
>
>On the client, trying to perform a "mount -o vers=3 <server
>IP>:<exportname> <local mountpoint>" gives the error "NFSv3 not
>supported!" and the mount fails.  If I remove the options to
>rpc.mountd,   and do not specify "-o vers=3" on the client side, then
>mountd listens for protocol versions 1 and 2, and the mount succeeds.
>
>This leads me to the following questions:
>
>1. Should "rpcinfo -p" list a version 3 for portmapper in order for
>NFSv3 to be successfully used, or should portmapper only be at version
>2 even for the NFSv3 protocol?
>

The answer to this question is that the portmapper protocol is completely
separate from the NFS and related protocols such as nlockmgr and mountd.

There are newer versions of the protocol, 10000, which are now called 
rpcbind.

But, the short answer, is that portmapper, version 2, is fine for these 
purposes.

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
