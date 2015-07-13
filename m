Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34594 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbGMHsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:48:39 -0400
Received: by igvi1 with SMTP id i1so26085269igv.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 00:48:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150713074008.GA23338@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
 <20150713065632.GA26245@infradead.org> <CAKVebiUnoFkp-q3VypGMqojvGF1MAAKLLY0PqABzD7DHq0w7Pw@mail.gmail.com>
 <20150713074008.GA23338@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Mon, 13 Jul 2015 15:48:19 +0800
Message-ID: <CAKVebiWFB5s7ZbipHK_8e2qgR8TDY9o=65Q61wx2CYKEBxM6zg@mail.gmail.com>
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Zach Brown <zab@zabbo.net>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 3:40 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Jul 13, 2015 at 03:30:56PM +0800, Peng Tao wrote:
>> I wasn't able to find XFS clone implementation in upstream kernel. Can
>> you please give a point to it so I can take a look?
>
> Hi Peng,
>
> it's not merged yet, I just mentioned it because it follows the btrfs
> lead:
>
>         http://oss.sgi.com/archives/xfs/2015-06/msg00407.html
Thanks!
