Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nautica.notk.org ([91.121.71.147]:40951 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185Ab2E3M3P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 08:29:15 -0400
Date: Wed, 30 May 2012 14:28:58 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: NFS/RDMA - client crash on mount
Message-ID: <20120530122858.GB29006@nautica>
References: <20120530114338.GA28445@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20120530114338.GA28445@nautica>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Well don't mind me, it was soft-iwarp related afterall.
It would look like siw doesn't like 2K MTU like a few other devices,
adding it in the list in net/sunrpc/xprtrdma/verbs.c around line 880
made the crash just disappear.

It's not something easy to patch though given siw is out of tree, why is
the MTU 2k by default? Isn't there a way to get capatibilities out of
the devices, other than an hard-coded list like this?

(this:
/* XXX Tavor device performs badly with 2K MTU! */
if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0)
{
	struct pci_dev *pcid = to_pci_dev(ia->ri_id->device->dma_device);
	if (pcid->device == PCI_DEVICE_ID_MELLANOX_TAVOR &&
	    (pcid->vendor == PCI_VENDOR_ID_MELLANOX ||
	    pcid->vendor == PCI_VENDOR_ID_TOPSPIN)) {
		struct ib_qp_attr attr = {
			.path_mtu = IB_MTU_1024
		};
		rc = ib_modify_qp(ia->ri_id->qp, &attr, IB_QP_PATH_MTU);
	}
})


Sorry for the noise then, thanks to everyone who bothered to read my
mail.

-- 
Dominique Martinet

