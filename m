From: "Roger Heflin" <rheflin@atipa.com>
Subject: NFS issue files and various errors
Date: Thu, 9 Sep 2004 16:11:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EXCHG2003BBsQwY6YHk00000021@EXCHG2003.microtech-ks.com>
References: <0CF6F73B3B779D43B160B85FD0CC2D37035C546D@xch-sw-07.sw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5WCN-0002Hs-Ej
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 14:11:19 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5WCK-0002qY-EQ
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 14:11:18 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <0CF6F73B3B779D43B160B85FD0CC2D37035C546D@xch-sw-07.sw.nos.boeing.com>
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

I have two customers that are having some odd nfs issues.   Both clusters
and
all components are identical (in terms of network and machine hardware,
network
configuration varies slightly depending on the site).   The cluster sizes
are
each in excess of 200 nodes.   Both clusters are physically (by several
hundred
miles) and logically separated such that one cannot be affecting the other.

networking hardware is identical and is a non-blocking Gigabit cisco 6509
switch, which is used to connect all of the machines together.

The messages that they are getting on the nfs servers are:

kernel: rpc-src/tcp: nfsd: sent only -107 bytes of ### - shutting down
socket

The have also seen this message on at least one of the nfs clients:
RPC: tcp_data_ready socket info not found!

The kernel is 2.4.21-15.0.3 (Redhat 3.0 WS update 2), using tcp and the
kernel 
adjustments needed to do 32k read/write size.    The servers and the clients
are all running the same kernel and all of the same software, there are a
mixture of IA64 and I386 machines, the nfs servers are I386, and all of the
clients are IA64's.

I have limited amount of adjustments that I can suggest, I know suggesting
the latest kernel with the latest NFS patches is out (I suggested running 
that on the initial build a long time ago), though adjusting various 
parameters (either in proc or the src/header files) should not be an issue.

/proc/mounts confirms the 32k read/write, and that tcp is being used.

There are some other odd things happening, the admins and users indicate
that
they have had several instances of editing an existing file and then saving
the 
file and that file not being there after they exit and save in the editor. 

They are not currently running noac I have told them to run noac as they
have
a couple of other symptons that noac will definitely fix (files created on
one node don't show up on other nodes for a while).

                         Roger




-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
