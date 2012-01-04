Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13681 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757099Ab2ADW3S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 17:29:18 -0500
Message-ID: <1325716152.25276.3.camel@lade.trondhjem.org>
Subject: Re: [PATCH] NFS: Cache state owners after files are closed
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 17:29:12 -0500
In-Reply-To: <1325716037-27762-1-git-send-email-Trond.Myklebust@netapp.com>
References: <C0783437-7D8F-4A45-913A-B49692D37AC2@oracle.com>
	 <1325716037-27762-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-01-04 at 17:27 -0500, Trond Myklebust wrote: 
> [Trond: Fixed a garbage collection race and a few efficiency issues]
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

As you can see from the resulting patch, I found a couple more
optimisations: mainly to do with optimising away the dropping and then
retaking of the client->cl_lock...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

