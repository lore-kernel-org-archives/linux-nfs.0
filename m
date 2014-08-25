Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f42.google.com ([209.85.213.42]:57910 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088AbaHYBT4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 21:19:56 -0400
Received: by mail-yh0-f42.google.com with SMTP id a41so10397429yho.15
        for <linux-nfs@vger.kernel.org>; Sun, 24 Aug 2014 18:19:55 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 24 Aug 2014 21:19:53 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/10] locks: define a lm_setup handler for leases
Message-ID: <20140824211953.1dfd7f77@synchrony.poochiereds.net>
In-Reply-To: <20140824155858.GF15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
	<1408804878-1331-8-git-send-email-jlayton@primarydata.com>
	<20140824155858.GF15908@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 24 Aug 2014 08:58:58 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> I like this change a lot!  But one caveat:
> 
> > +	/*
> > +	 * Despite the fact that it's an int return function, __f_setown never
> > +	 * returns an error. Just ignore any error return here, but spew a
> > +	 * WARN_ON_ONCE in case this ever changes.
> > +	 */
> > +	WARN_ON_ONCE(__f_setown(filp, task_pid(current), PIDTYPE_PID, 0));
> 
> I don't think this is a good idea.  The errors in __f_setown come from
> the security modules, and they could change easily.  If you can convince
> the LSM people to change their file_set_fowner routine to return void
> we could change __f_setown to return void as well and be done with it,
> but without that this looks too dangerous.
> 

Understood. I figured that this might not be acceptable. I can make
this propagate the error back up, but cleaning up the mess may not be
easy. I'll see what I can do.

Note that the error handling in the existing code looks wrong to me
too. The lease gets added to the list (or updated), the fasync handler
gets set up. Then, if __f_setown returns an error, the code just
returns that error without unwinding anything.

-- 
Jeff Layton <jlayton@primarydata.com>
