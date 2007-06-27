From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: Question: When NFS client check dir's permission,
 it	does not check the cache data
Date: Wed, 27 Jun 2007 13:22:03 +0800
Message-ID: <4681F3FB.7040609@cn.fujitsu.com>
References: <467F8247.9060607@cn.fujitsu.com>	
	<1182802099.6163.33.camel@heimdal.trondhjem.org>	
	<4681BC44.6000605@cn.fujitsu.com>
	<1182913754.12836.61.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1356602490=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3PzH-0005Zu-1P
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 22:22:43 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3PzI-0006Yw-RF
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 22:22:46 -0700
In-Reply-To: <1182913754.12836.61.camel@heimdal.trondhjem.org>
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

--===============1356602490==
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit

>
>> I think code "status = nfs_access_get_cached(inode, cred, &cache);" can do
>> this. And it works.
>> Other question: why only optimize all write operations, read operations
>> are not optimized? If read options is optimized, it can do the same things,
>> do not use access to check permissions, and server will check permissions
>> when we perform the read op.
>>     
>
> Huh? What read operations are we failing to optimise and how?
>   

I mean that read a dir, such as lookup a dir.
If I reply a getattr as that dir has no lookup permission, and then do a
"cat /nfsroot/dir/file" at client, client will not send lookup procedure to
server, because client used the cache data of the dir. It like this:
client server
#ls /nfsroot
readdirplus ------------------>
<------------- readdirplus reply
(attribute of dir has no lookup permission)
# cat /nfsroot/dir/file
(send nothing, used cache data)
-------no package is send-------

If no cache data exists, it would like this:
client server
#ls /nfsroot
readdirplus ------------------>
<------------- readdirplus reply
(attribute of dir has no lookup permission)
# cat /nfsroot/dir/file
access(dir) ------------------->
<------------- access reply(dir)
(has no lookup permission)

And if has permission to lookup dir, it would like this:
client server
#ls /nfsroot
readdirplus ------------------>
<------------- readdirplus reply
(attribute of dir has no lookup permission)
# cat /nfsroot/dir/file
access(dir) -------------------> (*1)
<------------- access reply(dir)
lookup(file) ------------------->
<------------- lookup reply(file)
read(file) ------------------->
<------------- read reply(file)

While you optimize all write operations to omit access procedure, can
this access (*1) be omitted? Then lookup(file) will return NOPERM.

Regards
Wei Yongjun




--===============1356602490==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1356602490==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1356602490==--
