Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33355 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbH0GQL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 02:16:11 -0400
Received: by igbjg10 with SMTP id jg10so9873956igb.0
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 23:16:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826131741.GA22249@infradead.org>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-3-git-send-email-tao.peng@primarydata.com> <20150826131741.GA22249@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Thu, 27 Aug 2015 14:15:51 +0800
Message-ID: <CAKVebiWewEd_jdVz=NwMgabZieNSfQhpJ=JYE1c6yJ85SQSFDA@mail.gmail.com>
Subject: Re: [PATCH-RFC-RESEND 2/9] vfs/btrfs: add .clone_range file operation
To: Christoph Hellwig <hch@infradead.org>
Cc: Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 9:17 PM, Christoph Hellwig <hch@infradead.org> wrote:
> You need to eep the existing defintion, either as a duplicate with a
> comment, or by including the uapi fs.h and defininin it to the new name.
OK. will keep it.

>
> Also this will break cifs, which uses the BTRFS_IOC_CLONE defintion
> already.
I'll look into it as well.

Thanks,
Tao
