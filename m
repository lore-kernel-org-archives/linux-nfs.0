From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/6] rpc: timeout patch
Date: Mon, 09 Jun 2008 17:18:50 -0400
Message-ID: <1213046330.19130.12.camel@localhost>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-2-git-send-email-bfields@citi.umich.edu>
	 <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbYFIVSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 17:18:52 -0400
In-Reply-To: <1213044696-32741-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-06-09 at 16:51 -0400, J. Bruce Fields wrote:
> From: Olga Kornievskaia <aglo@citi.umich.edu>
> 
> When a client gss upcall times out, we currently give a mesage reminding
> the user to check whether gssd is running.
> 
> Currently gssd only listens on pipes under nfs/.  We expect to modify it
> so it treats all clients the same regardless of protocol (as it probably
> should have before), and new functionality may depend on that.  So
> people may need to upgrade gssd to get such new functionality.
> 
> So it would be helpful if the error message specified which pipe exactly
> the upcall was failing on, and suggested that the problem could be due
> to an outdated gssd (not just a non-existant gssd).

NACK. I belive I've already made clear that I really don't like the idea
of using d_path() in an error message.

Please just correct the existing error message to remind people that
they need an up to date version of gssd, and add a comment in Kconfig
stating exactly _which_ minimal version is needed.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
