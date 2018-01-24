Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51836 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932238AbeAXVJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Jan 2018 16:09:51 -0500
Date: Wed, 24 Jan 2018 16:09:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: "Reshetova, Elena" <elena.reshetova@intel.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
Subject: Re: [PATCH 1/4] lockd: convert nlm_host.h_count from atomic_t to
 refcount_t
Message-ID: <20180124210950.GA12840@fieldses.org>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
 <1511954146-11793-2-git-send-email-elena.reshetova@intel.com>
 <20171221202350.GE31467@fieldses.org>
 <2236FBA76BA1254E88B949DDB74E612B802CFB57@IRSMSX102.ger.corp.intel.com>
 <20171222142553.GA9630@fieldses.org>
 <20171222154250.GB9630@fieldses.org>
 <2236FBA76BA1254E88B949DDB74E612B802D08DA@IRSMSX102.ger.corp.intel.com>
 <20180123220950.GA5632@fieldses.org>
 <1516754851.18068.3.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1516754851.18068.3.camel@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 23, 2018 at 07:47:31PM -0500, Trond Myklebust wrote:
> Sorry I forgot about the issues with the server garbage collector, and
> I applied these patches to my linux-next a couple of weeks ago.

Whoops, OK, so who's taking those patches anyway?

> What say we fix the issue with something like the following?
...
> @@ -662,8 +664,7 @@ nlm_gc_hosts(struct net *net)
>  	for_each_host_safe(host, next, chain, nlm_server_hosts) {
>  		if (net && host->net != net)
>  			continue;
> -		if (refcount_read(&host->h_count) || host->h_inuse
> -		 || time_before(jiffies, host->h_expires)) {
> +		if (host->h_inuse || time_before(jiffies, host->h_expires)) {

Can you really just drop the h_count check?

Oh, I see:

> @@ -671,7 +672,8 @@ nlm_gc_hosts(struct net *net)
>  				host->net->ns.inum);
>  			continue;
>  		}
> -		nlm_destroy_host_locked(host);
> +		if (refcount_dec_if_one(&host->h_count))
> +			nlm_destroy_host_locked(host);

So this is check that replaces it.

Makes sense to me, thanks.  ACK to the patch.

--b.

>  	}
>  
>  	if (net) {
> -- 
> 2.14.3
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
