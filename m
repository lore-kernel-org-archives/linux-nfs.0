Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758212Ab3ENWBY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 18:01:24 -0400
Date: Tue, 14 May 2013 18:01:22 -0400
To: James Vanns <james.vanns@framestore.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
Message-ID: <20130514220122.GE16811@fieldses.org>
References: <433790995.19587230.1368530229981.JavaMail.root@framestore.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <433790995.19587230.1368530229981.JavaMail.root@framestore.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 14, 2013 at 12:17:10PM +0100, James Vanns wrote:
> Hi. I'm struggling to locate the region in the NFSv3 server-side code
> where it figures out the block sizes for the FSINFO reply. We have
> servers that do not specify r/wsizes in their exports

There's no way to specify that as an export option.  You can configure
it server-wide using /proc/fs/nfsd/max_block_size.

> and so I need to
> find where this negotiated value between server->client actually comes
> from. How does the server reach the preferred block size for a given
> export?

fs/nfsd/nfssvc.c:nfsd_get_default_maxblksize() is probably a good
starting point.  Its caller, nfsd_create_serv(), calls
svc_create_pooled() with the result that's calculated.

For fsinfo see fs/nfsd/nfs3proc.c:nfsd3_proc_fsinfo, which uses
svc_max_payload().

--b.
