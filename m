From: Jeff Garzik <jeff@garzik.org>
Subject: NFS4ERR_DENIED becomes EIO?
Date: Wed, 18 Feb 2009 16:19:15 -0500
Message-ID: <499C7B53.5030802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48742 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756998AbZBRVTT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Feb 2009 16:19:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I think I may have found a tiny NFSv4 client bug.  What I am seeing:

1. On Linux NFS client (2.6.29-rc2), issue chown(1) to change the owner 
of the file (causing SETATTR:OWNER to be issued)

2. My userland NFS server returns NFS4ERR_DENIED for the SETATTR op

3. Linux NFS client returns EIO (I/O error) to userland

That was a bit unexpected.  I would have guessed EPERM, perhaps.

	Jeff


