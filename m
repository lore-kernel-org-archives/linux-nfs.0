Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710Ab1BIPOK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 10:14:10 -0500
Date: Wed, 9 Feb 2011 10:14:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/6] nfsd4: split up nfsd_break_deleg_cb
Message-ID: <20110209151402.GA13624@pad.home.fieldses.org>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
 <1297227351-15365-2-git-send-email-bfields@redhat.com>
 <20110209050118.GA2485@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110209050118.GA2485@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 09, 2011 at 12:01:18AM -0500, Christoph Hellwig wrote:
> > +static
> > +void nfsd_break_deleg_cb(struct file_lock *fl)
> 
> Very weird formatting.  Please make it either
> 
> static void nfsd_break_deleg_cb(struct file_lock *fl)
> 
> or
> 
> static void
> nfsd_break_deleg_cb(struct file_lock *fl)
> 
> but never just put the static on a line of it's own.

Agreed.  Those two lines were actually untouched by this patch, no
matter what diff thinks--but I'm just as happy to fix it up while we're
there; done.

--b.
