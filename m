From: Bernd Nies <bnies@bluewin.ch>
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Wed, 08 Sep 2004 20:36:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413F5127.5030008@bluewin.ch>
References: <412EBAA100062E28@mssbzhh-int.msg.bluewin.ch> <1094662327.9493.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C57J9-00047p-Bq
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 11:36:39 -0700
Received: from mail2.bluewin.ch ([195.186.4.73])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C57J8-00005h-Ae
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 11:36:39 -0700
Received: from bluewin.ch (62.203.51.60) by mail2.bluewin.ch (Bluewin AG 7.0.030.2)
        id 412F8E4000170E54 for nfs@lists.sourceforge.net; Wed, 8 Sep 2004 18:36:24 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <1094662327.9493.42.camel@lade.trondhjem.org>
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

Hi Trond,

>>Martin Algesten reported that this might be caused by non-unique NFS cookies
>>in the same READDIRPLUS reply from the Apple NFS server but in our environment
>>with MacOS X 10.3.5 and SuSE Linux 9.0 (Kernel 2.4.21-243-smp4G, glibc-2.3.2-88)
>>I cannot confirm this. The NFS cookies are unique in the same READDIRPLUS
>>reply but not unique during the same NFS session.
>>
> 
> 
> What does this mean? That 2 different READDIRPLUS entries for the same
> directory may return the same cookie? That would a server bug...

The problem reported by Martin Algesten was: His MacOS X 10.3.4 NFS 
server sent a duplicate Cookie within the _same_ READDIRPLUS reply. See:

http://algesten.blogspot.com/index.html#109103599929132337

I can't observe that on our MacOS X 10.3.5 server. I only see that while 
traversing a NFS share with ls -lR on a Linux client the same Cookie ID 
appears in different READDIRPLUS replies of different directories. 
Because our Solaris NFS servers do the same and Linux NFS client works 
fine with it, I guess this is allowed.

So I think the endless looping ls -lR from a Linux NFS client on a Mac 
OS X 10.3.5 NFS share I reported is not related to that bug reported by 
Martin Algesten.

Here is the ethereal snoop of such an incident:

http://www.nies.ch/download/apple-linux-nfs-loop.tar.gz

I did a ls -lR on a MacOS X NFS share and in a certain directory it 
hung. A strace on the ls process shows that it loops over these system 
calls:

getdents64(5, /* 3 entries */, 4096)    = 128 
lstat64("/share/dir/file1.txt", {st_mode=S_IFREG|0444, st_size=8550, 
...}) = 0
getxattr("/share/dir/file1.txt", "system.posix_acl_access", (nil), 0) = 
-1 EOPNOTSUPP (Operation not supported)
lstat64("/share/dir/file2.txt", {st_mode=S_IFREG|0444, st_size=6570, 
...}) = 0
getxattr("/share/dir/file2.txt", "system.posix_acl_access", (nil), 0) = 
-1 EOPNOTSUPP (Operation not supported)
lstat64("/share/dir/file3.txt", {st_mode=S_IFREG|0444, st_size=23411, 
...}) = 0
getxattr("/share/dir/file3.txt", "system.posix_acl_access", (nil), 0) = 
-1 EOPNOTSUPP (Operation not supported)

This does not only happen with ls. It happens with all commands that 
want to read a certain directory (e.g. tar). A quick workaround is to 
create a new file in the directory where it loops.

Regards,
Bernd



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
