Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:57462 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbbAFRmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 12:42:19 -0500
Date: Tue, 6 Jan 2015 18:42:14 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 10/18] nfsd: implement pNFS layout recalls
Message-ID: <20150106174214.GB16200@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-11-git-send-email-hch@lst.de> <20150106172508.GE12067@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150106172508.GE12067@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> This bothers me a little: cl_addr is just the address that the
> exchange_id came from.  In theory there's no one-to-one relationship
> between NFSv4 clients and IP addresses.  Is it likely the iscsi traffic
> could use a different interface than the MDS traffic?
> 
> If this is the best we can do, then maybe this should at least be
> documented.

The pNFS block fencing protocol bothers me a lot, it seems like very
little thought went into that part of the standard.

I proposed a new SCSI layout type that fixes those issues on the
NFSv4 WG list, but there's been zero interest in it:

http://www.ietf.org/mail-archive/web/nfsv4/current/msg13469.html

