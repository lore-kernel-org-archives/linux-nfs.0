Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40300 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750863AbdAPQyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Jan 2017 11:54:12 -0500
Date: Mon, 16 Jan 2017 11:54:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: Make sure pass all valid export flags to nfsd
Message-ID: <20170116165410.GB2953@fieldses.org>
References: <c0826298-545e-64a3-b6bb-86413bf9eb39@gmail.com>
 <20170106210531.GB31401@fieldses.org>
 <49b7be0a-548a-cff1-8f09-613cd5c63141@gmail.com>
 <20170111141650.GA18977@fieldses.org>
 <fdea0dfa-14f6-a29b-4001-549f0a40601d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <fdea0dfa-14f6-a29b-4001-549f0a40601d@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 15, 2017 at 03:43:21PM +0800, Kinglong Mee wrote:
> On 1/11/2017 22:16, J. Bruce Fields wrote:
> > On Sat, Jan 07, 2017 at 07:57:28PM +0800, Kinglong Mee wrote:
> >> On 1/7/2017 05:05, J. Bruce Fields wrote:
> >>> On Sat, Dec 31, 2016 at 09:05:11PM +0800, Kinglong Mee wrote:
> >>>> test_export pass a export flags only marks NFSEXP_FSID,
> >>>> nfsd may want other flags for export checking.
> >>>
> >>> Why?  What problem does this fix?
> >>
> >> When testing the patch "NFSD: Only support readonly export for
> >> !fsync and readonly filesystem", I found exportfs don't pass 
> >> all valid export flags to nfsd. So, make this patch.
> > 
> > This function is meant to test whether a filesystem supports nfs export
> > or not.  It doesn't need the full set of export flags.  Off the top of
> > my head I can't see reason this would cause problems, but I'm not
> > convinced it's safe, either.  (New nfs-utils against old kernels might
> > be a case to check, e.g. to see how unsupported flags are handled.)
> 
> There are two cases that passing the flags to nfsd, 
> 1, exportfs checks the export entry, only NFSEXP_FSID without this patch,
> 2, mountd pass the validate export entry, all validate export flags.
> 
> When the new nfs-utils against old kernels,
> user specifies an unsupported flags(Not NFSEXP_FSID),
> exportfs doesn't warning that unsupported flags (without test),
> mountd doesn't get the export entry for the flags.
> 
> If exportfs warning the unsupported flags, user can modify it and
> do the right export.
> Do I have an exact understanding?

OK, so when somebody specifies unsupported flags, the failures is silent
and client mounts just fail.  It would be better to warn when exportfs
runs.

I agree that that would be helpful.  Have you tested those cases?  (new
nfs-utils, old kernel).

It would be worth looking at validate_export() to see how it could
improve error messages in this case.  Currently it will say only:

	/example/export does not support NFS export

or

	/example/export requires fsid= for export

With your patch (forgive me if I misremember), I believe those are still
the only error messages, so it will be confusing if, for example, you
get

	/example/export does not support NFS export

when the real problem is that an export flag is unsupported.  (But maybe
you had kernel messages to help there, I don't remember.)

--b.
