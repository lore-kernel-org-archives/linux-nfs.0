From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/5] rpc: move in_downcall list to gss code
Date: Sat, 14 Jun 2008 12:01:00 -0400
Message-ID: <1213459260.7149.10.camel@localhost>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26760 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752913AbYFNQBf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Jun 2008 12:01:35 -0400
In-Reply-To: <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-06-13 at 18:50 -0400, J. Bruce Fields wrote:
> This list is only used by the auth_gss code anyway.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

NACK. This too reintroduces a forced one-to-one relationship between the
inode and the gss_auth.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
