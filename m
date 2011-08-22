Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:45734 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab1HVX3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 19:29:01 -0400
Message-ID: <4E52E603.3040107@panasas.com>
Date: Mon, 22 Aug 2011 16:28:03 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: <tao.peng@emc.com>, <Trond.Myklebust@netapp.com>, <benny@tonian.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com> <4E42C564.7070504@panasas.com> <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com> <4E442512.7080904@panasas.com> <CA+a=Yy4g09b_AEf2px1Cjfmr_ud3PFuAbEwdez1cbsiYJ0mmgA@mail.gmail.com> <4E446F63.5080707@panasas.com> <F19688880B763E40B28B2B462677FBF805BF0EB0A3@MX09A.corp.emc.com> <4E4AD0CE.3000506@panasas.com> <CA+a=Yy5jApbUqy+ESZxczZ3N+ixg8ixK9iAe0DWqSZavap18xQ@mail.gmail.com>
In-Reply-To: <CA+a=Yy5jApbUqy+ESZxczZ3N+ixg8ixK9iAe0DWqSZavap18xQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/17/2011 02:44 AM, Peng Tao wrote:
<snip>

> The problem w/ directly calling nfs_initiate_write() is that we may
> have pagelist length larger than server's rsize/wsize. So if client
> sends all the pages in single READ/WRITE rpc, MDS will reject the
> READ/WRITE operation. Therefore we need to recoalesce them before
> re-sending to MDS.
> 

Rrrr, you are absolutely right. I needed a smack on the head, to
get back on track.

<snip>

Thanks
Boaz
