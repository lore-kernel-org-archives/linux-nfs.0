From: Hans-Peter Jansen <hpj@urpla.net>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Tue, 26 Aug 2003 23:28:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308262328.09975.hpj@urpla.net>
References: <200308231404.34087.hpj@urpla.net> <shsekzcjnbt.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>,
	Bernd Schubert <bernd-schubert@web.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19rlNv-0003m7-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Aug 2003 14:29:51 -0700
Received: from moutng.kundenserver.de ([212.227.126.189])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19rlNu-0008QS-T7
	for nfs@lists.sourceforge.net; Tue, 26 Aug 2003 14:29:51 -0700
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

Hi Trond,

sorry 'bout the huge delay, but let me acknoledge: perfect cut.

Many thanks.

Since it's very late in 2.4.22 and crucial for all NFS users, I hope, 
it's fine to CC you, Marcelo: if you didn't noticed already, I highly 
recommend including this fix before 2.4.22-final (at least it hasn't 
found its way into your tree until now...). Be prepared about many 
more of these requests, if you don't ;-).

if (Tronds_fault || !Tronds_fault)	/* silly test */
   Tronds_heroscore += 100;

Pete

On Saturday 23 August 2003 19:28, Trond Myklebust wrote:
> >>>>> " " == Hans-Peter Jansen <hpj@urpla.net> writes:
>      > Hi, after kernel update all my (diskless) systems clutter up
>      > the syslog with:
>      >
>      > Aug 23 13:41:42 yogi kernel: nfs: server shrek not
>      > responding,
>
> Does the following patch help?
>
> Cheers,
>   Trond
>
> --- linux-2.4.22-up/net/sunrpc/timer.c.orig	2002-08-14
> 17:52:52.000000000 -0700 +++
> linux-2.4.22-up/net/sunrpc/timer.c	2003-08-23 10:26:36.000000000
> -0700 @@ -8,7 +8,7 @@
>
>  #define RPC_RTO_MAX (60*HZ)
>  #define RPC_RTO_INIT (HZ/5)
> -#define RPC_RTO_MIN (2)
> +#define RPC_RTO_MIN (HZ/10)
>
>  void
>  rpc_init_rtt(struct rpc_rtt *rt, long timeo)
>



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
