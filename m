Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61566 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab1JaQi5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 12:38:57 -0400
Received: by vws1 with SMTP id 1so5009811vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 09:38:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320076148.4714.4.camel@lade.trondhjem.org>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
 <1320074136-3087-2-git-send-email-bergwolf@gmail.com> <1320076148.4714.4.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 1 Nov 2011 00:38:35 +0800
Message-ID: <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 31, 2011 at 11:49 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2011-10-31 at 08:15 -0700, Peng Tao wrote:
>> For blocklayout, we need to issue layoutreturn to return layouts when
>> handling CB_RECALL_ANY.
>
> Why?
Because replying NFS4_OK to CB_RECALL_ANY indicates that client knows
that server wants client to return layout. And server will be waiting
for layoutreturn in such case.

Thanks,
Tao

>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>
