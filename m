Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4826 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010Ab3JDDPQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Oct 2013 23:15:16 -0400
Date: Thu, 3 Oct 2013 23:14:26 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@primarydata.com>
Message-ID: <1002088145.185.1380856466233.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <20131003130348.GA9634@infradead.org>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Admittedly, I'm not sure.  I'm convinced it will be a big help to have pre-integrated in
Ganesha, I was only speculating wrt Linux/knfsd.

Matt

----- "Christoph Hellwig" <hch@infradead.org> wrote:

> On Thu, Oct 03, 2013 at 08:58:08AM -0400, Matt W. Benjamin wrote:
> > Hi,
> > 
> > I think saying exofs is a proof of concept/toy is missing the
> point.
> > Exofs is an implementation baseline that provides insight into the
> > scalability/performance values that a pnfs implementation can
> achieve,
> > and potentially how to achieve them.
> 
> Speaking like a true diplomat..
> 
> What amount of that data are we going to get by merging an exofs
> based
> pnfs server that we haven't been able to gather with it out of tree
> for
> the last 6 years?  How is merging it and complicating the nfs servers
> for it going to provide a benefit outside of the small group of about
> a
> dozend people that actively care about the T10 OSD support in Linux?
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
