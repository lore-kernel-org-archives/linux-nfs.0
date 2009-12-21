From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: starting 90-second grace period : leasetime less than 10
Date: Mon, 21 Dec 2009 14:36:30 -0500
Message-ID: <20091221193630.GB22943@fieldses.org>
References: <f5b5ebae0912140410t2814d7bck688549103b3104ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59778 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbZLUTgP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Dec 2009 14:36:15 -0500
In-Reply-To: <f5b5ebae0912140410t2814d7bck688549103b3104ea-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 14, 2009 at 05:40:20PM +0530, Tharindu Rukshan Bamunuarachchi wrote:
> I can not set nfs4leasetime value less than 10 seconds.
> 
> there is a verification in __write_leasetime(). (lease < 10 || lease > 3600)
> 
> I am going to change this to ~2 second (to make NFS HA failover happen
> in less than 10 seconds with HeartBeat).
> 
> Any reason why is this checked for 10 (i.e. lease < 10) ... ?

No reason for that particular limit, but this does mean every client
will have to send a small NFSv4 operation to the server at least once
every 2 seconds as long as it holds any opens or other state. And if the
network goes down for more than 2 seonds the client will probably lose
that state.

Is it the grace-period time on the takeover server that you're trying to
limit?

--b.

> 
> 
> 
> 
> 
> static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
> {
>         /* if size > 10 seconds, call
>          * nfs4_reset_lease() then write out the new lease (seconds) as reply
>          */
>         char *mesg = buf;
>         int rv, lease;
> 
>         if (size > 0) {
>                 if (nfsd_serv)
>                         return -EBUSY;
>                 rv = get_int(&mesg, &lease);
>                 if (rv)
>                         return rv;
>                 if (lease < 10 || lease > 3600)
>                         return -EINVAL;
>                 nfs4_reset_lease(lease);
>         }
> 
>         return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
>                                                         nfs4_lease_time());
> }
> 
> -- 
> Tharindu Rukshan Bamunuarachchi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
