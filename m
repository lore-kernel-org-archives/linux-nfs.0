From: Martynas Buozis <martynas@ti.com>
Subject: Re: nfsroot problems on RedHat 8 with kernel linux-2.4.18-27.8.0
Date: Fri, 23 May 2003 15:39:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ECE2479.3000706@ti.com>
References: <3ECE0EF3.5080004@ti.com> <shs4r3lx1ux.fsf@charged.uio.no>
Reply-To: martynas@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from jester.ti.com ([192.94.94.1])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JClL-0001an-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 06:39:11 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello

Thank you for response. Alias this is not a case.

Disk less client gets host name via bootp. And I specify to use autoconf 
to get it via bootp in kernel parameters like it is written in 
nfsroot.txt. I also see, that it is configured with right IP and right 
host name. These line comes before NFS mount is tried :

IP-Config: Complete:
       device=eth0, addr=<correct address>, mask=255.255.255.0, 
gw=<correct address>,
      host=testmws, domain=, nis-domain=(none),
      bootserver=<correct address>, rootserver=<correct address>, rootpath=

All entries in this configuration information are correct. The problem 
is, that nfsroot module itself sends mount request without information 
that is required by Celerra.

When system is booted up (same IP and host name but using another boot 
tree with identical file shared on SUN/Solaris) I can mount there file 
systems shared on Celerra (simple "mount cellera:/share /mnt" command) 
In this case usual mount command sends all information Celerra expects 
to get. So I think that problem is really in nfsroot module itself. 
Maybe it is too old, because it does not support all options available 
for usual command line  mount command as specified in "man nfs" ?


With best regards
Martynas Buozis




Trond Myklebust wrote:
>>>>>>" " == Martynas Buozis <martynas@ti.com> writes:
>>>>>
> 
>      > Hello I have problems with nfsroot module when root file system
>      > is shared on EMC Cellerra. The problem is, that Celerra needs
>      > the
> 
>      > client's name and IP address to authenticate the mount
>      > request. This information is usually sent through the RPC
>      > authentication data. But nfsroot module does not send this data
>      > during mount, so Celerra denies request. This was a conclusion
>      > by EMC support after analyzing network's traffic between disk
>      > less station and Celerra.
> 
> 
>      > I was looking what can be changed in
>      > /usr/src/linux-2.4/fs/nfs/nfsroot.c code, but I am not very
>      > experienced in this. Maybe somebody can help me to solve this
>      > problem ? Maybe that's wrong file were too look for changes ? 
>      > Is it possible to make changes like this and is it possible to
>      > get official fix fro this problem ?
> 
> Look at Documentation/nfsroot.txt and/or the comments in
> net/ipv4/ipconfig.c. That will tell you how to specify the hostname.
> 
> Cheers,
>   Trond




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
