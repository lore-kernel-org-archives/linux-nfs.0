Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:42981 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbaHaOvY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Aug 2014 10:51:24 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so4507700qcx.27
        for <linux-nfs@vger.kernel.org>; Sun, 31 Aug 2014 07:51:24 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 31 Aug 2014 10:51:21 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/10] locks: move i_lock acquisition into
 generic_*_lease handlers
Message-ID: <20140831105121.65086ded@tlielax.poochiereds.net>
In-Reply-To: <20140824161134.GJ15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
	<1408804878-1331-9-git-send-email-jlayton@primarydata.com>
	<20140824160634.GG15908@infradead.org>
	<20140824161134.GJ15908@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 24 Aug 2014 09:11:34 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Aug 24, 2014 at 09:06:34AM -0700, Christoph Hellwig wrote:
> > We really should split a lm_release from lm_change, the way it is
> > used is highly confusing.  In addition I think a lot of code
> > currently in lease_modify should move here instead, e.g. something like:
> 
> At this point the old lm_change actually becomes superflous if we
> simply disallow changes for delegation.
> 

This sounds like a reasonable change, but I think it'll be easier to
implement a little later once we've done some cleanup and change how
file locks are handled. I'm going to leave this out of this current
patchset, but I'll keep it in mind for a later cleanup.

-- 
Jeff Layton <jlayton@primarydata.com>
