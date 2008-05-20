From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove	signaling
 for shutdown
Date: Mon, 19 May 2008 19:04:22 -0700
Message-ID: <483231A6.9020809@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>	<4831F860.6050801@melbourne.sgi.com> <18482.4782.858347.981553@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:38957 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752853AbYETCGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 22:06:48 -0400
In-Reply-To: <18482.4782.858347.981553-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:

>  
> +static ssize_t write_ports(struct file *file, char *buf, size_t size)
> +{
> +	ssize_t rv;
> +	mutex_lock(&nfsd_mutex);
> +	rv = __write_ports(file, buf, size);
> +	mutex_unlock(&nfsd_mutex);
> +	return rv;
> +}
>   
Oooh, much better.  I was foolishly trying to fix all the lock_kernels()
in the original write_ports().

There are some comments in net/sunrpc/svc.c referring to callers needing
to own the BKL, which will need updating also. Otherwise, looks good :-)
Perhaps the trouble I was having was in the older codebase only, or
because I didn't pull the locking out far enough.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

