From: IHE Lists <ihelists@gmail.com>
Subject: Client Lockups
Date: Mon, 13 Dec 2004 00:08:45 -0600
Message-ID: <2d3ad3600412122208434463fc@mail.gmail.com>
Reply-To: IHE Lists <ihelists@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CdjOE-0004SS-7z
	for nfs@lists.sourceforge.net; Sun, 12 Dec 2004 22:08:59 -0800
Received: from rproxy.gmail.com ([64.233.170.204])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CdjOD-0003at-GN
	for nfs@lists.sourceforge.net; Sun, 12 Dec 2004 22:08:58 -0800
Received: by rproxy.gmail.com with SMTP id f1so348824rne
        for <nfs@lists.sourceforge.net>; Sun, 12 Dec 2004 22:08:55 -0800 (PST)
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

Here's the situation:

We have a multithreaded Java application that does a great deal of IO
over NFS. Almost daily, sometimes several times within a single day,
we get an application deadlock. The error in the kernel syslog message
is:

Dec 11 11:09:05 <hostname> kernel: RPC: error 512 connecting to server
<NFS server>

This error repeats numerous times.

The client mount options are:

rw,hard,intr,rsize=8192,wsize=8192,noatime,nfsvers=3,tcp,timeo=600,retrans=2

We have a deadlock monitor that attempts to restart the application by
first sending the process a "kill -9", then running the init.d script.
Of course, the threads stuck in the D state do not die, so the restart
fails. This cycle continues for almost 25 minutes (almost
consistently) before it succeeds.

I believe the eventual total deadlock is a problem in the Java virtual
machine, but I cannot determine what is causing the problem to begin
with. Other applications on the same system do not lockup accessing
other NFS mounts.

I've seen this problem on a custom kernel running 2.4.20 with the -aa1
patches and all the other applicable 2.4.20 patches from Trond and
Neil. I've also seen it occur on SLES8 kernels 2.4.21-241, 2.4.21-251,
and 2.4.21-261. Our systems are somewhat custom, so they are all
running nfs-utils 1.0.6, but the base is currently Red Hat 7.3.

I guess my primary question is: this a kernel problem, an nfs-utils
problem, or does the problem lie somewhere else?

Any help is greatly appreciated!

-Brian


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
