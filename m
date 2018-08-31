Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl1-f196.google.com ([209.85.214.196]:45121 "EHLO
        mail-pl1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727417AbeIADGr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2018 23:06:47 -0400
MIME-Version: 1.0
References: <20170302160211.30451-1-kolga@netapp.com> <20170302160211.30451-3-kolga@netapp.com>
 <15e7ebf8-9150-be06-1a8b-ad0e8a70dbbb@redhat.com> <CAN-5tyHa_azgR0hgzv=Jed+Pg7hxH3DUJJHeNH9x4tnzUpzopQ@mail.gmail.com>
In-Reply-To: <CAN-5tyHa_azgR0hgzv=Jed+Pg7hxH3DUJJHeNH9x4tnzUpzopQ@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Fri, 31 Aug 2018 17:56:56 -0500
Message-ID: <CAH2r5ms+OWdhBu6oU+5p7cWav8ax+eyC4nEBbhLAEzpa_vLXhQ@mail.gmail.com>
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
To: aglo@umich.edu
Cc: fweimer@redhat.com, kolga@netapp.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 31, 2018 at 11:41 AM Olga Kornievskaia <aglo@umich.edu> wrote:
>
> On Fri, Aug 31, 2018 at 12:14 PM Florian Weimer <fweimer@redhat.com> wrote:
> >
> > On 03/02/2017 05:02 PM, Olga Kornievskaia wrote:
> > > Allow nfs_copy_file_range to copy across devices.
> > > NFSv4.2 inter server to server copy always copies across devices, and
> > > NFSv4.2 intra server to server copy can copy across devices on the same
> > > server.
> > >
> > > If a file system's fileoperations copy_file_range operation prohibits
> > > cross-device copies, fall back to do_splice_direct. This is needed for
> > > nfsd_copy_file_range() which is called by the inter server to server
> > > destination server acting as an NFS client, and reading the file from
> > > the source server.
> > >
> > > Signed-off-by: Andy Adamson<andros@netapp.com>
> >
> > What has happened to the patch?  We unwittingly used copy_file_range in
> > the glibc test suite, without realizing that it does not support
> > cross-device copies.
>
> I'm still planning to fight for the patch to be included. As per
> maintainers request, I separated out the async copy patches out and
> hopefully that will be going into 4.20. I'm working on the "inter"
> copy offload functionality which does require this patch. I will start
> submitting and pushing this patch along with the rest of the patches.
>
> Are you interested in the copy_file_range() functionality that does
> support cross-device copies? If so can you tell me how are you using
> it? It would be also helpful to watch for the submission of the patch
> and argue in its favor.

SMB3 clients and server (Windows, Macs, Samba and probably most
every modern NAS out there) support the SMB3 "CopyChunk"
operation used by the Linux client.

I would expect that one of the most useful cases is cross device
For example you have two mounts to your server or server cluster
\\server\share1 is mounted to /mnt1
and
\\server\backup is mounted to /mnt2

and you want to do copy_file or copy_file_range of various
files from /mnt1 to /mnt2

As long as they are both the same file system type, why not
let the file system tell you whether it can do the copy.

Given that this is 10x to 100x faster than the alternative
and this is a common case (and there are many 100s of millions
of SMB3 server capable systems out there which already support
copychunk (and thus would support copy file) - why would we
want to restrict it.

It is much saner to let the file system tell the VFS if it can't
support the cross device copy.

---- and to make it even more obvious why this patch matters ---
Virtualization clients (and various Windows and NetApp server)
support another copy offload mechanism (not just CopyChunk)
ie via ODX which would support cross server not just cross share
copy.    Enabling this would be a BIG incentive for finishing up
ODX copy support in Linux (cifs.ko using SMB3).   This is
fairly widely supported by servers.




-- 
Thanks,

Steve
