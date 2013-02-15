Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58623 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755870Ab3BOQay (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 11:30:54 -0500
Date: Fri, 15 Feb 2013 11:30:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tim Gardner <tim.gardner@canonical.com>, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH linux-next v2] lockd: nlmclnt_reclaim(): avoid stack
 overflow
Message-ID: <20130215163050.GL8343@fieldses.org>
References: <20130212211800.GG10267@fieldses.org>
 <1360770016-69586-1-git-send-email-tim.gardner@canonical.com>
 <20130214102038.52b1d292@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130214102038.52b1d292@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 14, 2013 at 10:20:38AM -0500, Jeff Layton wrote:
> On Wed, 13 Feb 2013 08:40:16 -0700
> Tim Gardner <tim.gardner@canonical.com> wrote:
> 
> > Even though nlmclnt_reclaim() is only one call into the stack frame,
> > 928 bytes on the stack seems like a lot. Recode to dynamically
> > allocate the request structure once from within the reclaimer task,
> > then pass this pointer into nlmclnt_reclaim() for reuse on
> > subsequent calls.
> > 
> > smatch analysis:
> > 
> > fs/lockd/clntproc.c:620 nlmclnt_reclaim() warn: 'reqst' puts
> >  928 bytes on stack
> > 
> > Also remove redundant assignment of 0 after memset.
> > 
> > Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > Cc: linux-nfs@vger.kernel.org
> > Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> > ---
> > 
> > Changes from v1 -- don't return -ENOMEM from a task thread because it is
> > not propagated to the task creator. Instead print an error message and return.
...
> Oops, just noticed there was a later version of this patch. Please
> disregard my earlier mail...
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks, applying.--b.
