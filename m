Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29424 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752569AbcIQRET (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 13:04:19 -0400
Date: Sat, 17 Sep 2016 10:03:41 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 0/4] Add copy_file_range() tests
Message-ID: <20160917170341.GA3059@birch.djwong.org>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 07, 2016 at 03:56:15PM -0400, Anna Schumaker wrote:
> These tests exercise the copy_file_range() system call, and check copying
> data to both a new file and overwriting data inside an existing file.  I use
> the xfs_io "copy_range" command for the actual copies, so running these
> tests requires an up-to-date version of xfsprogs.
> 
> Thanks,
> Anna
> 
> Anna Schumaker (4):
>   generic/377: Add copy to new file test
>   generic/378: Add small copies to new file test
>   generic/379: Add copy test that overwrites data
>   generic/380: Add a copy test for overwriting small amounts of data

By the way, do you have a test to check that invalid inputs produce
the error codes listed in the manpage?

--D

> 
>  tests/generic/377     | 102 +++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/377.out |  21 ++++++++++
>  tests/generic/378     |  88 +++++++++++++++++++++++++++++++++++++++++
>  tests/generic/378.out |  14 +++++++
>  tests/generic/379     | 107 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/379.out |  17 ++++++++
>  tests/generic/380     |  94 ++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/380.out |  17 ++++++++
>  tests/generic/group   |   4 ++
>  9 files changed, 464 insertions(+)
>  create mode 100644 tests/generic/377
>  create mode 100644 tests/generic/377.out
>  create mode 100644 tests/generic/378
>  create mode 100644 tests/generic/378.out
>  create mode 100644 tests/generic/379
>  create mode 100644 tests/generic/379.out
>  create mode 100644 tests/generic/380
>  create mode 100644 tests/generic/380.out
> 
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
