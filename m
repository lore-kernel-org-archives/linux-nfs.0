From: Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS/LSM: allow NFS to control all of its own mount options
Date: Tue, 19 Feb 2008 17:24:08 -0500
Message-ID: <20080219222408.GB10656@infradead.org>
References: <1203457094.2928.113.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, selinux <selinux@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	casey@schaufler-ca.com, trond.myklebust@fys.uio.no,
	chuck.lever@oracle.com, linux-fsdevel@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49088 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412AbYBSWYK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2008 17:24:10 -0500
In-Reply-To: <1203457094.2928.113.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please don't introduce a special case for just nfs.  All filesystems
should control their mount options, so please provide some library
helpers for context= handling and move it into all filesystems that
can support selinux.
