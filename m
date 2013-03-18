Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47459 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3CRJBr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 05:01:47 -0400
Received: by mail-ee0-f46.google.com with SMTP id e49so2528606eek.33
        for <linux-nfs@vger.kernel.org>; Mon, 18 Mar 2013 02:01:45 -0700 (PDT)
Message-ID: <5146D7F6.3010607@tonian.com>
Date: Mon, 18 Mar 2013 11:01:42 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: chenditang <chendt.fnst@cn.fujitsu.com>
CC: linux-nfs@vger.kernel.org, LINE <fnst-xmlinux@cn.fujitsu.com>,
        Trond Myklebust <trond.myklebust@netapp.com>
Subject: Re: pnfs: WRITE operation will not send LAYOUTCOMMI OP to MDS if
 use filelayout
References: <5146BE38.2060004@cn.fujitsu.com>
In-Reply-To: <5146BE38.2060004@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-18 09:11, chenditang wrote:
> In the recent pnfs kernel versions, WRITE operation will not send
> LAYOUTCOMMI OP to MDS if use filelayout.

I presume that the file server sets NFL4_UFLG_COMMIT_THRU_MDS
and that the DS is returning how=FILE_SYNC and that the client
is implementing the behavior described in  Errata ID: 2751
http://www.rfc-editor.org/errata_search.php?rfc=5661

Do you have a tcp dump of client, MDS, and DS traffic?

> 
> In nfs_write_rpcsetup function, the value of the variable 'stable' will
> always be NFS_FILE_SYNC(ncommit is 0). so NFS_INO_LAYOUTCOMMIT 
> flag will not be set.

What's the value of the "how" arg to nfs_write_rpcsetup that you see?
At any rate, if you look at filelayout_set_layoutcommit, it will not
call pnfs_set_layoutcommit in the following cases:

        if (FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds ||
            wdata->res.verf->committed == NFS_FILE_SYNC)
                return;

Benny

> 
> The value of the variable ncommit' will be ++ in the later process
> (nfs_writeback_release_common function).
> 
> 
> Thanks!
> 

