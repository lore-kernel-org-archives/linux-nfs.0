Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:32850 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbbHCPat (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 11:30:49 -0400
Received: by obdeg2 with SMTP id eg2so101600175obd.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Aug 2015 08:30:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55BF8551.2040505@Netapp.com>
References: <1438375070-4262-1-git-send-email-trond.myklebust@primarydata.com>
	<55BF8551.2040505@Netapp.com>
Date: Mon, 3 Aug 2015 11:30:48 -0400
Message-ID: <CAHQdGtTtQPMn7db54fhebBEYjyzHfx=bvkJM9Xw5MxqMLounVQ@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1/pnfs: Fix atomicity of commit list updates
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 3, 2015 at 11:14 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hey Trond,
>
> On 07/31/2015 04:37 PM, Trond Myklebust wrote:
<snip>
>> +void
>> +nfs_request_add_commit_list_locked(struct nfs_page *req, struct list_head *dst,
>> +                         struct nfs_commit_info *cinfo)
>> +{
>> +     set_bit(PG_CLEAN, &req->wb_flags);
>> +     nfs_list_add_request(req, dst);
>> +     cinfo->mds->ncommit++;
>> +}
>
> This function also needs to be exported for pnfs to use it:
>
>   MODPOST 112 modules
> ERROR: "nfs_request_add_commit_list_locked" [fs/nfs/nfsv4.ko] undefined!
> scripts/Makefile.modpost:90: recipe for target '__modpost' failed
>
> Thanks,
> Anna

Thanks! Fixed now...

Trond
