From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
 return error (try #2)
Date: Fri, 18 Dec 2009 16:02:34 -0500
Message-ID: <1261170154.3420.69.camel@localhost>
References: <1261153637-6209-1-git-send-email-jlayton@redhat.com>
	 <1261163139.3420.17.camel@localhost>
	 <20091218151345.5e86149d@tlielax.poochiereds.net>
	 <1261167866.3420.40.camel@localhost>
	 <20091218153841.1fbd5357@tlielax.poochiereds.net>
	 <1261169812.3420.68.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56384 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932952AbZLRVCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2009 16:02:38 -0500
In-Reply-To: <1261169812.3420.68.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 15:56 -0500, Trond Myklebust wrote: 
> switch (err) {
> case -EACCES:
> gss_msg->msg.errno = -EACCES;
> break;
> case -EFAULT:
> case -ENOMEM:
> case -EINVAL:
> case -ENOSYS:
> gss_msg->msg.errno = -EAGAIN;
> break;
> default:
> BUG();
> }
> 
> Yup. That looks good to me...


Well... Minus the helpful reformatting that evolution did for me after I
pressed the 'send' button.

Trond

