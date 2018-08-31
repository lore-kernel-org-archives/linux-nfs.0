Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:43648 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727268AbeHaUdt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2018 16:33:49 -0400
MIME-Version: 1.0
References: <20170302160211.30451-1-kolga@netapp.com> <20170302160211.30451-3-kolga@netapp.com>
 <15e7ebf8-9150-be06-1a8b-ad0e8a70dbbb@redhat.com>
In-Reply-To: <15e7ebf8-9150-be06-1a8b-ad0e8a70dbbb@redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 31 Aug 2018 12:25:21 -0400
Message-ID: <CAN-5tyHa_azgR0hgzv=Jed+Pg7hxH3DUJJHeNH9x4tnzUpzopQ@mail.gmail.com>
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
To: fweimer@redhat.com
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 31, 2018 at 12:14 PM Florian Weimer <fweimer@redhat.com> wrote:
>
> On 03/02/2017 05:02 PM, Olga Kornievskaia wrote:
> > Allow nfs_copy_file_range to copy across devices.
> > NFSv4.2 inter server to server copy always copies across devices, and
> > NFSv4.2 intra server to server copy can copy across devices on the same
> > server.
> >
> > If a file system's fileoperations copy_file_range operation prohibits
> > cross-device copies, fall back to do_splice_direct. This is needed for
> > nfsd_copy_file_range() which is called by the inter server to server
> > destination server acting as an NFS client, and reading the file from
> > the source server.
> >
> > Signed-off-by: Andy Adamson<andros@netapp.com>
>
> What has happened to the patch?  We unwittingly used copy_file_range in
> the glibc test suite, without realizing that it does not support
> cross-device copies.

I'm still planning to fight for the patch to be included. As per
maintainers request, I separated out the async copy patches out and
hopefully that will be going into 4.20. I'm working on the "inter"
copy offload functionality which does require this patch. I will start
submitting and pushing this patch along with the rest of the patches.

Are you interested in the copy_file_range() functionality that does
support cross-device copies? If so can you tell me how are you using
it? It would be also helpful to watch for the submission of the patch
and argue in its favor.

Thank you.
>
> Thanks,
> Florian
