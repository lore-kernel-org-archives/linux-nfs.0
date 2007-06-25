From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question: When NFS client check dir's permission,
	it	does not check the cache data
Date: Mon, 25 Jun 2007 16:08:19 -0400
Message-ID: <1182802099.6163.33.camel@heimdal.trondhjem.org>
References: <467F8247.9060607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I2urI-0005lm-AL
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 13:08:24 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1843Sxlqati3SJhuYt8auBeXu27FPz3aFQ=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I2urJ-0005cs-W0
	for nfs@lists.sourceforge.net; Mon, 25 Jun 2007 13:08:27 -0700
In-Reply-To: <467F8247.9060607@cn.fujitsu.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-06-25 at 16:52 +0800, Wei Yongjun wrote:
> Hello, everyone
>  When I test NFS client, I found a poblem that, if a dir we do not have 
> permission to write, it will let the server to check permissions when we 
> perform the write op.
> This is comment by source code:
>   * Optimize away all write operations, since the server
>   * will check permissions when we perform the op.
> In my test, the process is like following:
> #touch dir/file
> NFS Server                         NFS Client
>                        <----------      lookup (dir)
> lookup ok      ------------->
>                        <----------      access (dir)   (*1)
> access(read only)   -----------> 
>                        <----------      lookup (file)
> lookup(NOENT)     ------------->
>                        <----------      create (file)  (*2)
> create(NOPERM)     ------------->
> 
> (*1)
> First to check the permissions of that dir ,and will be add to cache data.
> (*2)
> Since the Client had known the permission of the dir, why no used it? 
> Does this effect to NFS client's performance?

You could, but we don't really have good semantics for how to cache
directory information. For files you have close-to-open caching, but for
directories, there is no equivalent. I'd therefore prefer to be
conservative in cases like this, rather than relying on cached
information.

The other question I have is why this is really something worth
optimising for? Are there really applications out there with a workload
that involves lots of attempts to create files in read-only directories?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
