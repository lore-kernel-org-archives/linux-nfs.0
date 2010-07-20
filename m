Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:62440 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753842Ab0GTFza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:55:30 -0400
Message-ID: <4C453A50.7070009@panasas.com>
Date: Tue, 20 Jul 2010 08:55:28 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
CC: Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/9] layout driver api cleanup and usage
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following patches do some further cleanup on top of Andy's
2010-07-15's patchset and use the new api in the obj and block LDs

[PATCH 1/3] SQUASHME: pnfs-submit: add nr_pages back to write_pagelist api
[PATCH 2/3] SQUASHME: pnfs-submit: filelayout: add nr_pages back to write_pagelist api
[PATCH 3/3] SQUASHME: pnfs-submit: use nfs_page_array_len in pnfs_try_to_read_data

[PATCH 1/3] SQUASHME: pnfs-block: use new commit api
[PATCH 2/3] SQUASHME: pnfs-block: use new read_pagelist api
[PATCH 3/3] SQUASHME: pnfs-block: use new write_pagelist api

[PATCH 1/3] SQUASHME: pnfs-obj: use new commit api
[PATCH 2/3] SQAUSHME: pnfs-obj: use new read_pagelist api
[PATCH 3/3] SQUASHME: pnfs-obj: use new write_pagelist api
