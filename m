Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34909 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbbH0GYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 02:24:31 -0400
Received: by igbjg10 with SMTP id jg10so59492919igb.0
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 23:24:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826131156.GA9948@infradead.org>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com> <20150826131156.GA9948@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Thu, 27 Aug 2015 14:24:11 +0800
Message-ID: <CAKVebiVh2Aker6pL2krtt-ovqiC5tc3EV-ph8fO6q5Ui3dBF8w@mail.gmail.com>
Subject: Re: [PATCH-RFC-RESEND 0/9] NFS/NFSD: add NFSv42 CLONE operation support
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

On Wed, Aug 26, 2015 at 9:11 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Aug 26, 2015 at 04:16:41PM +0800, Peng Tao wrote:
>> 2. vfs_file_clone_range() does not expect file systems to do data copy, and thus
>> no rw_verify_area() required.
>
> While there is no physical copy involved, the data logically is copied from
> file A to file B.  So we still need all the checks from rw_verify_area.
I see. Will add the checks.

Cheers,
Tao
