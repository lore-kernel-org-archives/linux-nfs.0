Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0139.hostedemail.com ([216.40.44.139]:44743 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750737AbdECSgy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 14:36:54 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave05.hostedemail.com (Postfix) with ESMTP id D14C5185120
        for <linux-nfs@vger.kernel.org>; Wed,  3 May 2017 18:26:43 +0000 (UTC)
Message-ID: <1493835998.22125.15.camel@perches.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Joe Perches <joe@perches.com>
To: Jeff Layton <jlayton@poochiereds.net>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Date: Wed, 03 May 2017 11:26:38 -0700
In-Reply-To: <1493835238.3180.7.camel@poochiereds.net>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <1493835238.3180.7.camel@poochiereds.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-03 at 14:13 -0400, Jeff Layton wrote:
> On Wed, 2017-05-03 at 17:04 +0100, David Howells wrote:
> > Introduce a mount context concept.

trivia:

> > static int selinux_mount_ctx_option(struct mount_context *mc, char *opt)
> > +{
[]
> > +	if (opts->mnt_opts) {
> > +		oo = kmalloc((opts->num_mnt_opts + 1) * sizeof(char *),
> > +			     GFP_KERNEL);
> > +		if (!oo)
> > +			return -ENOMEM;
> > +		memcpy(oo, opts->mnt_opts, opts->num_mnt_opts * sizeof(char *));
> > +		oo[opts->num_mnt_opts] = NULL;
> > +		old = opts->mnt_opts;
> > +		opts->mnt_opts = oo;
> > +		kfree(old);
> > +	}

krealloc would probably be more efficient and possible
readable as likely there's already padding in the original
allocation.

Are there no locking constraints?

