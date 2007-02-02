From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 14] knfsd: Preparation for IPv6 support in NFS server.
Date: Fri, 2 Feb 2007 15:39:36 +1100
Message-ID: <20070202153531.18622.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965239AbXBBEkG@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Andrew,
 could you please remove

knfsd-sunrpc-update-internal-api-separate-pmap-register-and-temp-sockets.patch
knfsd-sunrpc-allow-creating-an-rpc-service-without-registering-with-portmapper.patch
knfsd-sunrpc-cache-remote-peers-address-in-svc_sock.patch
knfsd-sunrpc-use-sockaddr_storage-to-store-address-in-svc_deferred_req.patch
knfsd-sunrpc-add-a-function-to-format-the-address-in-an-svc_rqst-for-printing.patch

 and 

#knfsd-sunrpc-provide-room-in-svc_rqst-for-larger-addresses.patch
#knfsd-sunrpc-make-rq_daddr-field-address-version-independent.patch
#knfsd-sunrpc-teach-svc_sendto-to-deal-with-ipv6-addresses.patch
#knfsd-sunrpc-add-a-generic-function-to-see-if-the-peer-uses-a-secure-port.patch
#knfsd-sunrpc-support-ipv6-addresses-in-svc_tcp_accept.patch
#knfsd-sunrpc-support-ipv6-addresses-in-rpc-servers-udp-receive-path.patch
#knfsd-sunrpc-fix-up-svc_create_socket-to-take-a-sockaddr-struct-length.patch

and include the following 14 patches instead?
They are mostly from Chuck Level and make preparating for IPv6 support
in the NFS server.
They are *not* for 2.6.20, but should be ok for .21.

Thanks,
NeilBrown


 [PATCH 001 of 14] knfsd: SUNRPC: update internal API: separate pmap register and temp sockets
 [PATCH 002 of 14] knfsd: SUNRPC: allow creating an RPC service without registering with portmapper
 [PATCH 003 of 14] knfsd: SUNRPC: aplit svc_sock_enqueue out of svc_setup_socket.
 [PATCH 004 of 14] knfsd: SUNRPC: Cache remote peer's address in svc_sock.
 [PATCH 005 of 14] knfsd: SUNRPC: Don't set msg_name and msg_namelen when calling sock_recvmsg
 [PATCH 006 of 14] knfsd: SUNRPC: Add a function to format the address in an svc_rqst for printing
 [PATCH 007 of 14] knfsd: SUNRPC: Use sockaddr_storage to store address in svc_deferred_req
 [PATCH 008 of 14] knfsd: SUNRPC: Provide room in svc_rqst for larger addresses
 [PATCH 009 of 14] knfsd: SUNRPC: Make rq_daddr field address-version independent
 [PATCH 010 of 14] knfsd: SUNRPC: teach svc_sendto() to deal with IPv6 addresses
 [PATCH 011 of 14] knfsd: SUNRPC: add a "generic" function to see if the peer uses a secure port.
 [PATCH 012 of 14] knfsd: SUNRPC: Support IPv6 addresses in svc_tcp_accept
 [PATCH 013 of 14] knfsd: SUNRPC: support IPv6 addresses in RPC server's UDP receive path.
 [PATCH 014 of 14] knfsd: SUNRPC: fix up svc_create_socket() to take a sockaddr struct + length
