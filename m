From: "Lorn Kay" <lorn_kay@hotmail.com>
Subject: NFS as a Cluster File System.
Date: Thu, 09 Jan 2003 19:39:50 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f112.law11.hotmail.com ([64.4.17.112] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WiY0-0000rr-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 11:41:00 -0800
To: nfs@lists.sourceforge.net, linux-ha@muc.de
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


Is NFS a viable CFS? (I'm cross posting this due to a discussion on the the 
linux-ha list recently.)

NFS has a bad reputation probably due to (at least) the following:

	It has been used in networking environments where different server hardware 
configurations (NICS, drivers, etc.) running different operating systems 
have connected to each other (in many-to-many configurations).

	It “grew up” on networks that were perhaps unstable, or immature 
(“Someone’s kicked the token ring coax cable laying on the floor again”) 
long before switches were common place, and the network was loaded down with 
all kinds of network traffic.

	It wasn’t understood very well. Since the default mount options worked, 
system administrators often didn’t fully understand the ramifications of 
their NFS client mount option choices.

	It relied on UDP, which is susceptible to huge retransmission efforts on 
noisy or lossy networks.

	NFS was used over many-hop WAN connections.

	NFS servers were often used for many other tasks, not just NFS.


A cluster configuration, however, offers several advantages over the typical 
NFS configuration:

	All NFS clients (the cluster nodes) run the same operating system (Linux).

	All clients run the same version of NFS and the kernel.

	All clients use the same network tuned configuration.

	A physical network can be dedicated to NFS. (Using a high quality switch, 
with short data-center-only cable runs.)

	All clients connect to one NFS server.

	The NFS server is a high-quality dedicated machine (Net App, EMC, etc.)

	Only one mount point need be used with one set of mount options.

	Linux clients can use TCP instead of UDP.

Except for the vagaries of the load placed on the cluster nodes, this sounds 
like a test lab environment. If NFS can’t work in this environment where 
will it ever work?

--K






_________________________________________________________________
STOP MORE SPAM with the new MSN 8 and get 2 months FREE* 
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
