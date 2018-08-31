Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44900 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727973AbeHaUVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Aug 2018 16:21:20 -0400
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
To: Olga Kornievskaia <kolga@netapp.com>, linux-fsdevel@vger.kernel.org
Cc: hch@lst.de, linux-nfs@vger.kernel.org
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-3-kolga@netapp.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <15e7ebf8-9150-be06-1a8b-ad0e8a70dbbb@redhat.com>
Date: Fri, 31 Aug 2018 18:13:06 +0200
MIME-Version: 1.0
In-Reply-To: <20170302160211.30451-3-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/02/2017 05:02 PM, Olga Kornievskaia wrote:
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
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>

What has happened to the patch?  We unwittingly used copy_file_range in 
the glibc test suite, without realizing that it does not support 
cross-device copies.

Thanks,
Florian
