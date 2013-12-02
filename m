Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab3LBQYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Dec 2013 11:24:09 -0500
Date: Mon, 2 Dec 2013 11:23:40 -0500
From: "J.Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Gao feng <gaofeng@cn.fujitsu.com>,
        Containers <containers@lists.linux-foundation.org>,
        linux-fsdevel@vger.kernel.org, Aditya Kali <adityakali@google.com>,
        Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Dumazet <edumazet@google.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
 point
Message-ID: <20131202162340.GH1960@fieldses.org>
References: <52899D09.5080202@cn.fujitsu.com>
 <20131118140830.GA22075@mail.hallyn.com>
 <20131118180134.GA24156@mail.hallyn.com>
 <87k3g5gnuv.fsf@xmission.com>
 <20131126181043.GA25492@mail.hallyn.com>
 <87siui1z1g.fsf_-_@xmission.com>
 <8738mi1yya.fsf_-_@xmission.com>
 <20131130061525.GY10323@ZenIV.linux.org.uk>
 <20131130170226.GZ10323@ZenIV.linux.org.uk>
 <20131202164359.4f4f2c94@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131202164359.4f4f2c94@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 04:43:59PM +1100, NeilBrown wrote:
> On Sat, 30 Nov 2013 17:02:26 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> 
> > BTW, what happens if svc_export_request() ends up with pathname filling
> > almost all space left, so that qword_add(bpp, blen, pth) right after the
> > call of d_path() in there overwrites the beginning of d_path() output?
> > Neil?  And while we are at it, handling of overflow in there looks also
> > looks fishy...
> 
> In this case the returned *blen will be negative so cache_request() in
> net/sunrpc/cache.h will return -EAGAIN.
> cache_read() would then go into a tight loop, trying again and again to
> create the request, but it will never fit in the buffer.
> 
> I guess maybe an EINVAL might help there, plus code to skip over impossible
> requests.
> Maybe the following.  We'd need to double check that no ->cache_request
> function can fail in a way that is worth retrying, but I doubt they would.
> 
> Any thoughts Bruce?

Yes, the cache_request failures are all similarly fatal overflows.

Uh, not sure if I remember how the data structures here work: so
userspace is now going to get an -EINVAL on read, and may just end up
retrying the read?

Or do we hit the "need to release rq" case in cache_read and just
discard the request?

--b.

> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index a72de074172d..a065f827e2a3 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -748,7 +748,7 @@ static int cache_request(struct cache_detail *detail,
>  
>  	detail->cache_request(detail, crq->item, &bp, &len);
>  	if (len < 0)
> -		return -EAGAIN;
> +		return -EINVAL;
>  	return PAGE_SIZE - len;
>  }
>  
> @@ -788,6 +788,11 @@ static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
>  
>  	if (rq->len == 0) {
>  		err = cache_request(cd, rq);
> +		if (err == -EINVAL) {
> +			spin_lock(&queue_lock);
> +			list_move(&rp->q.list, &rq->q.list);
> +			spin_unlock(&queue_lock);
> +		}
>  		if (err < 0)
>  			goto out;
>  		rq->len = err;


