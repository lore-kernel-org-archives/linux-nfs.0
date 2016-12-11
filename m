Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:36376 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbcLKJDx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 04:03:53 -0500
MIME-Version: 1.0
In-Reply-To: <20161208184909.23321-1-Anna.Schumaker@Netapp.com>
References: <20161208184909.23321-1-Anna.Schumaker@Netapp.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sun, 11 Dec 2016 11:03:50 +0200
Message-ID: <CAOQ4uxj5ct3-jYzj7RKip5oKqfX-U+jTXqhXDPSR2qOeSPbXMg@mail.gmail.com>
Subject: Re: [PATCH v4 0/5] Add copy_file_range() tests
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests <fstests@vger.kernel.org>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 8, 2016 at 8:49 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> These tests exercise the copy_file_range() system call, and check copying
> data to both a new file and overwriting data inside an existing file.
>

Hi Anna,

Both dedup and reflink have some generic tests to check for invalid cases
generic/{157,158}.
I wonder if there are any other dedup/reflink tests that should be
duplicated for copy_range. Darrick?
I also wonder if it would make sense to "deduplicate" some of these test
to repeat the same relevant checks for all 3 methods.


> The last patch is a duplicate of a patch I already submitted for the
> xfs_io utility.  It adds in fixes for the 'copy_range' command so error
> checking can work and so some copies won't loop forever.
>
> Thanks,
> Anna
>
> Anna Schumaker (5):
>   generic/392: Add copy to new file test
>   generic/393: Add small copies to new file test
>   generic/394: Add copy test that overwrites data
>   generic/395: Add a copy test for overwriting small amounts of data
>   generic/396: Add a copy test for invalid input
>
>  common/rc             |   6 +++
>  tests/generic/392     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/392.out |  26 +++++++++++++
>  tests/generic/393     |  83 ++++++++++++++++++++++++++++++++++++++++
>  tests/generic/393.out |  16 ++++++++
>  tests/generic/394     | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/394.out |  17 +++++++++
>  tests/generic/395     |  87 ++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/395.out |  17 +++++++++
>  tests/generic/396     |  68 +++++++++++++++++++++++++++++++++
>  tests/generic/396.out |   8 ++++
>  tests/generic/group   |   5 +++
>  12 files changed, 535 insertions(+)
>  create mode 100755 tests/generic/392
>  create mode 100644 tests/generic/392.out
>  create mode 100755 tests/generic/393
>  create mode 100644 tests/generic/393.out
>  create mode 100755 tests/generic/394
>  create mode 100644 tests/generic/394.out
>  create mode 100755 tests/generic/395
>  create mode 100644 tests/generic/395.out
>  create mode 100644 tests/generic/396
>  create mode 100644 tests/generic/396.out
>
> --
> 2.10.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
