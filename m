From: Matt C <wago@phlinux.com>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Thu, 4 Sep 2003 11:32:29 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309041128520.5868-100000@fubar.phlinux.com>
References: <shsekzcjnbt.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19uyvA-0001g3-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 11:33:28 -0700
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19uyv4-0007RP-IG
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 11:33:22 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsekzcjnbt.fsf@charged.uio.no>
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

Hi Trond-

I applied this patch to one of my clients, and it seems to have helped. 
However, I'm still getting a lot of the:

server x not responding, still trying
server x OK
server x not responding, still trying
server x OK

when the server is heavily loaded. what values would be reasonable for the 
#defines below in order to increase this timeout significantly? I tried 
changing RPC_RTO_MIN to (HZ/5) and RPC_RTO_INIT to (HZ/2), but that didn't 
seem to make a big difference. I'm having a hard time understanding the 
rpc_update_rtt() function.

thanks!

-matt



On 23 Aug 2003, Trond Myklebust wrote:

> >>>>> " " == Hans-Peter Jansen <hpj@urpla.net> writes:
> 
>      > Hi, after kernel update all my (diskless) systems clutter up
>      > the syslog with:
> 
>      > Aug 23 13:41:42 yogi kernel: nfs: server shrek not responding,
> 
> Does the following patch help?
> 
> Cheers,
>   Trond
> 
> --- linux-2.4.22-up/net/sunrpc/timer.c.orig	2002-08-14 17:52:52.000000000 -0700
> +++ linux-2.4.22-up/net/sunrpc/timer.c	2003-08-23 10:26:36.000000000 -0700
> @@ -8,7 +8,7 @@
>  
>  #define RPC_RTO_MAX (60*HZ)
>  #define RPC_RTO_INIT (HZ/5)
> -#define RPC_RTO_MIN (2)
> +#define RPC_RTO_MIN (HZ/10)
>  
>  void
>  rpc_init_rtt(struct rpc_rtt *rt, long timeo)
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: VM Ware
> With VMware you can run multiple operating systems on a single machine.
> WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
> at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
