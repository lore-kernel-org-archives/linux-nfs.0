From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd: couldn't create RPC handle for
Date: Thu, 27 Apr 2006 10:40:27 -0400
Message-ID: <1146148827.8142.33.camel@lade.trondhjem.org>
References: <215ff4410604270204x3e7cf525u8d019e4d1b1ac9d0@mail.gmail.com>
	 <1146147031.8142.3.camel@lade.trondhjem.org>
	 <215ff4410604270730m244dad1bhbba2e5fb7d4946a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZ7fo-000880-Mx
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 07:40:52 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FZ7fn-0005hz-Bl
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 07:40:52 -0700
To: Chris Fanning <christopher.fanning@gmail.com>
In-Reply-To: <215ff4410604270730m244dad1bhbba2e5fb7d4946a5@mail.gmail.com>
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

On Thu, 2006-04-27 at 16:30 +0200, Chris Fanning wrote:
> Hi Trond,
> 
> Thanks for getting back.
> 
> On the server
> ps -ef|grep lock
> root        16    11  0 13:14 ?        00:00:00 [kblockd/0]
> root        17    11  0 13:14 ?        00:00:00 [kblockd/1]
> root      6132  4154  0 16:27 pts/0    00:00:00 grep lock
> 
> netstat -ap | grep 32768
> nothing
> 
> On the client to the server
> rpcinfo -u 192.168.172.30 100021
> rpcinfo: RPC: Program not registered
> program 100021 is not available
> 
> Looks like nlockmgr isn't running on the server. right?
> Where does that leave me?
> Perhaps I left something out when I compiled the kernel?

Are you running with the user space NFS server perhaps? If you need
locking support, then you have to run the kernel NFS server.

Cheers,
 Trond



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
