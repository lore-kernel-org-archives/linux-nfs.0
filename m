Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36705 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbHJLcC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 07:32:02 -0400
Received: by ykeo23 with SMTP id o23so136213151yke.3
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 04:32:01 -0700 (PDT)
Date: Mon, 10 Aug 2015 07:31:59 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 04/18] nfsd: add a new struct file caching facility
 to nfsd
Message-ID: <20150810073159.1e87438a@tlielax.poochiereds.net>
In-Reply-To: <20150810082807.GA28480@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-5-git-send-email-jeff.layton@primarydata.com>
	<20150809071702.GD9772@infradead.org>
	<20150809071932.3ef4d0a2@tlielax.poochiereds.net>
	<20150810082807.GA28480@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Aug 2015 01:28:07 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > I started looking at extending the nfs4_file cache to NFSv2/3, but it's
> > actually rather difficult...
> > 
> > We traditionally haven't dealt with share/deny modes in NFSv3, so we'd
> > need a mechanism to bypass all of that stuff for legacy protocols. We'd
> > also have to convert that cache from one that frees objects when the
> > last one is put to one that keeps them around for a bit.
> > 
> > That also means that the v2/3 opens have to keep around extra fields
> > that aren't really needed, and deal with the really godawful locking of
> > the NFSv4 code.
> > 
> > I really think this approach is a better one. We can still use this
> > cache from the NFSv4 code and wiring it in shouldn't be too hard. It's
> > mostly a matter of plumbing in struct nfsd_file objects where that code
> > is passing around struct file objects now.
> 
> Ok.  I'd still like to it wired up to NFSv4 - with my changes to make all
> temporary file opens happens from nfs4_preprocess_stateid_op it should
> be fairly simple.


Ok, I should be able to add that in. I'll plan to do so before I send
out a v3 of the patchset.

-- 
Jeff Layton <jlayton@poochiereds.net>
