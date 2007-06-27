From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question: When NFS client check dir's permission,
	it	does not check the cache data
Date: Wed, 27 Jun 2007 10:25:31 -0400
Message-ID: <1182954331.5311.14.camel@heimdal.trondhjem.org>
References: <467F8247.9060607@cn.fujitsu.com>
	<1182802099.6163.33.camel@heimdal.trondhjem.org>
	<4681BC44.6000605@cn.fujitsu.com>
	<1182913754.12836.61.camel@heimdal.trondhjem.org>
	<4681F3FB.7040609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3YSg-00014z-D9
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 07:25:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+mu8yj6yLnjF3T9RhkvuQBdAcnxm6lzPc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3YSi-00065L-A1
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 07:25:41 -0700
In-Reply-To: <4681F3FB.7040609@cn.fujitsu.com>
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

On Wed, 2007-06-27 at 13:22 +0800, Wei Yongjun wrote:
> >
> >> I think code "status = nfs_access_get_cached(inode, cred, &cache);" can do
> >> this. And it works.
> >> Other question: why only optimize all write operations, read operations
> >> are not optimized? If read options is optimized, it can do the same things,
> >> do not use access to check permissions, and server will check permissions
> >> when we perform the read op.
> >>     
> >
> > Huh? What read operations are we failing to optimise and how?
> >   
> 
> I mean that read a dir, such as lookup a dir.
> If I reply a getattr as that dir has no lookup permission, and then do a
> "cat /nfsroot/dir/file" at client, client will not send lookup procedure to
> server, because client used the cache data of the dir. It like this:
> client server
> #ls /nfsroot
> readdirplus ------------------>
> <------------- readdirplus reply
> (attribute of dir has no lookup permission)
> # cat /nfsroot/dir/file
> (send nothing, used cache data)
> -------no package is send-------
> 
> If no cache data exists, it would like this:
> client server
> #ls /nfsroot
> readdirplus ------------------>
> <------------- readdirplus reply
> (attribute of dir has no lookup permission)
> # cat /nfsroot/dir/file
> access(dir) ------------------->
> <------------- access reply(dir)
> (has no lookup permission)
> 
> And if has permission to lookup dir, it would like this:
> client server
> #ls /nfsroot
> readdirplus ------------------>
> <------------- readdirplus reply
> (attribute of dir has no lookup permission)
> # cat /nfsroot/dir/file
> access(dir) -------------------> (*1)
> <------------- access reply(dir)
> lookup(file) ------------------->
> <------------- lookup reply(file)
> read(file) ------------------->
> <------------- read reply(file)
> 
> While you optimize all write operations to omit access procedure, can
> this access (*1) be omitted? Then lookup(file) will return NOPERM.

So what if I change the permissions on the directory? What should the
rules be for caching these attributes?

...and you still haven't replied to my question about what
application/workload actually _cares_ about optimising for this
particular case.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
