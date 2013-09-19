Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47590 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767Ab3ISOIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 10:08:52 -0400
Date: Thu, 19 Sep 2013 10:08:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: help with nfs export/mount
Message-ID: <20130919140846.GC20422@fieldses.org>
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <20130919131429.GA20422@fieldses.org>
 <1379597501.95818.YahooMailNeo@web140002.mail.bf1.yahoo.com>
 <20130919134028.GB20422@fieldses.org>
 <1379599410.72261.YahooMailNeo@web140001.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1379599410.72261.YahooMailNeo@web140001.mail.bf1.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 19, 2013 at 07:03:30AM -0700, Jody Gugelhupf wrote:
> on server side I see in dmesg this:
> [8040437.603605] nfsd: last server has exited, flushing export cache
> [8040439.496016] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> [8040439.496035] NFSD: starting 90-second grace period
> 
> on client side i only see:
> Sep 19 13:27:56 darkstar kernel: [61095.429346] nfs: server 192.168.2.3 OK
> Sep 19 13:31:01 darkstar kernel: [61280.169706] nfs: server 192.168.2.3 not responding, still trying
>  is there a way to further debug?

Exactly what commands did you type, and what things happened, in what
order?

--b.
