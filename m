Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from li9-11.members.linode.com ([67.18.176.11]:33704 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755493Ab1HSWaB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 18:30:01 -0400
Date: Fri, 19 Aug 2011 18:29:51 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        bfields@fieldses.org, bernd.schubert@fastmail.fm, hch@infradead.org,
        adilger@whamcloud.com, yong.fan@whamcloud.com,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3 2/4] Return 32/64-bit dir name hash according to
 usage type
Message-ID: <20110819222951.GC3578@thunk.org>
References: <20110816115404.1810393.47239.stgit@localhost.localdomain>
 <20110816115414.1810393.92169.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110816115414.1810393.92169.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 16, 2011 at 01:54:14PM +0200, Bernd Schubert wrote:
> +static inline int is_32bit_api(void)
> +{
> +#ifdef HAVE_IS_COMPAT_TASK
> +	return is_compat_task();
> +#else
> +	return (BITS_PER_LONG == 32);
> +#endif

I assume is_compat_task() is coming from another patch?  What is the
status of that change?

In the case where is_compat_task() is not defined, we can't just test
based on BITS_PER_LONG == 32, since even on an x86_64 machine, it's
possible we're running a 32-bit binary in compat mode....

	       	       	 	       	  - Ted
