From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Sun, 24 Aug 2003 02:12:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308240212.49348.bernd-schubert@web.de>
References: <200308231404.34087.hpj@urpla.net> <shsekzcjnbt.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qiV3-0001BU-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 17:12:54 -0700
Received: from [80.140.13.4] (helo=bathl.lan.fli4l)
	by smtp.web.de with asmtp (WEB.DE 4.99 #448)
	id 19qiUv-0004Xd-00
	for nfs@lists.sourceforge.net; Sun, 24 Aug 2003 02:12:45 +0200
To: nfs@lists.sourceforge.net
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

On Saturday 23 August 2003 19:28, Trond Myklebust wrote:
> >>>>> " " == Hans-Peter Jansen <hpj@urpla.net> writes:
>      > Hi, after kernel update all my (diskless) systems clutter up
>      > the syslog with:
>      >
>      > Aug 23 13:41:42 yogi kernel: nfs: server shrek not responding,
>
> Does the following patch help?
>
> Cheers,
>   Trond
>
> --- linux-2.4.22-up/net/sunrpc/timer.c.orig	2002-08-14 17:52:52.000000000
> -0700 +++ linux-2.4.22-up/net/sunrpc/timer.c	2003-08-23 10:26:36.000000000
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


Hello,

I also just had this problem with 2.4.22-rc2 and your patch is fixing it.

Thanks,
	Bernd



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
