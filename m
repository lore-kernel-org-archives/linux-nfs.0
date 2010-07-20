From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/5] nfsd: don't try to shut down nfs4 state handling
 unless it's up
Date: Mon, 19 Jul 2010 20:54:50 -0400
Message-ID: <20100719205450.3a194116@corrin.poochiereds.net>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
	<1279572608-7234-2-git-send-email-jlayton@redhat.com>
	<20100719220837.GA31074@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760973Ab0GTAwR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 20:52:17 -0400
In-Reply-To: <20100719220837.GA31074@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 19 Jul 2010 18:08:37 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jul 19, 2010 at 04:50:04PM -0400, Jeff Layton wrote:
> > If someone tries to shut down the laundry_wq while it isn't up it'll
> > cause an oops.
> 
> nfs4_state_shutdown is called only from nfsd_last_thread, which is
> called only after svc_create_pooled, which is called only when
> nfs4_state_start() succeeds.
> 
> If you've actually seen this happen then there's something going on that
> I don't understand.
> 
> --b.

I've not seen this in current code, but this delta is a prerequisite
for the next patch in the series. It's possible for nfsd_serv to be
created (via the write_ports interface), but for the threads file never
to be written.

With the next patch in the series, the nfsd_serv can be torn down in an
error condition before the threads file is ever written and at that
point this patch is required to prevent panics.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
