Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:33859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235Ab2AETTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jan 2012 14:19:42 -0500
Date: Thu, 05 Jan 2012 14:15:22 -0500 (EST)
Message-Id: <20120105.141522.1303730212186060591.davem@davemloft.net>
To: ian.campbell@citrix.com
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
        pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Trond.Myklebust@netapp.com, gregkh@suse.de,
        drbd-user@lists.linbit.com, devel@driverdev.osuosl.org,
        cluster-devel@redhat.com, ocfs2-devel@oss.oracle.com,
        ceph-devel@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/6] net: add paged frag destructor support to
 kernel_sendpage.
From: David Miller <davem@davemloft.net>
In-Reply-To: <1325783624-14601-5-git-send-email-ian.campbell@citrix.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	<1325783624-14601-5-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 5 Jan 2012 17:13:43 +0000

> -static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
> +static ssize_t do_tcp_sendpages(struct sock *sk,
> +				struct page **pages,
> +				struct skb_frag_destructor **destructors,
> +				int poffset,
>  			 size_t psize, int flags)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);

An array of destructors is madness, and the one call site that specifies this
passes an address of a single entry.

This also would never even have to occur if you put the destructor inside of
struct page instead.

Finally, except for the skb_shared_info() layout optimization in patch #1 which
I alreayd applied, this stuff is not baked enough for the 3.3 merge window.
