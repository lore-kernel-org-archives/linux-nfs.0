Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380Ab3JBOEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 10:04:47 -0400
Date: Wed, 2 Oct 2013 10:04:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Meledandri <m.meledandri@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Issues with a rather unusual configured NFS server
Message-ID: <20131002140446.GC14808@fieldses.org>
References: <CACFbnrwWJz8her6a4PRn-a0sTF2ci2VY7xOdgRS3zhFpYfxfug@mail.gmail.com>
 <20131001143400.GI26382@fieldses.org>
 <CACFbnrxWCTnudK5GJK0=xpiE7xym=Jm4apMSbBHTHF-oavJP5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CACFbnrxWCTnudK5GJK0=xpiE7xym=Jm4apMSbBHTHF-oavJP5g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 01, 2013 at 09:24:34PM -0400, Marc Meledandri wrote:
> On Tue, Oct 1, 2013 at 10:34 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Sat, Sep 28, 2013 at 11:37:40AM -0400, Marc Meledandri wrote:
> >> I was pointed at this thread by the linux-ext4 folks as relevant to my
> >> issue on kernels in
> >> the 3.10.x series. I see this commit was tagged for 3.12-rc2 on git,
> >> and wondering if it will be
> >> rebased for previous kernels? Maybe my issue (oops at shutdown) is
> >> caused by something
> >> else entirely? Thanks!
> >
> > That patch probably should have been cc'd to stable for kernels since
> > 3.10....
> >
> > Do you have a reproduceable test case?  Would it be possible for you to
> > confirm that this fixes your problem if applied on top of 3.10.x?
> >
> > --b.
> >
> 
> Thanks for replying. Regarding confirmation, the patch does not apply
> cleanly to 3.10.x kernels, but needs to be backported/rebased. I began
> that process, as it's a small patch, but didn't want to step on, or
> conflict with other changes that hadn't been merged yet from the
> latest nfs codebase if such changes are forthcoming.

Oops, hadn't noticed the patch didn't apply to 3.10.x.  OK, let me know
when you have that.  In fact, if you could just send it to
stable@vger.kernel.org and cc: me then I'll ACK it.

--b.

> 
> Regarding STR, I was seeing this on vanilla kernels 3.10.10 and
> 3.10.11 on shutdown (hangs with oops), and didn't pin down the exact
> conditions. I have the simplest of nfs setups with a single
> export/mount point and single client. I've recently built 3.10.13 with
> no patches and will try to reproduce the oops. I think I need to leave
> a client connected during shutdown.
> 
> Will follow up with more info...
