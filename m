Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45584 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750934AbdEDM6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 08:58:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87fugl3c22.fsf@rasmusvillemoes.dk>
References: <87fugl3c22.fsf@rasmusvillemoes.dk> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 May 2017 13:58:50 +0100
Message-ID: <14979.1493902730@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> > +const struct file_operations fs_fs_fops = {
> > +	.read		= fs_fs_read,
> > +	.write		= fs_fs_write,
> > +	.release	= fs_fs_release,
> > +	.llseek		= no_llseek,
> > +};
> > +
> 
> static const struct ?

No.  It's used in the next patch to validate the fd passed to sys_fsmount():

	if (f.file->f_op != &fs_fs_fops)
		goto err_fsfd;

David
