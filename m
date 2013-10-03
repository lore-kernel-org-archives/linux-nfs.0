Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4657 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248Ab3JCNAP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Oct 2013 09:00:15 -0400
Date: Thu, 3 Oct 2013 08:58:08 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@primarydata.com>
Message-ID: <592699116.20.1380805088543.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1588761701.18.1380804942396.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I think saying exofs is a proof of concept/toy is missing the point.
Exofs is an implementation baseline that provides insight into the
scalability/performance values that a pnfs implementation can achieve,
and potentially how to achieve them.

Matt

----- "Christoph Hellwig" <hch@infradead.org> wrote:

> On Thu, Oct 03, 2013 at 03:29:06PM +0300, Benny Halevy wrote:
> > I picked gfs2 as the initial use case for simplicity and ease of
> review.
> > If there is a rough consensus that it's useless and not worthy of
> inclusion
> > then the one we care about the most is exofs that has a more
> complete pnfs
> > implementation.
> 
> This was in reference to file layout implementation details, so exofs
> isn't a contender there.
> 
> As far as exofs is concerned a pnfs implementation based on it has
> just
> as much toy status as the current gfs2 one.  While the pnfs side of
> it
> might as well be a lot better, a filesystem that lacks all the
> integrity
> and scalability features developed in the last 30 years can't be
> considered more than a proof of concept.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
