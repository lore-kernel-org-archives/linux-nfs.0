Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39806 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756620AbZGNW4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 18:56:35 -0400
Subject: Re: Union mounts, NFS, and locking
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Valerie Aurora <vaurora@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, Jan Blunck <jblunck@suse.de>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <200907142233.n6EMXRQp019008@agora.fsl.cs.sunysb.edu>
References: <200907142233.n6EMXRQp019008@agora.fsl.cs.sunysb.edu>
Content-Type: text/plain
Date: Tue, 14 Jul 2009 18:55:40 -0400
Message-Id: <1247612140.5332.11.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-07-14 at 18:33 -0400, Erez Zadok wrote:
> How would the client detect that the server broke the promise?  In theory,
> your client may never know b/c it'll never send the server any
> state-changing ops (e.g., creat, write, unlink).  One really ugly idea might
> be for the client to try and create a dummy .nfsXXXXXX file on the server,
> and if that succeds, or the error returned isn't EROFS, the client can guess
> that the server's misbhaving.

That still doesn't guarantee anything:

cat /etc/exports
/export	10.0.0.0/24(ro,sync) 10.0.1.1(rw,sync)
/export/home 10.0.0.0/24(sec=krb5i:krb5p,rw,sec=sys:krb5,ro)


Both of the above are liable to return EROFS to some clients, but not
others...

NFSv4.1 directory delegations can do the job of notifying you if the
directory contents change, but what should your unionfs do when it gets
told that this is the case?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
