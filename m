Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33747 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbbGMHbQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:31:16 -0400
Received: by iggp10 with SMTP id p10so70001530igg.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 00:31:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150713065632.GA26245@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com> <20150713065632.GA26245@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Mon, 13 Jul 2015 15:30:56 +0800
Message-ID: <CAKVebiUnoFkp-q3VypGMqojvGF1MAAKLLY0PqABzD7DHq0w7Pw@mail.gmail.com>
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

On Mon, Jul 13, 2015 at 2:56 PM, Christoph Hellwig <hch@infradead.org> wrote:
> Hi Peng,
>
> please do not add another different ioctl.  I would much prefer to bring
> the yscall forward.  Alternatively please follow the btrfs ioctl, which
> XFS has been picking up as well.
>
Hi Christoph,

I wasn't able to find XFS clone implementation in upstream kernel. Can
you please give a point to it so I can take a look?

Thanks,
Tao
