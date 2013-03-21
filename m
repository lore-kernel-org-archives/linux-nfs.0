Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59131 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab3CURNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 13:13:22 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so1186512pdi.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2013 10:13:22 -0700 (PDT)
Date: Fri, 22 Mar 2013 01:06:14 +0800
From: Peng Tao <bergwolf@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH v2 2/3] NFSv4.1: Always clear the NFS_INO_LAYOUTCOMMIT in
 layoutreturn
Message-ID: <20130321170614.GA4581@X61>
References: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 21, 2013 at 10:13:00AM -0400, Trond Myklebust wrote:
<snip>
> @@ -1458,7 +1479,6 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
>  	dprintk("pnfs write error = %d\n", hdr->pnfs_error);
>  	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
>  	    PNFS_LAYOUTRET_ON_ERROR) {
> -		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
Hi Trond and Boaz,

If object layout requires layout being committed before returned (as fixed in
the 3/3 patch), is it a potential problem to directly return layout here as
well? e.g., if one lseg is successfully written and pending layoutcommit,
then another lseg of the same file failed read/write, then layout will be
returned w/o layoutcommit. For blocklayout, it is a potential data corruption
and that's why block layout doesn't set PNFS_LAYOUTRET_ON_ERROR bit. So
I'm wondering if object will suffer from the same issue?

Thanks,
Tao

-- 
Here lieth one whos name was writ on water.
