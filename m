From: Mathieu Chouquet-Stringer <mchouque@free.fr>
Subject: NFS mount point not responding with 2.6.16 on Alpha
Date: Thu, 27 Apr 2006 19:21:46 +0200
Message-ID: <20060427172146.GA2235@bigip.bigip.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZCzY-0004qN-Ks
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 13:21:36 -0700
Received: from smtp13.wanadoo.fr ([193.252.22.54])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FZCzY-00024c-26
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 13:21:36 -0700
Received: from smtp13.wanadoo.fr (mwinf1307 [172.22.144.37])
	by mwinf1305.wanadoo.fr (SMTP Server) with ESMTP id 35B241C079FA
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 19:24:33 +0200 (CEST)
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf1307.wanadoo.fr (SMTP Server) with ESMTP id 8B98370000BF
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 19:22:48 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

	Hello,

I've been using NFS for quite some time now and starting a couple of
months ago (can't recall exactly when), I've been having issues with one
of my servers.

The box in question is an Alpha (ev56 on a LX164 mb) - bar - running
knfsd on vanilla 2.6.16 (gentoo 1.6.14 - 2006.0) with /etc/exports
looking as follow:

/somemountpoint		someclients(rw,no_root_squash,async)

The problem can manifest itself in 2 (related) ways:
- I can mount somemountpoint fine on different linux boxes (ia32 or
  sparc64 based), manually or using autofs4, but after some time
  (something like 15-20 minutes, it doesn't matter wether the mount
  point is idle or not) the mountpoint will hang (ie trying to access
  it, by using df or whatever you can think of) and in the logs, I'll
  get the following:

Apr 27 18:32:15 foo kernel: nfs: server bar not responding, still trying

- or the initial mount command will hang with an identical message as
  above

In both cases, I can 'unhang' the whole mess by trying to mount
bar:/somemountpoint on server foo.  By "trying" I meant I don't even
have to mount it, just issuing a mount command looking like this:

mount bar:/somemountpoint /somedirthatdoesntevenexist

will unfreeze the process.


When I use autofs, I get more or less the same behaviour: automount just
hangs while trying to lstat64 the local mount point.  Running the above
mount command will correct the problem.

The interesting part is that with the same kernel version, it only
happens with the alpha being the server.

I've tried to pinpoint the problem but so far I've got admit I've been
quite unsucessfull (note that when it happens, all the services:
portmap, rpc, mountd, and so on are running).  So my first question
would be: where do I begin?  (tcpdump or raising nfsd/rpc debug level)?

FWIW I remember running tcpdump and I was seeing traffic originating
from the client going to the server and I wasn't getting any reply.
Sadly I haven't kept the traces, so I can't remember whether the traffic
was rpc based or not, bottom line take this with a grain of salt until I
produce a full tcpdump output.

Cheers,

-- 
Mathieu Chouquet-Stringer                         mchouque@free.fr



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
