From: Miquel van Smoorenburg <mikevs@xs4all.net>
Subject: Re: nfs/sunrpc: high CPU usage in rpcauth_lookup_credcache with
 lots of uids [PATCH]
Date: Mon, 22 Jun 2009 15:09:08 +0200
Message-ID: <1245676148.5413.1.camel@laptop>
References: <20090602142933.GA27312@xs4all.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond.Myklebust@netapp.com, bfields@fieldses.org, neilb@suse.de,
	mikevs@xs4all.net
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr10.xs4all.nl ([194.109.24.30]:3637 "EHLO
	smtp-vbr10.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574AbZFVNJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2009 09:09:24 -0400
In-Reply-To: <20090602142933.GA27312@xs4all.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-02 at 16:29 +0200, Miquel van Smoorenburg wrote:
> [repost, with more people in the cc: list]
> 
> We run a cluster of POP and IMAP servers that are used by
> hundreds of thousands of different users- we see as much
> as 80.000 different users per server on any given day.
>
> We noticed a high CPU load on these servers, sometimes near
> 100% system time being used on all cores. I used oprofile to
> find out where the CPU was being burned and it turned out to
> be in rpcauth_lookup_credcache(). The credential cache hashtable
> is sized way to small for our purposes- it's just 16 slots,
> and with 100.000 entries in the generic and unix credential
> caches the chainlength goes over 6000.

ping ?

Mike.

