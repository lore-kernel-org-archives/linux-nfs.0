From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: 23 Aug 2003 10:28:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsekzcjnbt.fsf@charged.uio.no>
References: <200308231404.34087.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qcid-0003yB-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 11:02:32 -0700
To: Hans-Peter Jansen <hpj@urpla.net>
In-Reply-To: <200308231404.34087.hpj@urpla.net>
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

>>>>> " " == Hans-Peter Jansen <hpj@urpla.net> writes:

     > Hi, after kernel update all my (diskless) systems clutter up
     > the syslog with:

     > Aug 23 13:41:42 yogi kernel: nfs: server shrek not responding,

Does the following patch help?

Cheers,
  Trond

--- linux-2.4.22-up/net/sunrpc/timer.c.orig	2002-08-14 17:52:52.000000000 -0700
+++ linux-2.4.22-up/net/sunrpc/timer.c	2003-08-23 10:26:36.000000000 -0700
@@ -8,7 +8,7 @@
 
 #define RPC_RTO_MAX (60*HZ)
 #define RPC_RTO_INIT (HZ/5)
-#define RPC_RTO_MIN (2)
+#define RPC_RTO_MIN (HZ/10)
 
 void
 rpc_init_rtt(struct rpc_rtt *rt, long timeo)


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
