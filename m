From: Matthew Mitchell <matthew@geodev.com>
Subject: Re: More about nfsd/lockd hang in 2.4.20+NFS_ALL
Date: Fri, 13 Jun 2003 11:19:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EE9F97C.9070006@geodev.com>
References: <3EE9D5BB.6040600@geodev.com> <shsd6hikmgi.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[y6OfgAnUtbyH/99iJWcNOGRFCc4CHegn])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QrKY-00017i-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 09:23:10 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsd6hikmgi.fsf@charged.uio.no>
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

Trond Myklebust wrote:
>>>>>>" " == Matthew Mitchell <matthew@geodev.com> writes:
> 
> 
>      > The code looks like this:
> 
>      >          if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
>      >           || ntohs(saddr.sin_port) >= 1024) {
>      >                  printk(KERN_WARNING
>      >                          "lockd: rejected NSM callback from
>      >                          %08x:%d\n",
>      >                          ntohl(rqstp->rq_addr.sin_addr.s_addr),
>      >                          ntohs(rqstp->rq_addr.sin_port));
>      >                  return rpc_system_err;
>      >          }
> 
>      > In this case, though, the rq_addr.sin_addr.s_addr is that of
>      > loopback, as it says in the message (7f000001 => 127.0.0.1).
>      > It would appear that this is a lock notify that's supposed to
>      > be called when a client reconnects to a server, but it thinks
>      > it's being called with some impossible values.
> 
> It's just saying that the kernel expects rpc.statd to contact it using
> a reserved port when notifying it about a reboot of one of the remote
> servers.
> 
> Most rpc.statd daemons today run setuid some unprivileged
> user. Perhaps this is causing bindresvport() to fail?

rpc.statd in this case is running as an unprivileged user, yes.  So 
lockd will not allow a local statd to talk to it unless it is running on 
a privileged port?  That seems to be what is going on in the 
conditional.  Next question is -- why?

Even assuming there is a good reason, why might it cause the whole nfs 
system to hang?  I'm guessing statd or somewhere in the rpc layer isn't 
expecting this to fail, but I have no idea where to even start looking.

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
