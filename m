From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: Question: When NFS client check dir's permission,
 it does not check the cache data
Date: Wed, 27 Jun 2007 09:24:20 +0800
Message-ID: <4681BC44.6000605@cn.fujitsu.com>
References: <467F8247.9060607@cn.fujitsu.com>
	<1182802099.6163.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3MHD-0006hl-C8
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 18:24:59 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3MHF-0004PZ-5B
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 18:25:02 -0700
In-Reply-To: <1182802099.6163.33.camel@heimdal.trondhjem.org>
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


>> Hello, everyone
>>  When I test NFS client, I found a poblem that, if a dir we do not have 
>> permission to write, it will let the server to check permissions when we 
>> perform the write op.
>> This is comment by source code:
>>   * Optimize away all write operations, since the server
>>   * will check permissions when we perform the op.
>> In my test, the process is like following:
>> #touch dir/file
>> NFS Server                         NFS Client
>>                        <----------      lookup (dir)
>> lookup ok      ------------->
>>                        <----------      access (dir)   (*1)
>> access(read only)   -----------> 
>>                        <----------      lookup (file)
>> lookup(NOENT)     ------------->
>>                        <----------      create (file)  (*2)
>> create(NOPERM)     ------------->
>>
>> (*1)
>> First to check the permissions of that dir ,and will be add to cache data.
>> (*2)
>> Since the Client had known the permission of the dir, why no used it? 
>> Does this effect to NFS client's performance?
>>     
>
> You could, but we don't really have good semantics for how to cache
> directory information. For files you have close-to-open caching, but for
> directories, there is no equivalent. I'd therefore prefer to be
> conservative in cases like this, rather than relying on cached
> information.
>   
I think code "status = nfs_access_get_cached(inode, cred, &cache);" can do
this. And it works.
Other question: why only optimize all write operations, read operations
are not optimized? If read options is optimized, it can do the same things,
do not use access to check permissions, and server will check permissions
when we perform the read op.
> The other question I have is why this is really something worth
> optimising for? Are there really applications out there with a workload
> that involves lots of attempts to create files in read-only directories?
>
> Trond
>   
Regards

Wei Yongjun



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
