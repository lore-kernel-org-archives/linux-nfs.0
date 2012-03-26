Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60476 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184Ab2CZUCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Mar 2012 16:02:13 -0400
Date: Mon, 26 Mar 2012 16:02:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 0/8] nfsd: overhaul the client name tracking code
Message-ID: <20120326200212.GD26254@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <20120323170630.GB6089@fieldses.org>
 <20120323132618.60e7e28d@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120323132618.60e7e28d@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 23, 2012 at 01:26:18PM -0400, Jeff Layton wrote:
> On Fri, 23 Mar 2012 13:06:30 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Mar 21, 2012 at 09:52:01AM -0400, Jeff Layton wrote:
> > > This is the tenth iteration of this patchset. The primary motivation
> > > of this respin is to fix up some merge conflicts with some fixes that
> > > Bruce merged recently.
> > 
> > Thanks, these look fine.  I'm intending to merge for 3.4.  But I going
> > want to spend some more time investigating the callback bug that
> > excltest is triggering before committing to my for-3.4 branch.
> > 
> > --b.
> > 
> 
> Thanks, and totally understood. No need to muddy the waters by merging new code...

Having looked at it longer: first, I can't see how 4.1/krb5 callbacks
ever really worked.  That's a project for another day.  (Soon, but
probably not for 3.4.)

Second, after further testing it turns out that the failure isn't always
reproduceable after applying these patches, and is sometimes
reproduceable without.

Also, the patches look fine to me.

So, I'm pushing them out soon and should be sending Linus a pull request
in the next couple days.

--b.
