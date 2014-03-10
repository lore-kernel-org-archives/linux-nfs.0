Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:18762 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbaCJI3O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 04:29:14 -0400
Message-ID: <531D77D9.40900@intel.com>
Date: Mon, 10 Mar 2014 16:29:13 +0800
From: "Yan, Zheng" <zheng.z.yan@intel.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH] nfsd4: fix memory leak in nfsd4_encode_fattr()
References: <1394427127-9985-1-git-send-email-zheng.z.yan@intel.com> <20140310080437.GA24753@infradead.org>
In-Reply-To: <20140310080437.GA24753@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/10/2014 04:04 PM, Christoph Hellwig wrote:
> On Mon, Mar 10, 2014 at 12:52:07PM +0800, Yan, Zheng wrote:
>> fh_put() does not free the temporary file handle.
> 
> Btw, it seems like the code to generate the file handle if it's missing
> should be moved out of nfsd4_encode_fattr and into
> nfsd4_encode_dirent_fattr or a small helper just called from there so that:
> 
>  a) the code flow is more obvious
>  b) the calling conventions for nfsd4_encode_fattr are sensible
>  c) nfsd4_encode_fattr shrinks at least a tiny bit
>  d) the required cleanup becomes more obvious by being paired with the
>     allocation and initialization of the FH.
> 
> Just curious: which client asks for the FH or FSID in READDIRPLUS?
> 

Both nfs server and client are complied from 3.14-rc5 kernel. The exported
FS is Ceph.

Regards
Yan, Zheng
 
