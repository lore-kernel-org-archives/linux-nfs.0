Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:59624 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753505AbdCBQuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:50:39 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170302160714.GA4760@lst.de>
Date: Thu, 2 Mar 2017 11:38:03 -0500
CC: <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Message-ID: <0ADCDD29-61BA-46CA-902C-06A6F7D06450@netapp.com>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-3-kolga@netapp.com> <20170302160714.GA4760@lst.de>
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 2, 2017, at 11:07 AM, Christoph Hellwig <hch@lst.de> wrote:
>=20
> On Thu, Mar 02, 2017 at 11:02:10AM -0500, Olga Kornievskaia wrote:
>> Allow nfs_copy_file_range to copy across devices.
>> NFSv4.2 inter server to server copy always copies across devices, and
>> NFSv4.2 intra server to server copy can copy across devices on the =
same
>> server.
>>=20
>> If a file system's fileoperations copy_file_range operation prohibits
>> cross-device copies, fall back to do_splice_direct. This is needed =
for
>> nfsd_copy_file_range() which is called by the inter server to server
>> destination server acting as an NFS client, and reading the file from
>> the source server.
>=20
> NAK, we really should not do operations between different superblocks.

Can you provide some reasoning as to why? What would it break? The =
reasoning for including one is to allow for a file system to achieve =
better performance which seems like a feature that would be of great =
benefit.=20=
