From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question: When NFS client check dir's permission,
	it	does not check the cache data
Date: Thu, 26 Jul 2007 12:26:50 -0400
Message-ID: <1185467210.6585.200.camel@localhost>
References: <467F8247.9060607@cn.fujitsu.com>
	<1182802099.6163.33.camel@heimdal.trondhjem.org>
	<4681BC44.6000605@cn.fujitsu.com>
	<1182913754.12836.61.camel@heimdal.trondhjem.org>
	<4681F3FB.7040609@cn.fujitsu.com>
	<1182954331.5311.14.camel@heimdal.trondhjem.org>
	<468325A6.9060607@cn.fujitsu.com>  <46A82D2D.5040405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE6Az-0007rB-76
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 09:26:57 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18/BgYqsQj4WQG0Ym3fXs4zq2V7lGJHZN4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IE6B0-0005yG-BU
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 09:27:01 -0700
In-Reply-To: <46A82D2D.5040405@cn.fujitsu.com>
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

On Thu, 2007-07-26 at 13:12 +0800, Wei Yongjun wrote:
> Sorry to trouble again, it is this a real problem of NFS?

You cannot replace an ACCESS call with checks of the mode bits. On NFS,
the mode bits do _not_ suffice to determine access rights.

Trond

> >>> I mean that read a dir, such as lookup a dir.
> >>> If I reply a getattr as that dir has no lookup permission, and then do a
> >>> "cat /nfsroot/dir/file" at client, client will not send lookup procedure to
> >>> server, because client used the cache data of the dir. It like this:
> >>> client server
> >>> #ls /nfsroot
> >>> readdirplus ------------------>
> >>> <------------- readdirplus reply
> >>> (attribute of dir has no lookup permission)
> >>> # cat /nfsroot/dir/file
> >>> (send nothing, used cache data)
> >>> -------no package is send-------
> >>>
> >>> If no cache data exists, it would like this:
> >>> client server
> >>> #ls /nfsroot
> >>> readdirplus ------------------>
> >>> <------------- readdirplus reply
> >>> (attribute of dir has no lookup permission)
> >>> # cat /nfsroot/dir/file
> >>> access(dir) ------------------->
> >>> <------------- access reply(dir)
> >>> (has no lookup permission)
> >>>
> >>> And if has permission to lookup dir, it would like this:
> >>> client server
> >>> #ls /nfsroot
> >>> readdirplus ------------------>
> >>> <------------- readdirplus reply
> >>> (attribute of dir has no lookup permission)
> >>> # cat /nfsroot/dir/file
> >>> access(dir) -------------------> (*1)
> >>> <------------- access reply(dir)
> >>> lookup(file) ------------------->
> >>> <------------- lookup reply(file)
> >>> read(file) ------------------->
> >>> <------------- read reply(file)
> >>>
> >>> While you optimize all write operations to omit access procedure, can
> >>> this access (*1) be omitted? Then lookup(file) will return NOPERM.
> >>>     
> >>>       
> >> So what if I change the permissions on the directory? What should the
> >> rules be for caching these attributes?
> >>
> >> ...and you still haven't replied to my question about what
> >> application/workload actually _cares_ about optimising for this
> >> particular case.
> >>   
> >>     
> > No application cares this ^_^, just for test.
> > I test the read op of dir, it maybe has tiny bug in it. As you said, if
> > I chmod of dir, client will be a little later to know this.
> > Test step ad following:
> >
> > [root@REHL ~]# mount -t nfs 192.168.0.19:/nfsroot /mnt
> > [root@REHL ~]# ll /mnt
> > total 4
> > dr-xr-xr-x 2 root root 4096 Jun 23  2007 dir
> > [root@REHL ~]# ll /mnt/dir
> > total 4
> > -rw-r--r-- 1 root root 5 Jun 24  2007 file
> > [root@REHL ~]# su weiyj
> > [weiyj@REHL root]$ ll /mnt
> > total 4
> > dr-xr-xr-x 2 root root 4096 Jun 23  2007 dir
> > [weiyj@REHL root]$ ll /mnt/dir
> > total 4
> > -rw-r--r-- 1 root root 5 Jun 24  2007 file
> > [weiyj@REHL root]$ cat /mnt/dir/file
> > test
> > [weiyj@REHL root]$ ssh 192.168.0.19 -l root chmod a-x /nfsroot/dir
> > [weiyj@REHL root]$ cat /mnt/dir/file
> > test
> > [weiyj@REHL root]$ cat /mnt/dir/file
> > test
> > [weiyj@REHL root]$ ll /mnt/dir
> > total 0
> > ?--------- ? ? ? ?            ? /mnt/dir/file
> > [weiyj@REHL root]$ ll /mnt
> > total 4
> > dr--r--r-- 2 root root 4096 Jun 23  2007 dir
> > [weiyj@REHL root]$ cat /mnt/dir/file
> > cat: /mnt/dir/file: Permission denied
> >   
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
