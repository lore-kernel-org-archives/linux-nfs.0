From: Olaf Kirch <okir@suse.de>
Subject: 2.6.5-pre TCP connect problems
Date: Mon, 29 Mar 2004 15:50:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040329135042.GG2992@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7xA6-0002hN-Ml
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 05:50:46 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B7xA6-0005NW-BN
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 05:50:46 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 0A8ED39E94D
	for <nfs@lists.sourceforge.net>; Mon, 29 Mar 2004 15:50:43 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

I'm currently debugging a problem with TCP reconnects in 2.6.5-pre where
the TCP reconnect code got rewritten to use worker queues.  What happens
is that the NFS server drops the connection immediately and that state
change isn't propagated to the transport. The typical sequence of
events goes like this

Mar 29 15:44:00 e36 kernel: RPC: 28611 call_transmit (status 0)
Mar 29 15:44:00 e36 kernel: RPC: 28611 xprt_prepare_transmit
Mar 29 15:44:00 e36 kernel: RPC: 28611 call_status (status -107)
Mar 29 15:44:00 e36 kernel: RPC: 28611 call_bind xprt d42c4200 is not connected
Mar 29 15:44:00 e36 kernel: RPC: 28611 call_connect status 0
Mar 29 15:44:00 e36 kernel: RPC: 28611 xprt_connect xprt d42c4200 is not connected
Mar 29 15:44:00 e36 kernel: RPC:      disconnected transport d42c4200
Mar 29 15:44:00 e36 kernel: RPC:      xprt_create_socket(tcp 6)
Mar 29 15:44:00 e36 kernel: RPC: d42c4200  connect status 115 connected 0 sock state 2
Mar 29 15:44:00 e36 kernel: RPC:      tcp_state_change client d42c4200...
Mar 29 15:44:00 e36 kernel: RPC:      state 1 conn 0 dead 0 zapped 0
Mar 29 15:44:00 e36 kernel: RPC:      tcp_state_change client d42c4200...
Mar 29 15:44:00 e36 kernel: RPC:      state 8 conn 1 dead 0 zapped 0
Mar 29 15:44:00 e36 kernel: RPC:      disconnected transport d42c4200
Mar 29 15:44:00 e36 kernel: RPC:      tcp_data_ready...
Mar 29 15:44:15 e36 kernel: RPC: 28611 call_transmit (status 0)
Mar 29 15:44:15 e36 kernel: RPC: 28611 xprt_prepare_transmit
Mar 29 15:44:15 e36 kernel: RPC: 28611 call_status (status -107)

Does this sound familiar to anyone?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
