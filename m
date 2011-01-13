Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:43977 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932424Ab1AMLtM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 06:49:12 -0500
From: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: Deepak SIKRI <deepak.sikri@st.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Armando VISCONTI <armando.visconti@st.com>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>
Date: Thu, 13 Jan 2011 12:48:51 +0100
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Message-ID: <4D2EE6A3.7010309@st.com>
References: <4D2EC133.7010607@st.com>
In-Reply-To: <4D2EC133.7010607@st.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Hi
>
> I am facing a problem related to nfs boot, while using the stmmac driver
> ported on 2.6.37 kernel. When we use a JFFS2 file system and mount the
> kernel,
> the network driver works fine.
>
> I have been following the mailing list and could find some issues with NFS
> on 2.6.37 but I am not too sure whether the kernel crash I am getting is
> related to that.
>
> The driver worked fine on 2.6.32 kernel, but while booting the 2.6.37
> kernel I get the following log messages:
>
Also no problem on my side with the Kernel 2.6.32 plus
the latest device driver from net-2.6.

Peppe

> stmmac: Rx Checksum Offload Engine supported
>         TX Checksum insertion supported
> IP-Config: Complete:
>      device=eth0, addr=192.168.1.10, mask=255.255.255.0,
> gw=255.255.255.255,
>      host=192.168.1.10, domain=, nis-domain=(none),
>      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
> VFS: Unable to mount root fs via NFS, trying floppy.
> VFS: Cannot open root device "nfs" or unknown-block(2,0)
> Please append a correct "root=" boot option; here are the available
> partitions:
> 1f00              64 mtdblock0  (driver?)
> 1f01             256 mtdblock1  (driver?)
> 1f02            2816 mtdblock2  (driver?)
> 1f03            5056 mtdblock3  (driver?)
> Kernel panic - not syncing: VFS: Unable to mount root fs on
> unknown-block(2,0)
> Backtrace:
> [<c00370f0>] (dump_backtrace+0x0/0x110) from [<c0037234>]
> (dump_stack+0x18/0x1c)
>  r7:c7b5b000 r6:00000000 r5:c7b5b015 r4:c04296b8
> [<c003721c>] (dump_stack+0x0/0x1c) from [<c004ebf8>] (panic+0x60/0x180)
> [<c004eb98>] (panic+0x0/0x180) from [<c0009114>]
> (mount_block_root+0x1d4/0x214)
>  r3:00000000 r2:00000001 r1:c782bf50 r0:c0394851
> [<c0008f40>] (mount_block_root+0x0/0x214) from [<c00091fc>]
> (mount_root+0xa8/0xc8)
> [<c0009154>] (mount_root+0x0/0xc8) from [<c0009388>]
> (prepare_namespace+0x16c/0x1d0)
>  r4:c04288c0
> [<c000921c>] (prepare_namespace+0x0/0x1d0) from [<c0008904>]
> (kernel_init+0x1cc/0x220)
>  r5:c0402048 r4:c0428860
> [<c0008738>] (kernel_init+0x0/0x220) from [<c00522a8>] (do_exit+0x0/0x5e0)
>  r7:00000013 r6:c00522a8 r5:c0008738 r4:00000000
> CPU0: stopping
> Backtrace:
> [<c00370f0>] (dump_backtrace+0x0/0x110) from [<c0037234>]
> (dump_stack+0x18/0x1c)
>  r7:c0405484 r6:00000406 r5:00000000 r4:00000000
> [<c003721c>] (dump_stack+0x0/0x1c) from [<c002d334>] (do_IPI+0xb4/0x124)
> [<c002d280>] (do_IPI+0x0/0x124) from [<c0032bb4>] (__irq_svc+0x34/0xc0)
> Exception stack(0xc03f3f50 to 0xc03f3f98)
> 3f40:                                     c0402048 00000000 c03f3f98
> 00000000
> 3f60: c03f2000 c04288dc c0027290 c0405484 000258e8 411fc091 00000000
> c03f3fa4
> 3f80: c03f3fa8 c03f3f98 c0034a24 c0034a28 60000013 ffffffff
>  r5:fc800100 r4:ffffffff
> [<c00349fc>] (default_idle+0x0/0x30) from [<c0034874>]
> (cpu_idle+0x80/0xc0)
> [<c00347f4>] (cpu_idle+0x0/0xc0) from [<c030602c>] (rest_init+0x64/0x7c)
>  r5:c04288dc r4:c04020b0
> [<c0305fc8>] (rest_init+0x0/0x7c) from [<c0008bd4>]
> (start_kernel+0x27c/0x2d8)
> [<c0008958>] (start_kernel+0x0/0x2d8) from [<00008038>] (0x8038)
>  r5:c0401fac r4:10c5387d
>
> I have tried the same over latest source picked from linus tree,
> 4162cf64973df51fc885825bc9ca4d055891c49f
> Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
>
> We are using version 3 of the NFs protocol in kernel's NFS client.
>
>
> Regards
> Deepak
> ST Microelectronics
>
> .
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
