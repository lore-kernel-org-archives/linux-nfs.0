Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754542Ab2DMMJs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 08:09:48 -0400
Date: Fri, 13 Apr 2012 08:09:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, pstaubach@exagrid.com, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120413080927.72cca80f@tlielax.poochiereds.net>
In-Reply-To: <20120413120232.GA27179@umich.edu>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413120232.GA27179@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 13 Apr 2012 08:02:32 -0400
Jim Rees <rees@umich.edu> wrote:

> Jeff Layton wrote:
> 
>   +retry:
>    	error = user_path_at(dfd, filename, lookup_flags, &path);
>    	if (error)
>    		goto out;
>    
>    	error = vfs_getattr(path.mnt, path.dentry, stat);
>   +	should_retry = error == -ESTALE ? retry_estale(path.dentry) : false;
>    	path_put(&path);
>   +	if (should_retry) {
>   +		lookup_flags |= LOOKUP_REVAL;
>   +		goto retry;
>   +	}
>    out:
>    	return error;
>    }
> 
> This is starting to look like FORTRAN.  Maybe turn this into a "do while"?
> Then you could make the "goto out" into a break and get rid of them both.

Sure, that's doable. If we want to do a finite number of retries that
may be preferable anyway.

-- 
Jeff Layton <jlayton@redhat.com>
