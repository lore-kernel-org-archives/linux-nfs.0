From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] new statd [take 2]
Date: Wed, 5 Aug 2009 13:15:54 -0400
Message-ID: <20090805131554.67eb15bc@tlielax.poochiereds.net>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55049 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934303AbZHERQA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 13:16:00 -0400
In-Reply-To: <20090805143550.12866.8377.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 05 Aug 2009 10:45:30 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Apparently there is a 100KB per-email size limit imposed by
> vger.kernel.org.  I've broken up the large statd patch, and
> postponed the nfs(8) man page patches to another day.
> 
> Yesterday it was decided that:
> 
>   [PATCH 3/5] statd: change default state dir to /var/lib/nfs/statd
> 
> was overkill. That one has been dropped from this series.
> 
> The first two of the present patches introduce the .c files under
> utils/new-statd/ .  The next patch adds actools infrastructure for
> building the new statd and sm-notify executables.  The last patch
> adds two new man pages for statd and sm-notify.
> 
> The old statd remains in utils/statd.  If sqlite3 and TI-RPC is
> present on the build system, and TI-RPC is enabled during
> configuration, the new statd is built and installed instead of the
> old one.
> 
> See the description in the first patch for more details on the
> features of the new implementation.
> 

Nice work, Chuck.

Rewriting statd from scratch is a pretty bold step, but I think it's
warranted.

I've been testing this new implementation over several iterations and
the recent ones have worked well for me so far. I've also walked
through the code and it all seems to make sense.

Acked-by: Jeff Layton <jlayton@redhat.com>
