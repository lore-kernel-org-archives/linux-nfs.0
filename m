Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbbJZVlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2015 17:41:12 -0400
Date: Mon, 26 Oct 2015 17:41:10 -0400
To: =?utf-8?Q?P=C3=A1draig?= Brady <P@draigBrady.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com
Subject: Re: [PATCH v7 5/4] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20151026214110.GA9232@fieldses.org>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445628736-13058-6-git-send-email-Anna.Schumaker@Netapp.com>
 <562B734D.50800@draigBrady.com>
 <20151026033925.GA9945@infradead.org>
 <562E1A55.4050409@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <562E1A55.4050409@draigBrady.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 26, 2015 at 12:19:33PM +0000, Pádraig Brady wrote:
> On 26/10/15 03:39, Christoph Hellwig wrote:
> > On Sat, Oct 24, 2015 at 01:02:21PM +0100, P??draig Brady wrote:
> >> I'm a bit worried about the sparse expansion and default reflinking
> >> which might preclude cp(1) from using this call in most cases, but I will
> >> test and try to use it. coreutils has heuristics for determining if files
> >> are remote, which we might use to restrict to that use case.
> > 
> > Can you explain why reflinking and hole expansion are an issue if done
> > locally and not if done remotely?  I'd really like to make the call as
> > usable as possible for everyone, but we really need clear sem�ntics for
> > that.
> 
> Fair point on local vs remote. I was just assuming that remote
> copy offload would not do reflinking on the backend, or at
> least wasn't an exposed option over the remote interface.

The server could definitely do a reflink.  More generally, from the
description of the NFS COPY operation:

	https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-39#page-64

	If the copy completes successfully, either synchronously or
	asynchronously, the data copied from the source file to the
	destination file MUST appear identical to the NFS client.
	However, the NFS server's on disk representation of the data in
	the source file and destination file MAY differ.  For example,
	the NFS server might encrypt, compress, deduplicate, or
	otherwise represent the on disk data in the source and
	destination file differently.

> I get the impression that you think reflinking should be hidden
> from the user, i.e. cp(1) should not have had the --reflink option
> (for the last 6 years)?  I'm not convinced of that, and even so
> I think lower level interfaces would benefit from finer grained options.
> This would be especially useful since there is no general interface
> to reflink at present. I was happy with the reflink control options,
> thinking the extra control could allow cp to use this by default.

Maybe that's a case for Christoph's "clone" operation.

I agree with him that it makes sense to allow the filesystem to
implement "copy" using reflink or similar tricks under the covers.  And
that in fact it's difficult to imagine how you'd prevent that in the
presence of layers of filesystem or block protocols underneath.

That "cp" flag seems strange to me, but if "cp" wants to take advantage
of a copy system call while continuing to make something like that
distinction then I suppose it could fallocate the destination range file
after the copy.

--b.

> > Also note that Annas current series allows for hole filling - any decent
> > implementation should not do them, but that's really a quality of
> > implementation and not an interface issue.
> 
> I think you're saying the default `cp --sparse=auto` operation
> could rely on copy_file_range(...complete file...), while
> cp --sparse={always,never} would have to iterate over the
> file, punching or filling holes as appropriate. I thought
> Anna indicated differently wrt splice filling holes by default.
> 
> TBH I'm not clear on the semantics of the current implementation,
> so need to test the above in various cases.
> 
> thanks,
> Pádraig.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
