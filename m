Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9695 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410Ab1DKENT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2011 00:13:19 -0400
Message-ID: <4DA27FD8.7000103@panasas.com>
Date: Mon, 11 Apr 2011 07:13:12 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: quanli gui <gqlxj1987@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
CC: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Fwd: [pnfs]how to use object-based pnfs
References: <BANLkTim8WvPR8K0-nv=8WvMUit8EK9z10g@mail.gmail.com> <BANLkTi=dR-z3=nGNOmAEQuwdz+uB_win5g@mail.gmail.com>
In-Reply-To: <BANLkTi=dR-z3=nGNOmAEQuwdz+uB_win5g@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Quanli Gui,

The object-based pnfs server is based on the exofs filesystem
which is in the mainline tree, plus a few patches in the linux-pnfs git
tree, available in the pnfs-all-latest branch:

e24ff7c pnfsd-exofs: pnfs objects server XDR functions
9c0cd62 pnfsd-exofs: Add pNFS export support
3b8ef79 pnfsd-exofs: get_device_info implementation.
cea15bf pnfsd-exofs: Recall layouts on truncate
835e61b pnfsd-exofs: layoutreturn pnfs-obj information decoding
d01493f SQUASHME: pnfsd-exofs: convert to new pnfs-submit changes

Boaz (Cc'ed here) is the GUI who implemented most of it so he'd be the
best person who could help you if you have any questions.

See the following documents in the linux tree for setting up exofs:
Documentation/filesystems/exofs.txt
Documentation/scsi/osd.txt

Once exofs is set up on the server and is exported with the pnfs
export option and the obj layout driver is set up on the client
(including attaching to all OSDs) you just need to mount the MDS
the same way you would do for pnfs over nfsv4.1 files.

See also the do-* scripts in the open-osd git tree for
practical examples:
http://git.open-osd.org/gitweb.cgi?p=open-osd.git;a=tree

Regards,

Benny

On 2011-04-11 06:08, quanli gui wrote:
> 
> 
> ---------- Forwarded message ----------
> From: *quanli gui* <gqlxj1987@gmail.com <mailto:gqlxj1987@gmail.com>>
> Date: 2011/4/11
> Subject: [pnfs]how to use object-based pnfs
> To: linux-pnfs <linux-nfs@vger.kernel.org
> <mailto:linux-nfs@vger.kernel.org>>
> 
> 
>  pNFS has object layout, in the linux source code, we found that there
> are only some source code on the client, for example, in
> fs/nfs/objlayout. It looks like that there is no source code about the
> server(file server).I try to configure object-based pnfs via the manner
> that using 'modprobe objlayoutdriver' on the client, but the fiesystem
> doesn't read/write via object layout.
> 
>     * how to configure object-base pNFS? Is there some documents about
>       the configuration?
>     * Is there some extra configuration on the file server to support
>       object layout? Is there  necessary to configure open-osd on the
>       file server? If there is, how to configure?
> 
> 

