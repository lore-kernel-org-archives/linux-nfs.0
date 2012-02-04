Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.chillheid.nl ([195.189.117.195]:48397 "EHLO
	mail.chillheid.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989Ab2BDNhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Feb 2012 08:37:47 -0500
From: Koen Wilde <koen@chillheid.nl>
Subject: Re: oops when copying a file from a nfs mount
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
In-Reply-To: <1328312712.5335.17.camel@lade.trondhjem.org>
References: <20120203223604.98C91405DC@mail.chillheid.nl> <20120203230811.GH2999@fieldses.org> <1328312712.5335.17.camel@lade.trondhjem.org>
Date: Sat, 04 Feb 2012 14:37:45 +0100
Message-Id: <20120204133745.B3607405DC@mail.chillheid.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 Feb 2012 23:45:12 +0000, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> It is obvious: firstly acl_scratch is only needed (and allocated) if the
> npages > 1. Secondly, the call to xdr_set_scratch_buffer() needs to be
> done in the decoder, not the encoder...
> 
> The following patch should fix it.
> 
I can confirm the oops indeed doesn't occur anymore after applying this patch
to v3.2.2 :)

-- Koen
