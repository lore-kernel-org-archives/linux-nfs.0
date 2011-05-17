From: bpm@sgi.com
Subject: Re: [PATCH] nfs-utils: getexportent interprets -test-client- as
	default options
Date: Tue, 17 May 2011 09:05:47 -0500
Message-ID: <20110517140547.GI11654@sgi.com>
References: <20110512131810.25028.50931.stgit@nfs3> <4DD14CE9.1070301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50903 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754939Ab1EQOHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 10:07:07 -0400
In-Reply-To: <4DD14CE9.1070301-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Steve,

On Mon, May 16, 2011 at 12:12:25PM -0400, Steve Dickson wrote:
> On 05/12/2011 09:18 AM, Ben Myers wrote:
> > With commit 1374c3861abdc66f3a1410e26cc85f86760b51dd Neil added a -test-client-
> > export to test the exportability of filesystems when exportfs is run.  When
> > using the old cache controls (i.e. /proc/fs/nfsd is not mounted) exportfs will
> > read /proc/fs/nfs/exports and find these test client entries.  The dash at the
> > beginning of -test-client- will be cause getexportent to look for default
> > options in the rest of the string, which test-client- will not match:
> > 
> > exportfs: /proc/fs/nfs/exports:1: unknown keyword "test-client-(rw"
> > 
> > This patch resolves the problem by testing for -test-client- string in the
> > check for default arguments.
> > 
> > Signed-off-by: Ben Myers <bpm@sgi.com>
> > ---
> >  support/nfs/exports.c |    9 ++++++---
> >  1 files changed, 6 insertions(+), 3 deletions(-)
> > 
> > diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> > index 6acb2b6..7e29155 100644
> > --- a/support/nfs/exports.c
> > +++ b/support/nfs/exports.c
> > @@ -142,9 +142,12 @@ getexportent(int fromkernel, int fromexports)
> >  		return NULL;
> >  	}
> >  	first = 0;
> > -		
> > -	/* Check for default options */
> > -	if (exp[0] == '-') {
> > +
> > +	/*
> > +	 * Check for default options.  The test client string does not indicate
> > +	 * default arguments.
> > +	 */
> > +	if (exp[0] == '-' && strncmp(exp, "-test-client-", 13) != 0) {
> >  		if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
> >  			return NULL;
> If I'm understanding you correctly, when using the old cache controls
> and when processing exports that are already exported (exports that 
> are in /proc/fs/nfs/exports) will cause this problem.

Exactly.

> If this indeed is the case, I think it's a bit cleaner if we
> use the 'fromkernel' argument to decide if the '-' options
> should or should not be processed. Something like:
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 6acb2b6..e4e9375 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -144,7 +144,7 @@ getexportent(int fromkernel, int fromexports)
>         first = 0;
>                 
>         /* Check for default options */
> -       if (exp[0] == '-') {
> +       if (exp[0] == '-' && !fromkernel) {
>                 if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
>                         return NULL;
> 

Ok, I'll try that on.

Thanks,
	Ben
