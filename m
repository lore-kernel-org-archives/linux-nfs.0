Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:56847 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934032Ab2DLPtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Apr 2012 11:49:24 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 12 Apr 2012 11:49:23 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BA4636E805C
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 11:49:05 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3CFjrhV251776
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 11:49:05 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3CFNDhj003703
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 09:23:13 -0600
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q3CFN41f002038
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 09:23:04 -0600
Date: Thu, 12 Apr 2012 10:23:03 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: How to manage EDQUOT on the server side
Message-ID: <20120412152303.GA10979@us.ibm.com>
References: <4F86E4E0.8000703@cea.fr>
 <20120412142946.GB29891@us.ibm.com>
 <4F86E813.3010200@cea.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F86E813.3010200@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DENIEL Philippe [philippe.deniel@cea.fr] wrote:
> > I think there is a bug where the client
> >reports EIO rather than QUOTA/NOSPC errors under some circumstances.
> Do you have more informations about those circumstances ? I just ran
> "dd" until I exceed my data quota's hard limit.

For me dd with "conv=fdatasync" didn't work every time. Regular dd did
work, so the issue is with fsync/sync.

elm3c46:/mnt # dd if=/dev/zero of=./testfile count=100000 bs=1024
dd: closing output file `./testfile': No space left on device

elm3c46:/mnt # dd if=/dev/zero of=./testfile count=100000 bs=1024 conv=fdatasync
dd: fdatasync failed for `./testfile': Input/output error
100000+0 records in
100000+0 records out
102400000 bytes (102 MB) copied, 0.165134 s, 620 MB/s

Notes from Neil Brown:

The problem here is that vfs_sync_range in fs/sync.c prefers to error
from filemap_write_and_wait_range over the error from fop->fsync.

The former will be EIO in this case, the latter is EDQUOT.
fsync returns and error and then clears, so the EDQUOT is lost.

Shortly after this, nfs_do_fsync is called (again) which would prefer
the EDQUOT error, but it has been cleared by this time.

This only affect O_SYNC writes.

Regards, Malahal.
Neil's fix does work for my case.

