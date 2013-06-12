Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f42.google.com ([209.85.212.42]:51567 "EHLO
	mail-vb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757198Ab3FLQWI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jun 2013 12:22:08 -0400
Received: by mail-vb0-f42.google.com with SMTP id i3so6009930vbh.29
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jun 2013 09:22:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130612153936.GB32569@fieldses.org>
References: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com>
	<20130611195140.GA29634@fieldses.org>
	<51B7DE9C.6080703@talpey.com>
	<20130612153936.GB32569@fieldses.org>
Date: Wed, 12 Jun 2013 21:52:07 +0530
Message-ID: <CAEfL3Kk=L5JNN_2FNaF0BbVBpo-zvXMQr5QX7pHd0i_Kf=5E_g@mail.gmail.com>
Subject: Re: why does nfsd write not use splice
From: Sandeep Joshi <sanjos100@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

Splice can be implemented independent of RDMA.  It is supposed to
transfer pages between two file descriptors.  I found some postings on
lkml from 2006 where Linus says it is quite possible to splice from a
socket to a file.

See the paragraph:
" For filesystems, splice support tends to be really easy (both read
and write). For other things, it depends a bit. But unlike sendfile(),
it really is quite possible to splice _from_ a socket too, not just
_to_ a socket. But no, that case hasn't been written yet."
 http://yarchive.net/comp/linux/splice.html

Larry McVoy's 1997 proposal for adding splice support to the  kernel
can be read at ftp.tux.org/pub/sites/ftp.bitmover.com/pub/splice.ps.gz

Perhaps I should have opened this thread on lkml to determine if
splice from socket to file is still feasible..

-Sandeep

On Wed, Jun 12, 2013 at 9:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Jun 11, 2013 at 10:36:12PM -0400, Tom Talpey wrote:
> > On 6/11/2013 3:51 PM, J. Bruce Fields wrote:
> > >On Sun, Jun 09, 2013 at 01:05:16PM +0530, Sandeep Joshi wrote:
> > >>Is there a reason as to why the nfsd server does not use splice in the
> > >>write calls - nfsd_vfs_write() ?  Is there some structural limitation
> > >>or is it just something nobody got around to implementing ?
> > >>
> > >>I have looked at the source back to the 2.6.x kernels and it seems
> > >>only nfsd_vfs_read() has ever used splice/sendfile.
> > >>http://lxr.linux.no/linux+v3.9.5/fs/nfsd/vfs.c
> > >
> > >I don't actually know how splice_write works.... I assume to avoid a
> > >copy we'd have to place the incoming write data into pages already
> > >correctly aligned.  That would be an interesting trick.
> >
> > NFS-RDMA does that, by design. ;-)
>
> So teaching nfsd to take advantage of splice in the rdma case could be
> a doable project for someone?
>
> I was thinking about NFSv4/tcp, in which case I guess we'd need to start
> parsing the xdr in the tcp receive code.
>
> --b.
