Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35058 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbGMHyI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:54:08 -0400
Received: by iecuq6 with SMTP id uq6so229775048iec.2
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 00:54:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150713074139.GB23338@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
 <20150713065851.GD26245@infradead.org> <CAKVebiXYYzL=yhMBUjxKk=7p+Aunm1UFPRCzXsqYi5R7Fj7=gg@mail.gmail.com>
 <20150713074139.GB23338@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Mon, 13 Jul 2015 15:53:48 +0800
Message-ID: <CAKVebiVQ=pOVdUXzTBqqBGARWU2PUcUL8bYAaooJjfjOcOeRBw@mail.gmail.com>
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, Zach Brown <zab@zabbo.net>,
        "Darrick J. Wong" <darrick.wong@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 3:41 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Jul 13, 2015 at 03:36:22PM +0800, Peng Tao wrote:
>> So the main change is .copy_file_range syscall. Was it rejected before
>> or can we just push it forward as it is?
>
> It wasn't rejected, but we kept bikeshedding over the semantics insted
> of moving it forward.
>
>> If there are objections against a new syscall, we can drop it and move
>> on with vfs helper and the new copy_file_range file operation, in
>> order to just make nfsd clone work.
>
> I think everyone wants the syscall, but people don't agree on the
> semantics.  For now maybe we should just add the method and move the
> btrfs/xfs ioctl to common code.
yeah, makes sense.
