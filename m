Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:57377 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752746AbdCBSXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 13:23:37 -0500
Date: Thu, 2 Mar 2017 17:07:14 +0100
From: Christoph Hellwig <hch@lst.de>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
Message-ID: <20170302160714.GA4760@lst.de>
References: <20170302160211.30451-1-kolga@netapp.com> <20170302160211.30451-3-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302160211.30451-3-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 11:02:10AM -0500, Olga Kornievskaia wrote:
> Allow nfs_copy_file_range to copy across devices.
> NFSv4.2 inter server to server copy always copies across devices, and
> NFSv4.2 intra server to server copy can copy across devices on the same
> server.
> 
> If a file system's fileoperations copy_file_range operation prohibits
> cross-device copies, fall back to do_splice_direct. This is needed for
> nfsd_copy_file_range() which is called by the inter server to server
> destination server acting as an NFS client, and reading the file from
> the source server.

NAK, we really should not do operations between different superblocks.
