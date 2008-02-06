From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 06 Feb 2008 13:46:25 -0500
Message-ID: <1202323586.8549.18.camel@heimdal.trondhjem.org>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>
	 <47A9C620.70106@oxeva.fr> <1202311096.12647.28.camel@heimdal.trondhjem.org>
	 <47A9FB75.90206@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>, linux-nfs@vger.kernel.org
To: Gabriel Barazer <gabriel-KSe8qvLY914@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:39540 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbYBFSqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 13:46:30 -0500
In-Reply-To: <47A9FB75.90206-KSe8qvLY914@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-06 at 19:24 +0100, Gabriel Barazer wrote:
> Oops (tm)! Fortunately I do mostly reads, but maybe the exports(5) man 
> page should be updated. According to the man page, I thought that 
> although writes aren't commited to the block devices, the server-side 
> cache is correctly synchronized (but lost if you pull the plug).

...or if the server crashes for some reason.

> Thanks 
> for the explanation. Having a battery backed large write cache on the 
> server, is there a performance hit when switching from async to sync in 
> NFSv3 ?

The main performance hits occur on operations like create(), mkdir(),
rename and unlink() since they are required to be immediately synced to
disk.
IOW: there will be a noticeable overhead when writing lots of small
files.

For large files, the overhead should be minimal, since all writes can be
cached by the server until the close() operation.

Trond

