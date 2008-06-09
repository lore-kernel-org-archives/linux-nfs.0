From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/6] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Mon, 9 Jun 2008 17:22:05 -0400
Message-ID: <20080609212205.GB32446@fieldses.org>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu> <1213044696-32741-2-git-send-email-bfields@citi.umich.edu> <1213044696-32741-3-git-send-email-bfields@citi.umich.edu> <1213044696-32741-4-git-send-email-bfields@citi.umich.edu> <1213044696-32741-5-git-send-email-bfields@citi.umich.edu> <1213044696-32741-6-git-send-email-bfields@citi.umich.edu> <1213044696-32741-7-git-send-email-bfields@citi.umich.edu> <1213045696.19130.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41678 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755924AbYFIVWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 17:22:07 -0400
In-Reply-To: <1213045696.19130.7.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 09, 2008 at 05:08:16PM -0400, Trond Myklebust wrote:
> 
> What if it is an IPv6 address? As I've said before, could we please just
> adapt nfs_parse_server_address to deal with all these cases?

I haven't had the time to do that, so I thought we'd rather have a fix
for the immediate bug now, then add ipv6 support later.  For all I know
the final patches might end up factoring reasonable cleanly that way
anyway.

--b.
