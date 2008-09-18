From: Mike Eisler <email2mre-linuxv4@yahoo.com>
Subject: netid in the NFS mount command
Date: Thu, 18 Sep 2008 04:16:49 -0700 (PDT)
Message-ID: <288393.82711.qm@web38108.mail.mud.yahoo.com>
Reply-To: email2mre-linuxv4@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web38108.mail.mud.yahoo.com ([209.191.124.135]:31860 "HELO
	web38108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752789AbYIRLXb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 07:23:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

http://article.gmane.org/gmane.linux.nfs/16950 has Chuck Lever's patch to the nfs man page, which includes:


-The default value depends on whether
-.IR proto=udp
[...]
+.BI proto= netid
+The transport protocol used by the RPC client
+to transmit requests to the NFS server for this mount point.
+The value of
+.I netid
+can be either
+.B udp
 or
-.IR proto=tcp
-is in effect (see below).

After talking to Chuck yesterday, it appears that he is being literal:
the netid can only be either udp or tcp, and not also udp6 or tcp6, which
are the netids IETF defines (see RFC3530) for ONC RPC over UDP/IPv6
and TCP/IPv6. 

If proto= is going to mean transport protocol in the Linux mount 
command (as opposed to meaning a netid as it does in the Solaris mount
command), then please fix the man page to say that.

But I think there is value in following the Solaris convention
(which I established when I was at Sun in the 1990s working on the
Solaris NFS/TCP stack) because by specifying "proto=tcp6" in the
mount command, this can force the use of TCP over the IPv6 networking
protocol in cases where the same host name is resolvable to both an
IPv4 or IPv6 host address. Of course, one could edit nsswitch.conf and /etc/hosts or ipnodes to insert an IPv6-only host name, but that is cumbersome.

BTW, the terse netid stuff in RFC3530 is being codified in a separate
to-be-approved RFC. You can look at the internet draft at:
  http://tools.ietf.org/wg/nfsv4/draft-ietf-nfsv4-rpc-netid/

Netids for all the IETF transports that I am aware of are specified.
Additional ones can be added after the RFC is published by registering
with IANA via the process specified in the internet-draft.

Note that rdma and rdma6, corresponding to the rdma over TCP/IP and 
rdma over TCP/IPv6 protocols are among the netids. If people want
a netid for a raw, non-IP-based RDMA transport, that will have to be
registered with IANA.






