Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37716 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947AbcGMPf0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 11:35:26 -0400
Date: Wed, 13 Jul 2016 11:34:56 -0400
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: ELOOP from getdents
Message-ID: <20160713153456.GB9180@fieldses.org>
References: <87lh1fizyy.fsf@thinkpad.rath.org>
 <87vb0a8oyc.fsf@thinkpad.rath.org>
 <E35BAE5E-4D9B-44B4-98B3-54BA36AC895B@primarydata.com>
 <87d1mh1ssl.fsf@thinkpad.rath.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87d1mh1ssl.fsf@thinkpad.rath.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 13, 2016 at 05:06:34PM +0200, Nikolaus Rath wrote:
> On Jul 12 2016, Trond Myklebust <trondmy@primarydata.com> wrote:
> > In NFSv4, offsets 1 and 2 are reserved:
> > https://tools.ietf.org/html/rfc7530#section-16.24
> 
> Ah, that explains it. Thanks!
> 
> I was assuming that I could export any "proper" unix file system over
> NFS - and as far as I know, the rest of the VFS does not make any
> assumptions (or reservations) about readdir offsets. Are there other
> such constraints? I looked at the RFC, but it's rather hard to extract
> that specific information...

Local filesystems only need to generate readdir offsets that work for a
given open, while exportable filesystem need to readdir offsets that
they can still interpret at an arbitrary future point (possibly after a
reboot).

The other main requirements are on filehandles.

An in-kernel filesystem shouldn't define export_ops if it doesn't
support export, so should be able to fail export attempts early on
rather than seeming to work and then behaving weird later, as in this
case.  I don't know if there's a comparable way for a fuse filesystem to
say "don't even try exporting me".

--b.

> 
> Best,
> Nikolaus
> 
> -- 
> GPG encrypted emails preferred. Key id: 0xD113FCAC3C4E599F
> Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F
> 
>              »Time flies like an arrow, fruit flies like a Banana.«
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
