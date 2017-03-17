Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:18489 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdCRAT3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 20:19:29 -0400
Date: Fri, 17 Mar 2017 15:02:46 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org,
        hch@infradead.org
Subject: Re: [PATCH v5 0/5] Add copy_file_range() tests
Message-ID: <20170317220246.GA12585@birch.djwong.org>
References: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 17, 2017 at 03:52:28PM -0400, Anna Schumaker wrote:
> These tests exercise the copy_file_range() system call, and check copying
> data to both a new file and overwriting data inside an existing file.
> 
> Sorry it took so long to get this version out.  I forgot about these patches
> after the last submission.

Hooray, tests finally!

I had to bump the numbers up due to conflicts (it's usually best to pick
a really high number and let Eryu mvtest them to their real numbers),
but these mostly look ok.

However, I do see that something isn't triggering an EINVAL return code:

generic/816      - output mismatch (see /tmp/xfstests/results//generic/816.out.bad)
    --- tests/generic/816.out   2017-03-17 14:46:21.064521899 -0700
    +++ /tmp/xfstests/results//generic/816.out.bad      2017-03-17 14:58:15.848000000 -0700
    @@ -16,7 +16,6 @@
     e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-816/file
     e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-816/end
     Copy beyond end of original file
    -copy_range: Invalid argument
     md5sums after copying beyond:
     e11fbace556cba26bf0076e74cab90a3  TEST_DIR/test-816/file
     e68d4a150c4e42f4f9ea3ffe4c9cf4ed  TEST_DIR/test-816/beyond
    ...
    (Run 'diff -u tests/generic/816.out /tmp/xfstests/results//generic/816.out.bad'  to see the entire diff)
generic/817      - output mismatch (see /tmp/xfstests/results//generic/817.out.bad)
    --- tests/generic/817.out   2017-03-17 14:47:02.916437143 -0700
    +++ /tmp/xfstests/results//generic/817.out.bad      2017-03-17 14:58:17.168000000 -0700
    @@ -4,7 +4,6 @@
     ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-817/file
     ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-817/copy
     Small copies from various points in the original file
    -copy_range: Invalid argument
     md5sums after small copies
     ab56b4d92b40713acc5af89985d4b786  TEST_DIR/test-817/file
     0cc175b9c0f1b6a831c399e269772661  TEST_DIR/test-817/a
    ...
    (Run 'diff -u tests/generic/817.out /tmp/xfstests/results//generic/817.out.bad'  to see the entire diff)
generic/818      1s
generic/819      1s
generic/820      - output mismatch (see /tmp/xfstests/results//generic/820.out.bad)
    --- tests/generic/820.out   2017-03-17 14:47:44.140338654 -0700
    +++ /tmp/xfstests/results//generic/820.out.bad      2017-03-17 14:58:21.120000000 -0700
    @@ -1,7 +1,6 @@
     QA output created by 820
     Create the original files
     Try to copy when source pos > source size
    -copy_range: Invalid argument
     Try to copy to a read-only file
     copy_range: Bad file descriptor
     Try to copy to an append-only file
    ...
    (Run 'diff -u tests/generic/820.out /tmp/xfstests/results//generic/820.out.bad'  to see the entire diff)

Running 4.11-rc2 here with a ton of XFS patches, though these results
are from an FSTYP=ext4 run.  FSTYP=xfs produces the same diff output.

--D

> 
> Thanks,
> Anna
> 
> 
> Anna Schumaker (5):
>   generic/416: Add copy to new file test
>   generic/417: Add small copies to new file test
>   generic/418: Add copy test that overwrites data
>   generic/419: Add a copy test for overwriting small amounts of data
>   generic/420: Add a copy test for invalid input
> 
>  common/rc             |   6 +++
>  tests/generic/416     | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/416.out |  26 +++++++++++++
>  tests/generic/417     |  83 ++++++++++++++++++++++++++++++++++++++++
>  tests/generic/417.out |  16 ++++++++
>  tests/generic/418     | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/418.out |  17 +++++++++
>  tests/generic/419     |  87 ++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/419.out |  17 +++++++++
>  tests/generic/420     |  76 +++++++++++++++++++++++++++++++++++++
>  tests/generic/420.out |  12 ++++++
>  tests/generic/group   |   5 +++
>  12 files changed, 547 insertions(+)
>  create mode 100755 tests/generic/416
>  create mode 100644 tests/generic/416.out
>  create mode 100755 tests/generic/417
>  create mode 100644 tests/generic/417.out
>  create mode 100755 tests/generic/418
>  create mode 100644 tests/generic/418.out
>  create mode 100755 tests/generic/419
>  create mode 100644 tests/generic/419.out
>  create mode 100644 tests/generic/420
>  create mode 100644 tests/generic/420.out
> 
> -- 
> 2.12.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
