From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC][PATCH] nfs: don't assume fscache_acquire_cookie will always succeed
Date: Thu, 21 Jan 2010 11:07:07 +0000
Message-ID: <29178.1264072027@redhat.com>
References: <4B56F565.7080104@suse.de>
Cc: dhowells@redhat.com, trond.myklebust@netapp.com,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab0AULHN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 06:07:13 -0500
In-Reply-To: <4B56F565.7080104@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Suresh Jayaraman <sjayaraman@suse.de> wrote:

> +	if (!clp->fscache)
> +		goto error_cleanup;

This should be unnecessary.  FS-Cache's API functions in linux/fscache.h
should handle a NULL cookie and do the right thing.

David
