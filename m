Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:33151 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbCUOHD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Mar 2015 10:07:03 -0400
Received: by yhpt93 with SMTP id t93so51292941yhp.0
        for <linux-nfs@vger.kernel.org>; Sat, 21 Mar 2015 07:07:02 -0700 (PDT)
Date: Sat, 21 Mar 2015 10:06:57 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd use after free in 4.0-rc
Message-ID: <20150321100657.32ff0340@tlielax.poochiereds.net>
In-Reply-To: <20150316182810.GA4690@infradead.org>
References: <20150315125614.GA766@infradead.org>
	<20150315180811.02847842@tlielax.poochiereds.net>
	<20150316114648.GA7432@infradead.org>
	<20150316155845.GC12231@fieldses.org>
	<20150316182810.GA4690@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/jmi_l710+Q9ZB_pznIc9A.y"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/jmi_l710+Q9ZB_pznIc9A.y
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Mon, 16 Mar 2015 11:28:10 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Mar 16, 2015 at 11:58:45AM -0400, J. Bruce Fields wrote:
> > > 3240		list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> > > 3241		spin_lock(&fp->fi_lock);
> > > 3242		list_add(&stp->st_perfile, &fp->fi_stateids);
> > 
> > I assume you're testing only NFS v4.1?
> 
> Exactly. I'm testing with a version of this patch applied to force 4.1:
> 
> http://git.infradead.org/users/hch/pnfs.git/commitdiff/72ef9b95aaed593ac061bb380bc27ced4fd67b4b

I've been using 4.2, fwiw...

So far, this bug has turned out to be pretty elusive, I've looked all
over the so_count handling and I don't see anywhere that we've got a
refcount imbalance. I must be missing something, but it all looks right
AFAICT.

I've also instrumented the code to look for 0->1 transitions on the
so_count, and that hasn't fired. I also looked to see whether Bruce's
hunch about the nfsd4_find_existing_open thing might be a problem with
the sc_count going 0->1 since we're taking a reference there w/o
holding the cl_lock. I haven't seen that happen either.

Mostly when I see this bug without memory poisoning enabled, it
manifests itself as list corruption in one of the stateowner lists
during nfsd4_close. Curiously, the attached patch seems to make that
problem go away, but the generic/011 test seems to fail most of the
time with this in the log:

    Cannot chdir out of pid directory: Stale file handle

...but if I turn up poisoning of the nfsd4_openowners slab then I get
an oops similar to what HCH is seeing.

-- 
Jeff Layton <jeff.layton@primarydata.com>

--MP_/jmi_l710+Q9ZB_pznIc9A.y
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-nfsd-poison-so_owner.data-before-freeing-it.patch


--MP_/jmi_l710+Q9ZB_pznIc9A.y--
