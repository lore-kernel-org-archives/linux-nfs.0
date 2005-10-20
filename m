From: Simon Kelley <srk@sanger.ac.uk>
Subject: NFS port use.
Date: Thu, 20 Oct 2005 17:35:40 +0100
Message-ID: <4357C75C.8050805@sanger.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESdOZ-0005Yq-Fj
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 09:35:59 -0700
Received: from smtp.sanger.ac.uk ([193.62.203.215])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESdOT-0003jI-V8
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 09:35:56 -0700
Received: from ssh.sanger.ac.uk ([193.62.203.54] helo=[127.0.0.1])
	by intmail1a.internal.sanger.ac.uk with esmtp (Exim 4.41)
	id 1ESdOH-00082P-4U
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 17:35:41 +0100
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

I'm trying to track down a problem with low ports being used by NFS and 
I've hit a brick wall. I don't think the problem lies in the NFS system, 
but the solution might, if I can understand what's going on.

Background.

I have a daemon starting at boot time which must bind tcp port 988 or 
bad things happen. Sometimes it fails with "address in use". By the time 
that the boot sequence is finished port 988 is free again.

I replaced the daemon with a wrapper like this:

#!/bin/sh
netstat -ap | grep 988 | logger
exec daemon.orig $*

And captured the following:

logger: tcp        0      0 bc-4-3-09.internal.:988 ecs2:sunrpc 
    TIME_WAIT  -

So NFS is implicated. Sure enough, the host is mounting many NFS 
filesystems on boot, including six or seven from an NFS server called ecs2.

BUT: this is kernel version 2.6.8, without the patch referenced by
http://sourceforge.net/mailarchive/forum.php?thread_id=7704466&forum_id=4930
so, unless I'm mistaken, it should be using ports in the range 1-800, 
and leaving 988 alone.

I verified that net/sunrpc/xprt.c contains
#define XPRT_MAX_RESVPORT       (800)


At this point I need help: my reasoning is wrong somewhere and I can't 
get any furher. Can anybody clarify things and tell me how to keep the 
NFS client subsystem away from port 988?


Cheers,

Simon.





-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
