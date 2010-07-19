From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs]ds ip
Date: Mon, 19 Jul 2010 10:38:01 +0300
Message-ID: <4C4400D9.90101@panasas.com>
References: <AANLkTilJTogMkslFT-bGoOJYgGSznHnpi75e6IeCuWzC@mail.gmail.com>	<4C3C2481.1090708@panasas.com> <AANLkTilyAgrY6Sa07ef1QmUhV1OkeKSMug45LwBEeCMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: quanli gui <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32625 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755250Ab0GSHiG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jul 2010 03:38:06 -0400
In-Reply-To: <AANLkTilyAgrY6Sa07ef1QmUhV1OkeKSMug45LwBEeCMg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Gui, please keep the nfs list on the Cc so that others may help and/or
benefit in any other way from our discussion :)

To understand more about your problem we'll need a network dump
on the MDS side showing the communication between the client and the MDS
and probably some more information.

Have you installed the latest nfs utils from below?
git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git

What's your spnfs configuration?

What's in your /etc/exports file?

What are the mount option on the client side?

Can please run tcpdump as root on the MDS to capture the traffic:
# tcpdump -s 0 -w /tmp/nfs.pcap host <client_address>

Also, let's get the debug info from both client and server:

on the server side:
# echo 32767 > /proc/sys/sunrpc/nfsd_debug

on the client side:
# echo 32767 > /proc/sys/sunrpc/nfs_debug

and then mount the mds and run a simple command like
# date > <your_mount_point>/foo

Thanks,

Benny

On Jul. 13, 2010, 12:59 +0300, quanli gui <gqlxj1987@gmail.com> wrote:
> But the MDS that we use has only one fucntion. The data eventually store
> in the DS, but the data has been found in the functions in the MDS.
> for example, I dprintk some message in write_one() in the spnfs_ops.c.
> static int
> write_one(struct inode *inode, loff_t offset, size_t len, char *buf,
>  struct file **filp)
> {
> loff_t bufoffset = 0, soffset, pos, snum, soff, tmp;
> size_t iolen;
> int completed = 0, ds, err;
> 
>        dprintk("buf   %s\n",buf);
> 
> while (len > 0) {
> tmp = offset;
> soff = do_div(tmp, spnfs_config->stripe_size);
> snum = tmp;
> ds = do_div(tmp, spnfs_config->num_ds);
> if (spnfs_config->dense_striping == 0)
> soffset = offset;
> else {
> tmp = snum;
> do_div(tmp, spnfs_config->num_ds);
> soffset = tmp * spnfs_config->stripe_size + soff;
> }
> if (len < spnfs_config->stripe_size - soff)
> iolen = len;
> else
> iolen = spnfs_config->stripe_size - soff;
> 
> pos = soffset;
> err = vfs_write(filp[ds], buf + bufoffset, iolen, &pos);
> if (err < 0)
> return -EIO;
> filp[ds]->f_pos = pos;
> iolen = err;
> completed += iolen;
> len -= iolen;
> offset += iolen;
> bufoffset += iolen;
> }
> 
> return completed;
> }
> 
> I cp a file whose name is install.log to /mnt/nfs. The message shows that 
> buf   Installing m17n-db-1.5.3-1.fc10.noarch
> <4>warning: m17n-db-1.5.3-1.fc10: Header V3 DSA signature: NOKEY, key ID
> 4ebfc273
> <4>Installing setup-2.7.4-1.fc10.noarch
> <4>Installing filesystem-2.4.19-1.fc10.i386
> <4>Installing xml-common-0.6.3-26.fc10.noarch
> <4>Installing xkeyboard-config-1.4-4.fc10.noarch
> <4>Installing ca-certificates-2008-7.noarch
> <4>Installing mozilla-filesystem-1.9-2.fc10.i386
> <4>Installing mailcap-2.1.28-1.fc9.noarch
> <4>Installing iso-codes-3.3-1.fc10.noarch
> <4>Installing nodoka-filesystem-0.3.90-2.fc10.noarch
> <4>Installing nodoka-metacity-theme-0.3.90-2.fc10.noarch
> <4>Installing texlive-texmf-errata-2007-4.fc9.noarch
> <4>Installing control-center-filesystem-2.24.0.1-9.fc10.i386
> <4>Installing desktop-backgrounds-basic-9.0.0-5.noarch
> <4>Installing basesystem-10.0-1.noarch
> <4>Installing texlive-texmf-errata-dvips-2007-4.fc9.noarch
> <4>Installing texlive-texmf-errata-fonts-2007-4.fc9.noarch
> <4>Installing ncurses-base-5.6-20.20080927.fc10.i386
> .....
> The content of the buf is the content of the install.log file. And
> spnfs_ops.c is used in MDS. This shows that client translate the data to
> MDS, MDS write the data to DS. This architecture is different from the
> pnfs architecture that people say of. Please give me some answer.
> 
> 2010/7/13 Benny Halevy <bhalevy@panasas.com <mailto:bhalevy@panasas.com>>
> 
>     On Jul. 13, 2010, 5:05 +0300, quanli gui <gqlxj1987@gmail.com
>     <mailto:gqlxj1987@gmail.com>> wrote:
>     > I use
>     > #define dprintk printk
> 
>     You don't have to modify the kernel to see the debug prints...
>     You can turn the debug prints on and off in run time
>     by writing the numeric bitmask (in ASCII) into
>     /proc/sys/sunrpc/nfs_debug
>     for example:
>     # echo 32767 > /proc/sys/sunrpc/nfs_debug
> 
>     > to show some messages in the pnfs process. In the pnfs process, the
>     > client would use some functions in nfs4filelayoutdev.c to connect with
>     > ds. But from the printk messages, I found that the functions that
>     > connect to the ds printk the ip message, which is belong to the
>     mds. Do
>     > the client only connect to the mds? Do the mds become the storage
>     server
>     > which connect to the client? This conficts the pnfs
>     architecture.Please
>     > give me some answers.
> 
>     The client should communicate with the DS for I/O operations.
>     If the MSD has dual function, both as a DS and a MDS, the DS ip address
>     may be the same as the MDS's.
> 
>     Can you give an example of a particular message you're worried about?
> 
>     What do you have running on the server side?
> 
>     Benny
> 
> 
