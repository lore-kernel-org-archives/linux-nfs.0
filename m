From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: More about nfsd/lockd hang in 2.4.20+NFS_ALL
Date: 13 Jun 2003 08:48:29 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6hikmgi.fsf@charged.uio.no>
References: <3EE9D5BB.6040600@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QqnE-00035Y-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 08:48:44 -0700
To: Matthew Mitchell <matthew@geodev.com>
In-Reply-To: <3EE9D5BB.6040600@geodev.com>
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

>>>>> " " == Matthew Mitchell <matthew@geodev.com> writes:

     > The code looks like this:

     >          if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
     >           || ntohs(saddr.sin_port) >= 1024) {
     >                  printk(KERN_WARNING
     >                          "lockd: rejected NSM callback from
     >                          %08x:%d\n",
     >                          ntohl(rqstp->rq_addr.sin_addr.s_addr),
     >                          ntohs(rqstp->rq_addr.sin_port));
     >                  return rpc_system_err;
     >          }

     > In this case, though, the rq_addr.sin_addr.s_addr is that of
     > loopback, as it says in the message (7f000001 => 127.0.0.1).
     > It would appear that this is a lock notify that's supposed to
     > be called when a client reconnects to a server, but it thinks
     > it's being called with some impossible values.

It's just saying that the kernel expects rpc.statd to contact it using
a reserved port when notifying it about a reboot of one of the remote
servers.

Most rpc.statd daemons today run setuid some unprivileged
user. Perhaps this is causing bindresvport() to fail?

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
