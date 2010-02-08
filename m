Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780Ab0BHVek (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 16:34:40 -0500
Date: Mon, 8 Feb 2010 16:34:32 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: release reference to nsm_handle in
 nlm_host_rebooted
Message-ID: <20100208163432.583a8153@tlielax.poochiereds.net>
In-Reply-To: <20100208211908.GB14942@fieldses.org>
References: <1265400552-8375-1-git-send-email-jlayton@redhat.com>
	<20100208211908.GB14942@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 8 Feb 2010 16:19:08 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Feb 05, 2010 at 03:09:12PM -0500, Jeff Layton wrote:
> > nsm_reboot_lookup takes a reference to the nsm_handle that it returns,
> > but nlm_host_rebooted never releases that reference.
> 
> Makes sense to me; I'll apply to the nfsd tree.
> 
> (How did you run across this?)
> 
> --b.
> 

Thanks,

When I was testing Chuck's statd patches, I went through some rather
strange scenarios, mostly with Linux as the client. In some cases, we
noticed that an SM_UNMON would occur when umounting a NFS filesystem,
and in others it wouldn't. These two patches are the result of tracking
down the cause. With them in place, a SM_UNMON gets issued much more
consistently in the face of server reboots.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
