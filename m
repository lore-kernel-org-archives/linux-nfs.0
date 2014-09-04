Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41350 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470AbaIDTwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2014 15:52:42 -0400
Date: Thu, 4 Sep 2014 15:52:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/5] lockd: add a /proc/fs/lockd/nlm_end_grace file
Message-ID: <20140904195237.GA14576@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <1408473509-14010-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408473509-14010-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 19, 2014 at 02:38:26PM -0400, Jeff Layton wrote:
> Add a new procfile that will allow a (privileged) userland process to
> end the NLM grace period early. The basic idea here will be to have
> sm-notify write to this file, if it sent out no NOTIFY requests when
> it runs. In that situation, we can generally expect that there will be
> no reclaim requests so the grace period can be lifted early.
> 
> +static ssize_t
> +nlm_end_grace_write(struct file *file, const char __user *buf, size_t size,
> +		    loff_t *pos)
> +{
> +	struct lockd_net *ln = net_generic(current->nsproxy->net_ns, lockd_net_id);
> +
> +	if (size > 0)

I'd rather we expect some particular string ("Y\n"?) and return -EINVAL
otherwise, just in case we want to extend this some day.

--b.
