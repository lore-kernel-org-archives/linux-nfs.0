From: Ion Badulescu <ionut@badula.org>
Subject: Re: [PATCH] Makes nfs mount warning less frequent and more
 valuable
Date: Mon, 21 Mar 2005 11:18:39 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503211051110.5958@guppy.limebrokerage.com>
References: <4237178A.5030003@dgreaves.com>  <Pine.LNX.4.61.0503151439250.22235@guppy.limebrokerage.com>
  <42384B59.3060408@dgreaves.com> <1111075232.13215.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Greaves <david@dgreaves.com>,
	Neil Brown <neilb@cse.unsw.edu.au>, Erez Zadok <ezk@cs.sunysb.edu>,
	am-utils@fsl.cs.sunysb.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDPcT-00089z-JF
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 08:19:09 -0800
Received: from ns1.limegroup.com ([64.48.93.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DDPcR-0000fE-Kl
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 08:19:10 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111075232.13215.14.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 17 Mar 2005, Trond Myklebust wrote:

> I started rethinking this subject last night in between cleanups of the
> ACL code. Attached is the resulting patch proposal. It goes a lot
> further that what you do, but should hopefully provide better error
> reporting in "mount" and clean up some of that code.
>
> In particular, note that it attempts to add an error code that tells you
> whether or not NFSv3 is actually supported by the kernel: I used
> EPROTONOSUPPORT, since that gives the correct error message with
> perror() (although strictly, EPROTONOSUPPORT appears to be a socket
> error). If anyone has a better suggestion for an error that makes more
> sense, then I'm all ears...

ENOSYS might be an alternative, though personally I have no problem with 
EPROTONOSUPPORT. ENOSYS is worse because it's then hard to differentiate 
between no NFS support at all and no support for that particular version.

This is actually very good news for amd, because we've been struggling for 
years to detect (and work around) the case when the kernel version (and 
headers) indicate that v3 support would be available on the client side, 
but the user doesn't have it compiled in.

I think the patch looks good. Just a small problem with one error path:

+       s = ERR_PTR(-ENOMEM);
         server = kmalloc(sizeof(struct nfs_server), GFP_KERNEL);
         if (!server)
-               return ERR_PTR(-ENOMEM);
+               goto out_err;
[...]
+out_err:
+       kfree(server);
+       return s;

This will call kfree(NULL) if the kmalloc fails. Which may well be fine--I 
haven't looked at kfree to see if handles that case.

Thanks,
Ion

-- 
   It is better to keep your mouth shut and be thought a fool,
             than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
