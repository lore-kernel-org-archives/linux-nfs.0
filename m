From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 4/4] NFS: Allow the "nfs" file system type to support
 NFSv4
Date: Tue, 08 Sep 2009 18:17:42 -0400
Message-ID: <1252448262.8099.57.camel@heimdal.trondhjem.org>
References: <20090902135032.3550.23170.stgit@matisse.1015granger.net>
	 <20090902135222.3550.59986.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55336 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbZIHWRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 18:17:43 -0400
In-Reply-To: <20090902135222.3550.59986.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-09-02 at 09:52 -0400, Chuck Lever wrote:
> When mounting an "nfs" type file system, recognize "v4," "vers=4," or
> "nfsvers=4" mount options, and convert the file system to "nfs4" under
> the covers.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

For consistency, can we please ensure that we set the
nfs_parsed_mount_data->version in the binary mount case too?

The other thing to note is that we should not allow vers=2,3 in the -t
nfs4 case.

I'll fix the former inline in your patch 4/4, and add the latter as a
separate patch.

Cheers
  Trond

