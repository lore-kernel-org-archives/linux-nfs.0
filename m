Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:30782 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbbBWSDs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 13:03:48 -0500
Date: Mon, 23 Feb 2015 21:03:27 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] groups: integer underflow in groups_alloc()
Message-ID: <20150223180326.GC5116@mwanda>
References: <20150223154419.GA2542@mwanda>
 <87385w1rmd.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87385w1rmd.fsf@x220.int.ebiederm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 23, 2015 at 11:10:02AM -0600, Eric W. Biederman wrote:
> Dan Carpenter <dan.carpenter@oracle.com> writes:
> 
> > This is called from rsc_parse() with a use controlled value.  Say for
> > example that "gidsetsize" is negative, then we could end up allocating
> > less than sizeof(struct group_info) leading to memory corruption.
> 
> Right now it is the responsibility of the caller of groups_alloc to make
> certain that gidsetsize is a valid value, and the callers of
> groups_alloc who know what they are doing already validate this value.
> 
> Either the pattern of caller validates the messages needs to continue,
> or groups_alloc needs to be changed and all of the callers need to be
> updated.
> 
> Changing groups_alloc for one particular caller is just going to cause
> maintenance problems.
> 

This only affects NFS so let's hear from them if this limit is correct
and decide from there.

regards,
dan carpenter

