Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:49788 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbaKJRSd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2014 12:18:33 -0500
Received: by mail-wg0-f49.google.com with SMTP id x13so9394995wgg.36
        for <linux-nfs@vger.kernel.org>; Mon, 10 Nov 2014 09:18:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5460D84A.3050704@Netapp.com>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
	<20141109011518.8806.36904.stgit@manet.1015granger.net>
	<5460D84A.3050704@Netapp.com>
Date: Mon, 10 Nov 2014 11:21:34 -0500
Message-ID: <CAHQdGtTOzEtFe6QkjdR80D+hnP1YoR42BdUEz_2Z_hqHJxf+jA@mail.gmail.com>
Subject: Re: [PATCH v2 09/10] NFS: SETCLIENTID XDR buffer sizes are incorrect
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2014 at 10:22 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hi Chuck,
>
> It looks like this patch and the next one are general client changes, so they might have to be submitted to Trond directly rather than going through my tree.  Trond, what do you think?

Ditto for the iostat locking change (PATCH 08/10). None of those are
RDMA related.

Should I just cherrypick them from this series?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
