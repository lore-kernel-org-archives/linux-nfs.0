From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 12:24:18 -0500
Message-ID: <20090112172418.GC24322@fieldses.org>
References: <87zlhxy102.fsf@newsguy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
To: Harry P <reader-kFrNdAxtuftBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40541 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822AbZALRYV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 12:24:21 -0500
In-Reply-To: <87zlhxy102.fsf-kFrNdAxtuftBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 11, 2009 at 03:41:01PM -0600, Harry P wrote:
> NOTE: This is a repost of a message posted on gentoo.user list
> 
> I've apparently forgotten whatever little I may have known about
> setting up nfs from having used it long ago.
> 
> I found a brief help page on google that I used to get this far along
> at:
> http://linux-bsd-sharing.blogspot.com/2008/09/howto-setup-nfs-server-on-gentoo.html
> 
> Its very brief and has no debugging info.  
> 
> Also I see nothing about debugging in /etc/conf.d/nfs either.
> 
> After setting all nfs related kernel items and booting the kernel.
> (The setting are inlined toward the end of this message)
> Checking that mods appears to be installed and running.  Making sure
> portmapper is running.
> 
> Then when I try to start nfsd service it fails, producing these
> messages in sysklogd:
> 
> Jan [...] nfsd[29077]: nfssvc: Protocol not supported
> Jan [...' : RPC: failed to contact local rpcbind server (errno 5).

Hm, maybe it's the portmap version:

> 
> Only one of the nfssvc lines appear but the RPC line appears several
> times. 
> 
> I got the impression from google that nfssvc was related to nfs4 so
> may not mean too much ... but then I'm really not sure what it might
> mean.
> 
> I don't really know what info would be helpfull but have included
> output from emerge, rpcinfo, lsmod and related kernel settings:
> 
> Installed nfs related pkgs
>  [...]
> Sat Jan 10 18:30:11 2009 >>> net-libs/libnfsidmap-0.21-r1
> Sat Jan 10 18:30:30 2009 >>> net-nds/portmap-6.0
> Sat Jan 10 18:31:20 2009 >>> dev-libs/libevent-1.4.9
> Sat Jan 10 18:32:39 2009 >>> net-fs/nfs-utils-1.1.4
> 
> =====     *     =====     *     =====     *     =====
> 
> kernel:
> # grep 'NFS\|RPC' .config
> 
>   # CONFIG_AF_RXRPC is not set
>   CONFIG_NFS_FS=m
>   CONFIG_NFS_V3=y
>   CONFIG_NFS_V3_ACL=y
>   CONFIG_NFS_V4=y
>   CONFIG_NFSD=m
>   CONFIG_NFSD_V2_ACL=y
>   CONFIG_NFSD_V3=y
>   CONFIG_NFSD_V3_ACL=y
>   CONFIG_NFSD_V4=y
>   CONFIG_NFS_ACL_SUPPORT=m
>   CONFIG_NFS_COMMON=y
>   CONFIG_SUNRPC=m
>   CONFIG_SUNRPC_GSS=m
>   CONFIG_SUNRPC_REGISTER_V4=y

>From the config help test: "If you enable this option, you must run a
portmapper daemon that supports rpcbind protocol version 4."

Chuck, what's the minimum userland required to support this?

--b.

>   CONFIG_RPCSEC_GSS_KRB5=m
>   # CONFIG_RPCSEC_GSS_SPKM3 is not set
> 
> =====     *     =====     *     =====     *     =====
>  
> # rpcinfo -p localhost
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  34971  status
>     100024    1   tcp  43460  status
>     100005    1   udp  34365  mountd
>     100005    1   tcp  44349  mountd
>     100005    2   udp  34365  mountd
>     100005    2   tcp  44349  mountd
>     100005    3   udp  34365  mountd
>     100005    3   tcp  44349  mountd
> 
> =====     *     =====     *     =====     *     =====
>  
> lsmod
> 
> Module                  Size  Used by
> nfs                   206772  0 
> nfsd                  185008  9 
> lockd                  55160  2 nfs,nfsd
> nfs_acl                 2688  2 nfs,nfsd
> auth_rpcgss            28548  1 nfsd
> sunrpc                144584  9 nfs,nfsd,lockd,nfs_acl,auth_rpcgss
> exportfs                3456  1 nfsd
> fuse                   42268  0 
> usbhid                 13588  0 
> usbmouse                3712  0 
> usbkbd                  4992  0 
> floppy                 45348  0 
> pcspkr                  2176  0 
> i2c_i801                7952  0 
> r8169                  26500  0 
> i2c_core               17680  1 i2c_i801
> mii                     4224  1 r8169
> snd_intel8x0           25500  0 
> snd_ac97_codec         88352  1 snd_intel8x0
> ehci_hcd               28684  0 
> uhci_hcd               18444  0 
> ac97_bus                1536  1 snd_ac97_codec
> snd_pcm                48008  2 snd_intel8x0,snd_ac97_codec
> snd_timer              15364  1 snd_pcm
> snd                    34788  4 snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer
> usbcore               104760  6 usbhid,usbmouse,usbkbd,ehci_hcd,uhci_hcd
> snd_page_alloc          7304  2 snd_intel8x0,snd_pcm
> intel_agp              22588  1 
> agpgart                25520  1 intel_agp
> button                  5904  0 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
