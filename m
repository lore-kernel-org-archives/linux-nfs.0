Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932300AbbDMMoa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 08:44:30 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <552BB530.50405@gmail.com>
References: <552BB530.50405@gmail.com> <5527C9A0.6030502@gmail.com> <30571.1428924822@warthog.procyon.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fscache: put reference of parent's usage and n_children
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 13 Apr 2015 13:44:24 +0100
Message-ID: <32264.1428929064@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kinglong Mee <kinglongmee@gmail.com> wrote:

> > Good catch.  Though it might be preferable to only increment the counters if
> > the list_add() is done.
> 
> Thanks for your comments, that's great.
> I will update and resend those two patch.

In fact, kmem_cache_free() can be called instead of
fscache_relinquish_cookie() in that case.

David
