From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv2/3 requiring RPC_AUTH_GSS
Date: Mon, 7 Mar 2005 10:50:26 -0500
Message-ID: <20050307155026.GC25025@fieldses.org>
References: <1109890493.4361.95.camel@roadrunner.phys.psu.edu> <1109963019.10173.14.camel@lade.trondhjem.org> <20050305064537.GD4354@fieldses.org> <1110016071.21281.70.camel@roadrunner.phys.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8LbH-0004Eq-UT
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 09:00:59 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8LbF-0008AM-J1
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 09:00:59 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8KY8-0006oW-Li
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 07:53:41 -0800
To: Benjamin Bennett <ben@phys.psu.edu>
In-Reply-To: <1110016071.21281.70.camel@roadrunner.phys.psu.edu>
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

On Sat, Mar 05, 2005 at 04:47:52AM -0500, Benjamin Bennett wrote:
> The problem I saw (can't require gss for v3 access) seems to be the
> result of two things:
> 
>   A) mountd needs to see the v3 host in exports (or it will return
> unknown host). So even though we just want to use gss, we need another
> export (auth_unix) to satisfy this.

Oh, right.

>   I wrote a little code to unconditionally send back a successful mount
> response with filehandle and included gss flavors. This led to the
> second problem:
> 
>   B) knfsd also validates host, so we again need the same auth_unix
> export as in A.

I'm not sure what you mean by "knfsd also validates host".  I think the
client mount program sends a NULL rpc call to nfsd, is that what you're
talking about?

>   The most simple work-around I could think of was making the auth_unix
> export ro, all_squash. But that still allows auth_unix anyone to mount
> and be nobody ;-)
> 
>   Whether a client is going to use gss for nfs transactions isn't
> necessarily known at mount time, so we can't just have mountd ignore
> hostnames when gss is going to be used.

Well, I suppose we could require mount to contact mountd using gss.
That seems much more sensible to me than what rfc2623 recommends.  Maybe
I'm missing some obvious problem.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
