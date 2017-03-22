Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37562 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964875AbdCVQpN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 12:45:13 -0400
Received: by mail-wm0-f48.google.com with SMTP id n11so43104499wma.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Mar 2017 09:45:12 -0700 (PDT)
Subject: Re: [PATCH v5 2/5] generic/417: Add small copies to new file test
To: Anna Schumaker <Anna.Schumaker@Netapp.com>, fstests@vger.kernel.org
References: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
 <20170317195233.4042-3-Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <dce891e7-b15b-2197-8473-c1012cc2d216@plexistor.com>
Date: Wed, 22 Mar 2017 18:45:08 +0200
MIME-Version: 1.0
In-Reply-To: <20170317195233.4042-3-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2017 09:52 PM, Anna Schumaker wrote:
> This test copies single bytes from a source file into various new files
> just to make sure that we can handle very small copies.
> 

Sorry for not following closely, but how is this supposed to work, I know that
for FSs that support it a copy_file_range is supported by clone_file_range.
But usually there are fs-block alignment restrictions on clone_file_range.

Does the VFS do the switch from fs->clone to generic-copy, or is the FS
suppose to call the generic-copy?

Thanks
Boaz

> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  tests/generic/417     | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  tests/generic/417.out | 16 ++++++++++
>  tests/generic/group   |  1 +
>  3 files changed, 100 insertions(+)
>  create mode 100755 tests/generic/417
>  create mode 100644 tests/generic/417.out
> 
> diff --git a/tests/generic/417 b/tests/generic/417
> new file mode 100755
> index 00000000..dde3f4d6
> --- /dev/null
> +++ b/tests/generic/417
> @@ -0,0 +1,83 @@
> +#!/bin/bash
> +# FS QA Test No. 417
> +#
> +# Tests vfs_copy_file_range():
> +#   - Copy a small file
> +#   - Small copies from various points in the original file
> +#-----------------------------------------------------------------------
> +# Copyright (c) 2016 Netapp, Inc. All rights reserved.
<snip>


