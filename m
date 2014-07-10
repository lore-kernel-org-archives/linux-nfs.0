Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:52047 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbaGJNVD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 09:21:03 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so7526788qgf.26
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 06:21:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 09:21:01 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Message-ID: <20140710092101.28558ab4@tlielax.poochiereds.net>
In-Reply-To: <20140710131650.GA6806@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-16-git-send-email-jlayton@primarydata.com>
	<20140710103100.GA6935@infradead.org>
	<20140710081912.4af7c35b@tlielax.poochiereds.net>
	<20140710131650.GA6806@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 06:16:50 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Ok, feel free do drop my comments re the access/deny bitmap.  I don't
> really think this is worth it to avoid the small false positive to
> allow downgrading if a different open owner had a r/o or w/o open, but
> it's probably indeed way to much churn for this series to do anything
> about it.
> 

Ok, thanks.

I agree that having to track this is a little ridiculous. No real client
really cares about that, but there are some pynfs tests that will fail
if we remove it altogether. I broke it a couple of years ago and Bruce
dinged me on it, so I'm inclined not to change it here.

-- 
Jeff Layton <jlayton@primarydata.com>
