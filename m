From: Rajesham Gajjela <rajeshamg@yahoo.com>
Subject: nfs over ipv6 support
Date: Thu, 13 Mar 2008 07:08:29 -0700 (PDT)
Message-ID: <956157.57545.qm@web30507.mail.mud.yahoo.com>
References: <1205414790-1710-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: aime.le-rouzic@bull.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org,
	gilles.quillard@bull.net
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web30507.mail.mud.yahoo.com ([68.142.200.120]:39730 "HELO
	web30507.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752409AbYCMOPK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2008 10:15:10 -0400
In-Reply-To: <1205414790-1710-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Did any body test nfs (v2 and v3) over ipv6 ?
do you guys claim "this feature suppose to work" ?

It did not work for me. Here are the details of
experiments I did (for me server and client is
same):
 
1) Kernel side : Linux-2.6.12-5 +
      linux-2.6.12-rc6-CITI_NFS4_ALL-1.dif +
      Chuck Lever Transport Patch
(http://oss.oracle.com/~cel/linux-2.6/2.6.12/release-notes.html)

2) User land (tools) side: libtirpc-0.1.7-1 + 
     rpcbind-0.1.4 + nfs-utils-1.1.1 + quota-3.12-5
(Ref:
http://nfsv4.bullopensource.org/patches/nfsv4_ipv6-2)

3) rpcbind suppose to recognize ipv6/ipv4 tcp/udp 
   protocols (after modifying /etc/netconfig). I did 
   softlink of /usr/bin/rpcbind to /sbin/portmap).
   Then did "service portmap restart".
   Then "service nfs restart". NFS services failed.

syslog messages:

Mar 13 19:32:20 DXi5500-12345 nfs: Starting NFS
services:  succeeded
Mar 13 19:32:20 DXi5500-12345 nfs: rpc.rquotad startup
succeeded
Mar 13 19:32:20 DXi5500-12345 kernel: RPC: transport
(2/17) not supported
Mar 13 19:32:20 DXi5500-12345 last message repeated 2
times
Mar 13 19:32:20 DXi5500-12345 nfsd[12453]: nfssvc:
Input/output error
Mar 13 19:32:20 DXi5500-12345 nfs: rpc.nfsd startup
failed
Mar 13 19:32:20 DXi5500-12345 nfs: rpc.mountd startup
succeeded
Mar 13 19:32:20 DXi5500-12345 rpc.idmapd: nfsdreopen:
Opening '/proc/net/rpc/nfs4.idtoname/channel' failed:
errno 2 (No such file or directory)
Mar 13 19:32:20 DXi5500-12345 rpc.idmapd: nfsdreopen:
Opening '/proc/net/rpc/nfs4.nametoid/channel' failed:
errno 2 (No such file or directory)
Mar 13 19:32:20 DXi5500-12345 rpcidmapd: rpc.idmapd
-SIGHUP succeeded



      ____________________________________________________________________________________
Never miss a thing.  Make Yahoo your home page. 
http://www.yahoo.com/r/hs
