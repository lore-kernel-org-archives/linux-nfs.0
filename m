From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: Question: When NFS client check dir's permission,
 it does not check the cache data
Date: Thu, 28 Jun 2007 11:06:14 +0800
Message-ID: <468325A6.9060607@cn.fujitsu.com>
References: <467F8247.9060607@cn.fujitsu.com>	
	<1182802099.6163.33.camel@heimdal.trondhjem.org>	
	<4681BC44.6000605@cn.fujitsu.com>	
	<1182913754.12836.61.camel@heimdal.trondhjem.org>	
	<4681F3FB.7040609@cn.fujitsu.com>
	<1182954331.5311.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1453391644=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3kLT-0004uW-8B
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:06:59 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3kLT-0007ir-Hq
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:07:02 -0700
In-Reply-To: <1182954331.5311.14.camel@heimdal.trondhjem.org>
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

--===============1453391644==
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit


>> I mean that read a dir, such as lookup a dir.
>> If I reply a getattr as that dir has no lookup permission, and then do a
>> "cat /nfsroot/dir/file" at client, client will not send lookup procedure to
>> server, because client used the cache data of the dir. It like this:
>> client server
>> #ls /nfsroot
>> readdirplus ------------------>
>> <------------- readdirplus reply
>> (attribute of dir has no lookup permission)
>> # cat /nfsroot/dir/file
>> (send nothing, used cache data)
>> -------no package is send-------
>>
>> If no cache data exists, it would like this:
>> client server
>> #ls /nfsroot
>> readdirplus ------------------>
>> <------------- readdirplus reply
>> (attribute of dir has no lookup permission)
>> # cat /nfsroot/dir/file
>> access(dir) ------------------->
>> <------------- access reply(dir)
>> (has no lookup permission)
>>
>> And if has permission to lookup dir, it would like this:
>> client server
>> #ls /nfsroot
>> readdirplus ------------------>
>> <------------- readdirplus reply
>> (attribute of dir has no lookup permission)
>> # cat /nfsroot/dir/file
>> access(dir) -------------------> (*1)
>> <------------- access reply(dir)
>> lookup(file) ------------------->
>> <------------- lookup reply(file)
>> read(file) ------------------->
>> <------------- read reply(file)
>>
>> While you optimize all write operations to omit access procedure, can
>> this access (*1) be omitted? Then lookup(file) will return NOPERM.
>>     
>
> So what if I change the permissions on the directory? What should the
> rules be for caching these attributes?
>
> ...and you still haven't replied to my question about what
> application/workload actually _cares_ about optimising for this
> particular case.
>   
No application cares this ^_^, just for test.
I test the read op of dir, it maybe has tiny bug in it. As you said, if
I chmod of dir, client will be a little later to know this.
Test step ad following:

[root@REHL ~]# mount -t nfs 192.168.0.19:/nfsroot /mnt
[root@REHL ~]# ll /mnt
total 4
dr-xr-xr-x 2 root root 4096 Jun 23  2007 dir
[root@REHL ~]# ll /mnt/dir
total 4
-rw-r--r-- 1 root root 5 Jun 24  2007 file
[root@REHL ~]# su weiyj
[weiyj@REHL root]$ ll /mnt
total 4
dr-xr-xr-x 2 root root 4096 Jun 23  2007 dir
[weiyj@REHL root]$ ll /mnt/dir
total 4
-rw-r--r-- 1 root root 5 Jun 24  2007 file
[weiyj@REHL root]$ cat /mnt/dir/file
test
[weiyj@REHL root]$ ssh 192.168.0.19 -l root chmod a-x /nfsroot/dir
[weiyj@REHL root]$ cat /mnt/dir/file
test
[weiyj@REHL root]$ cat /mnt/dir/file
test
[weiyj@REHL root]$ ll /mnt/dir
total 0
?--------- ? ? ? ?            ? /mnt/dir/file
[weiyj@REHL root]$ ll /mnt
total 4
dr--r--r-- 2 root root 4096 Jun 23  2007 dir
[weiyj@REHL root]$ cat /mnt/dir/file
cat: /mnt/dir/file: Permission denied




--===============1453391644==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1453391644==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1453391644==--
