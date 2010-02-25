From: bpm@sgi.com
Subject: Re: Problem with nfs server reboot causing exports to jumble
Date: Thu, 25 Feb 2010 14:06:57 -0600
Message-ID: <20100225200657.GD20620@sgi.com>
References: <20100225192911.09CC318839E@wsnyder.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Wilson Snyder <wsnyder-12vJDDTx9R9AfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:44120 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933525Ab0BYUGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Feb 2010 15:06:07 -0500
In-Reply-To: <20100225192911.09CC318839E-12vJDDTx9R9AfugRpC6u6w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wilson,

On Thu, Feb 25, 2010 at 02:29:10PM -0500, Wilson Snyder wrote:
> 
> We're using the 2.6.18 x86_64 kernel (RH SL 5.1) with a NFS
> v3 server and NFS v3 clients using the automounter with options
> (rw,noatime,hard,intr,rsize=32768,wsize=32768,proto=tcp).
> 
> Our NFS server had several exports
> 
>     /export/a/{files-a}
>     /export/b/{files-b}
> 
> these were mounted on various clients.
> 
> We then added a new mount and export without rebooting:
> 
>     /export/a/{files-a}
>     /export/b/{files-b}
>     /export/c/{files-c}
> 
> All were visible on the clients, and everything was fine:
> 
>     /nfs/a/{files-a}
>     /nfs/b/{files-b}
>     /nfs/c/{files-c}
> 
> Our NFS server then crashed, and rebooted.  After reboot the
> clients then had:
> 
>     /nfs/a/{files-c}
>     /nfs/b/{files-a}
>     /nfs/c/{files-b}
> 
> Note the files correspond to the wrong exports.  Remounting
> on every client fixed the problem - once we realized what
> was going on!  (files-a/b/c were all similar so it wasn't
> immediately aparent)
> 
> My speculation is the reboot changed some enumeration
> causing a mismatch between the clients and servers.
> 
> This is a new one by me - is this a known issue, and if so
> is a patch available?
> 
> Other than patching, are there any precautions we can take
> to avoid this in the future?  (Other than not crashing the
> server, which we'd be happy to not to do. :)

Use the mp and fsid export options documented in the exports manpage.

-Ben
