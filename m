Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:54052 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838Ab3KLHdA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 02:33:00 -0500
Date: Mon, 11 Nov 2013 16:47:03 -0800
From: Greg KH <gregkh@linuxfoundation.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>, devel@openvz.org,
        ebiederm@xmission.com, oleg@redhat.com, bfields@fieldses.org,
        bharrosh@panasas.com
Subject: Re: call_usermodehelper in containers
Message-ID: <20131112004703.GB15377@kroah.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131111071825.62da01d1@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 11, 2013 at 07:18:25AM -0500, Jeff Layton wrote:
> We have a bit of a problem wrt to upcalls that use call_usermodehelper
> with containers and I'd like to bring this to some sort of resolution...
> 
> A particularly problematic case (though there are others) is the
> nfsdcltrack upcall. It basically uses call_usermodehelper to run a
> program in userland to track some information on stable storage for
> nfsd.

I thought the discussion at the kernel summit about this issue was:
	- don't do this.
	- don't do it.
	- if you really need to do this, fix nfsd

thanks,

greg k-h
