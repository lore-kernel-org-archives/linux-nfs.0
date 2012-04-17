Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:52986 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab2DQPiz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 11:38:55 -0400
Received: by vbbff1 with SMTP id ff1so4246872vbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 08:38:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334608910.2879.45.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	<1334004744-31842-15-git-send-email-iisaman@netapp.com>
	<1334608910.2879.45.camel@lade.trondhjem.org>
Date: Tue, 17 Apr 2012 11:38:54 -0400
Message-ID: <CADnza45Tp9o1Pk=01LU4wB3UPBsCRMu7KevciGceX3Ph6nRaDA@mail.gmail.com>
Subject: Re: [PATCH 14/26] NFS: merge _full and _partial read rpc_ops
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2012 at 4:41 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> BTW: It makes me nervous that we can allocate a struct nfs_read_data
> that does not have data->header set. Could we please always pass an
> nfs_pgio_header argument?
>
> If you make sure that the above function always bumps header->refcnt,
> then you can check if header->rpc_data is allocated by seeing if
> header->refcnt is zero.
>
> BTW: The same applies to the "write" equivalents...
>


OK

Fred
