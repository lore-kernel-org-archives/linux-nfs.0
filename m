From: kanagesh <kanagesh@ncoretech.com>
Subject: unable to start nfs daemon
Date: Tue, 27 Aug 2002 15:12:01 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D6B4969.EAF7E90B@ncoretech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [164.164.42.6] (helo=gateway.ncoretech.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jcwa-0007Zo-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 02:47:31 -0700
Received: from ncoretech.com (IDENT:root@mail.ncoretech.com [192.168.1.3])
	by gateway.ncoretech.com (8.10.0/8.10.0) with ESMTP id g7R9lCE24727
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 15:17:12 +0530
Received: (from root@localhost)
	by ncoretech.com (8.10.0/8.10.0) id g7R9lCs22826
	for nfs@lists.sourceforge.net.VIRCHECK; Tue, 27 Aug 2002 15:17:12 +0530
Received: from ncoretech.com (ws130.ncoretech.com [192.168.1.130])
	by ncoretech.com (8.10.0/8.10.0) with ESMTP id g7R9lBl22734
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 15:17:11 +0530
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

I have linux (kernel 2.4.18) running on my embedded board
(StrongARM - SA1110 processor).

I am trying to mount a remote filesystem on the network from this board
(i.e) I need this board to behave as a NFS client.  I don't have an
ethernet
connection to this board, but I have it in the network through a PPP
connection
on the Serial port.  (I am able to ping, telnet and ftp into other
systems on the
network and vice-versa).

I had downloaded nfs-utils rpm for arm and I got it installed aswell.
But when I try to start the nfs daemon (on the command line, by typing
./rpc.nfsd ), it fails
with the following complaint:

nfssvc: Function not impelmented.

could anyone tell me what I need to do?  I've checked up with other
mailing list archives
and it looks as though this was a problem with the 2.2.x kernel
series......

1. My Kernel has been compiled with support for NFS (I can see an entry
for nfs in /proc/filesystems)

2. Do I need to run a portmap daemon in addition to nfsd?  (Sorry, I
don't have rpcinfo for the arm target
and hence am unable to provide info on the daemons running)

Regards,
Kanagesh





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
