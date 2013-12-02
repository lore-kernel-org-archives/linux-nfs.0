Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35535 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485Ab3LBPVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 10:21:04 -0500
Date: Mon, 2 Dec 2013 07:21:02 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Sebastian Feld <sebastian.n.feld@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Joshuah Hurst <joshhurst@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Linux client access to NFSv4 Alternate Data Streams (O_XATTR)?
Message-ID: <20131202152102.GA20458@infradead.org>
References: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
 <5B7CDA5C-C3F1-4CFD-9A72-013523068FBB@primarydata.com>
 <CAHnbEG+cJGjx7o=+ZASNo7ddc0O9hYG4fE0EAQ2hoh688nBBeQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHnbEG+cJGjx7o=+ZASNo7ddc0O9hYG4fE0EAQ2hoh688nBBeQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 03:27:20PM +0100, Sebastian Feld wrote:
> This isn't a Solaris-specific extension, its part of the original Sun
> NFSv4 spec. Unfortunately the ARC/ARchitecture Cases from
> Opensolaris.org are no longer available, otherwise the background,
> e.g. feature parity with CIFS/NTFS, and the overall usefulness of such
> a feature, would be clearer.

It's a dumb part of the spec, and Linux has no intent support pretty
braindead file/directory mixups.  Just store all your separate streams
in separate files, that's how it's implemented underneath anyway.

