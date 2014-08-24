Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58565 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbaHXP66 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 11:58:58 -0400
Date: Sun, 24 Aug 2014 08:58:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/10] locks: define a lm_setup handler for leases
Message-ID: <20140824155858.GF15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-8-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-8-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I like this change a lot!  But one caveat:

> +	/*
> +	 * Despite the fact that it's an int return function, __f_setown never
> +	 * returns an error. Just ignore any error return here, but spew a
> +	 * WARN_ON_ONCE in case this ever changes.
> +	 */
> +	WARN_ON_ONCE(__f_setown(filp, task_pid(current), PIDTYPE_PID, 0));

I don't think this is a good idea.  The errors in __f_setown come from
the security modules, and they could change easily.  If you can convince
the LSM people to change their file_set_fowner routine to return void
we could change __f_setown to return void as well and be done with it,
but without that this looks too dangerous.

