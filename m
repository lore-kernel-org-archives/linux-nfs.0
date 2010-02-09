From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Tue, 09 Feb 2010 14:53:35 +0000
Message-ID: <26496.1265727215@redhat.com>
References: <20100208145942.17581.83842.stgit@localhost.localdomain> <20100208145942.17581.81775.stgit@localhost.localdomain>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
	Suresh Jayaraman <sjayaraman@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267Ab0BIOxk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 09:53:40 -0500
In-Reply-To: <20100208145942.17581.83842.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Not having an fscache cookie is perfectly valid if the user didn't mount
> with the fscache option.
> 
> This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=15234
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Acked-by: David Howells <dhowells@redhat.com>
