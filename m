From: Sven Geggus <sven@gegg.us>
Subject: 2.4.21: NFS client Freeze
Date: Tue, 24 Jun 2003 12:12:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030624101227.GA21744@benzin.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from benzin.geggus.net ([213.146.112.23] ident=foobar)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UknP-0001AI-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 03:13:04 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi there,

After mounting an NFS-Volume exported from a Windows Machine
(Hummingbird-NFS Maestro Server) a simple ls of the mount point causes an
almost complete freeze of the system (ping does still work, but nothing
else).

This did work fine in 2.4.20 but does not work on 2.4.21 anymore!

Here is the debug output I produced using:

echo 3 >/proc/sys/sunrpc/rpc_debug
echo 3 >/proc/sys/sunrpc/nfs_debug

RPC:   24 call_start nfs3 proc 1 (sync)
RPC:   24 call_reserve
RPC:   24 reserved req df16d078 xid 81c60017
RPC:   24 xprt_reserve returns 0
RPC:   24 call_reserveresult (status 0)
RPC:   24 call_allocate (status 0)
RPC:   24 call_encode (status 0)
RPC:   24 call_transmit (status 0)
RPC:   24 xprt_transmit(81c60017)
RPC:   24 xprt_cwnd_limited cong = 0 cwnd = 512
RPC:      xprt_sendmsg(0) = 108
RPC:      udp_data_ready...
RPC:      udp_data_ready client df16d000
RPC:   24 received reply
RPC:      cong 256, cwnd was 512, now 512
RPC:   24 has input (112 bytes)
RPC:   24 xmit complete
RPC:   24 call_status (status 112)
RPC:   24 call_decode (status 112)
RPC:   24 call_decode result 0
RPC:   24 release request df16d078
RPC:      rpc_release_client(dfd6b480, 2)
NFS: refresh_inode(7/395120 ct=1 info=0x6)
RPC:   25 call_start nfs3 proc 4 (sync)
RPC:   25 call_reserve
RPC:   25 reserved req df16d078 xid 81c60018
RPC:   25 xprt_reserve returns 0
RPC:   25 call_reserveresult (status 0)
RPC:   25 call_allocate (status 0)
RPC:   25 call_encode (status 0)
RPC:   25 call_transmit (status 0)
RPC:   25 xprt_transmit(81c60018)
RPC:   25 xprt_cwnd_limited cong = 0 cwnd = 512
RPC:      xprt_sendmsg(0) = 112
RPC:   25 xmit complete
RPC:      udp_data_ready...
RPC:      udp_data_ready client df16d000
RPC:   25 received reply
RPC:      cong 256, cwnd was 512, now 512
RPC:   25 has input (36 bytes)
RPC:   25 call_status (status 36)
RPC:   25 call_decode (status 36)
RPC:   25 call_decode result 0
RPC:   25 release request df16d078
RPC:      rpc_release_client(dfd6b480, 2)
NFS: readdir_search_pagecache() searching for cookie 0
NFS: find_dirent_page() searching directory page 0
NFS: nfs_readdir_filler() reading cookie 0 into page 0.
RPC:   26 call_start nfs3 proc 16 (sync)
RPC:   26 call_reserve
RPC:   26 reserved req df16d078 xid 81c60019
RPC:   26 xprt_reserve returns 0
RPC:   26 call_reserveresult (status 0)
RPC:   26 call_allocate (status 0)
RPC:   26 call_encode (status 0)
RPC:   26 call_transmit (status 0)
RPC:   26 xprt_transmit(81c60019)
RPC:   26 xprt_cwnd_limited cong = 0 cwnd = 512
RPC:      xprt_sendmsg(0) = 128
RPC:   26 xmit complete
RPC:      udp_data_ready...
RPC:      udp_data_ready client df16d000
RPC:   26 received reply
RPC:      cong 256, cwnd was 512, now 512
RPC:   26 has input (760 bytes)
RPC:   26 call_status (status 760)
RPC:   26 call_decode (status 760)

Regards

Sven

-- 
.. this message has been created using an outdated OS (UNIX-like) with an 
outdated mail- or newsreader (text-only) :-P

/me is giggls@ircnet, http://sven.gegg.us/ on the Web



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
