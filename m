Return-Path: linux-nfs-owner@vger.kernel.org
Received: from knm.org ([173.10.24.5]:60977 "EHLO knm.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793Ab3BUVC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 16:02:27 -0500
Date: Thu, 21 Feb 2013 14:01:50 -0700 (MST)
From: Mark Lehrer <mark@tpsit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Mark Lehrer <mark@tpsit.com>, linux-nfs@vger.kernel.org
Subject: Re: Time to declare war on "stale nfs file handle"
In-Reply-To: <20130220202114.GA4995@fieldses.org>
Message-ID: <alpine.DEB.1.00.1302211400050.801@shell>
References: <alpine.DEB.1.00.1302191507240.5816@shell> <20130220202114.GA4995@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> been running for awhile and then I fail over, clients get the dreaded
>> Stale NFS file handle error on any open files.  In this case they are
>
> That's weird.  The contents of /proc/net/rpc/nfsd.fh/content and
> /proc/net/rpc/nfsd.export/content on both nodes after a failed failover
> might be interesting.

Cool, this is exactly the kind of information I was looking for.


> What filesystem are you exporting?

ext4.

Thanks!
Mark

