From: Christian Liem <liemcc@ousd.k12.ca.us>
Subject: Setting default block size on the server side
Date: 08 Jul 2002 12:11:36 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1026155497.8405.44.camel@fiona.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from paloalto-smrly2.gtei.net ([131.119.246.6])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Rezi-0007Um-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Jul 2002 13:20:26 -0700
Received: from firewall.ousd.k12.ca.us (firewall.ousd.k12.ca.us [198.94.127.6])
	by paloalto-smrly2.gtei.net (Postfix) with SMTP id DAB5C6F75
	for <nfs@lists.sourceforge.net>; Mon,  8 Jul 2002 20:20:24 +0000 (GMT)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi,

I'm wondering about how I can do this.  The NFS-HOWTO is a little vague
about the issue.  It says:

4096 bytes is the most common default, although for TCP-based mounts in
2.2 kernels, and for all mounts beginning with 2.4 kernels, the server
specifies the default block size.

After googling around the web and poking around kernel source, I can't
seem to find anything that relate to this.  So, where or how do I
specify it on the server?

help =)

P.S.:  I'm actually trying to boot an old Uniden n|c thin client.  The
BIOS boots by first doing a bootp request to get ip address and then
grabs a config file from the specified boot server.  The config file
points to the nfs export that it should mount as the root partition and
the kernel file name.  So far I've been able to get it to mount the nfs
volume.  When it tries to read the file, it ignores the nfs read reply
packets.  These thin clients originally boot off a BSD server.  And the
only difference I found between the two nfs servers is the default block
size.  The BSD nfsd sends out 8k blocks and the linux one sends out 4k
blocks.  If there are others who had experience with these n|c clients,
I'd like to hear about it too.

-chris



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
