Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35310 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbcCPDkW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2016 23:40:22 -0400
MIME-Version: 1.0
In-Reply-To: <20160315071439.GE19747@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org> <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
 <CAH2r5mv3OTmPOQBV7xc-uZmB0gWxykXOCEVOcybx3tbHiViTZg@mail.gmail.com> <20160315071439.GE19747@infradead.org>
From: Steve French <smfrench@gmail.com>
Date: Tue, 15 Mar 2016 22:40:00 -0500
Message-ID: <CAH2r5ms+bQTQjL5DUz0v7vWhcaUr_ewvDcFiSasFNYphFdsf=Q@mail.gmail.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
To: Christoph Hellwig <hch@infradead.org>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 2:14 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Mar 11, 2016 at 02:05:16PM -0600, Steve French wrote:
>> A loosely related question is what can be done for tools around existing
>> interfaces for ACLs.  I recently found out NTFS-3g has this xattr:
>>
>>     static const char nf_ns_xattr_ntfs_acl[] = "system.ntfs_acl";
>>
>> which allows you to query system.ntfs_acl xattr to get their full ACL
>
> Bah.  Filesystems really have no business exposing random system xattrs,
> and we really need to add a filter to fs/xattr.c to not expose
> arbitrary attrs ouside the user.* prefix.

Hopefully we don't consider them random system xattrs, it is
plausible that ntfs uses these for user space tools that I don't
have.

At least for cifs.ko a similar subset (querying ACLs, streams and
reparse info e.g.)
to the ntfs set would be very helpful.  For example,
Being able to query the actual ACL over the wire, is important for backup
and for debug, the only question is whether to do it via an xattr (possibly
being able to have some synergy with existing ntfs-3g tools) or an ioctl
(since adding an NTFS specific syscall for a couple fs doesn't make sense).


For the specific example of the odd ntfs.streams.list xattr, I can see why
they have it.  I would have mixed feelings about having no way to tell
streams and EAs from each other
since NTFS-3g displaying streams as xattrs and also Extended
Attributes (EAs) as xattrs
(and if they didn't have an additional xattr to list streams)
without a way to tell the difference (at least a system xattr to list
the alternate
data streams is useful).   There is useful information in alternate data streams
that backup (and debugging) programs need for some workloads,
for example the origin (where internet explorer downloaded a file from)
and file classification information.

-- 
Thanks,

Steve
