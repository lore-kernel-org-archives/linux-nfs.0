Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:52110 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbbBWVQK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Feb 2015 16:16:10 -0500
Date: Mon, 23 Feb 2015 16:16:07 -0500
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] groups: integer underflow in groups_alloc()
Message-ID: <20150223211607.GB28635@fieldses.org>
References: <20150223154419.GA2542@mwanda>
 <87385w1rmd.fsf@x220.int.ebiederm.org>
 <20150223180326.GC5116@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150223180326.GC5116@mwanda>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 23, 2015 at 09:03:27PM +0300, Dan Carpenter wrote:
> On Mon, Feb 23, 2015 at 11:10:02AM -0600, Eric W. Biederman wrote:
> > Dan Carpenter <dan.carpenter@oracle.com> writes:
> > 
> > > This is called from rsc_parse() with a use controlled value.  Say for
> > > example that "gidsetsize" is negative, then we could end up allocating
> > > less than sizeof(struct group_info) leading to memory corruption.
> > 
> > Right now it is the responsibility of the caller of groups_alloc to make
> > certain that gidsetsize is a valid value, and the callers of
> > groups_alloc who know what they are doing already validate this value.
> > 
> > Either the pattern of caller validates the messages needs to continue,
> > or groups_alloc needs to be changed and all of the callers need to be
> > updated.
> > 
> > Changing groups_alloc for one particular caller is just going to cause
> > maintenance problems.
> > 
> 
> This only affects NFS so let's hear from them if this limit is correct
> and decide from there.

I think that's probably the correct check, sure.

Putting it in rsc_parse sounds reasonable.

--b.
