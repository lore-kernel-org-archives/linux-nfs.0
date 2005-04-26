From: Kris Vassallo <kris@linuxcertified.com>
Subject: Re: Stale File handles keep coming back
Date: Tue, 26 Apr 2005 15:22:29 -0700
Message-ID: <1114554149.4470.5.camel@localhost.localdomain>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-Exnnqur/e56lO4z2JdM6"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQYS3-0008II-7v
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 15:22:43 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQYRz-0003gc-Iy
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 15:22:43 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17006.13241.129839.558300@cse.unsw.edu.au>
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


--=-Exnnqur/e56lO4z2JdM6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2005-04-26 at 05:27, Neil Brown wrote:

> On Monday April 25, kris@linuxcertified.com wrote:
> > I am experiencing a problem with stale file handles, and I have not been
> > able to find an answer in the archives nor has doing anything in the
> > readme helped. I apologize if an answer has already been posted
> > regarding an issue such as this. After many frustrating hours of
> > troubleshooting I am hoping for some help. The mail is long but I am
> > hoping that it answers all the questions. 
> 
> Very odd...
> 
> The output of:
> 
>   echo 2048 > /proc/sys/sunrpc/rpc_debug
>   grep . /proc/net/rpc/*/content
>   ls -l /proc/fs/nfsd
>   cat /proc/fs/nfs/exports

As you wished:

[root@venus ~]# echo 2048 > /proc/sys/sunrpc/rpc_debug
[root@venus ~]# grep . /proc/net/rpc/*/content
/proc/net/rpc/auth.unix.ip/content:#class IP domain
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555250 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.35 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554736 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.31 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555091 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.32 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554725 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.33 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114553809 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.30 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554372 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.23 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554950 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.20 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554967 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.22 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555344 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.15 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554495 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.16 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555310 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.18 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555306 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.13 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555211 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.7 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555134 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.8 10.113.1.0/26
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554927 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.9 10.113.1.0/26
/proc/net/rpc/nfs4.idtoname/content:#domain type id [name]
/proc/net/rpc/nfs4.nametoid/content:#domain type name [id]
/proc/net/rpc/nfsd.export/content:#path domain(flags)
/proc/net/rpc/nfsd.export/content:# expiry=1114555041 refcnt=1
/proc/net/rpc/nfsd.export/content:/home
10.113.1.0/26(rw,no_root_squash,sync,no_wdelay,no_subtree_check)
/proc/net/rpc/nfsd.fh/content:#domain fsidtype fsid [path]
/proc/net/rpc/nfsd.fh/content:# expiry=1114555041 refcnt=0
/proc/net/rpc/nfsd.fh/content:10.113.1.0/26 0 0x1100080000000002 /home

[root@venus ~]# ls -l /proc/fs/nfsd/
total 0
-r--r--r--  1 root root 0 Apr 22 19:14 exports
-rw-------  1 root root 0 Apr 22 19:14 filehandle
-rw-------  1 root root 0 Apr 22 19:14 nfsv4leasetime
-rw-------  1 root root 0 Apr 22 19:14 threads

[root@venus ~]# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/home   10.113.1.0/26(rw,no_root_squash,sync,no_wdelay,no_subtree_check)
[root@venus ~]#

Hope this helps! 
Thanks for taking a look at this, 
Kris


> 
> might help.
> 
> Thanks,
> NeilBrown

--=-Exnnqur/e56lO4z2JdM6
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
On Tue, 2005-04-26 at 05:27, Neil Brown wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>On Monday April 25, kris@linuxcertified.com wrote:
&gt; I am experiencing a problem with stale file handles, and I have not been
&gt; able to find an answer in the archives nor has doing anything in the
&gt; readme helped. I apologize if an answer has already been posted
&gt; regarding an issue such as this. After many frustrating hours of
&gt; troubleshooting I am hoping for some help. The mail is long but I am
&gt; hoping that it answers all the questions. 

Very odd...

The output of:

  echo 2048 &gt; /proc/sys/sunrpc/rpc_debug
  grep . /proc/net/rpc/*/content
  ls -l /proc/fs/nfsd
&nbsp; cat /proc/fs/nfs/exports</I></FONT></PRE>
</BLOCKQUOTE>
As you wished:<BR>
<BR>
[root@venus ~]# echo 2048 &gt; /proc/sys/sunrpc/rpc_debug<BR>
[root@venus ~]# grep . /proc/net/rpc/*/content<BR>
/proc/net/rpc/auth.unix.ip/content:#class IP domain<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555250 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.35 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554736 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.31 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555091 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.32 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554725 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.33 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114553809 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.30 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554372 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.23 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554950 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.20 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554967 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.22 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555344 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.15 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554495 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.16 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555310 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.18 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555306 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.13 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555211 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.7 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114555134 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.8 10.113.1.0/26<BR>
/proc/net/rpc/auth.unix.ip/content:# expiry=1114554927 refcnt=0<BR>
/proc/net/rpc/auth.unix.ip/content:nfsd 10.113.1.9 10.113.1.0/26<BR>
/proc/net/rpc/nfs4.idtoname/content:#domain type id [name]<BR>
/proc/net/rpc/nfs4.nametoid/content:#domain type name [id]<BR>
/proc/net/rpc/nfsd.export/content:#path domain(flags)<BR>
/proc/net/rpc/nfsd.export/content:# expiry=1114555041 refcnt=1<BR>
/proc/net/rpc/nfsd.export/content:/home 10.113.1.0/26(rw,no_root_squash,sync,no_wdelay,no_subtree_check)<BR>
/proc/net/rpc/nfsd.fh/content:#domain fsidtype fsid [path]<BR>
/proc/net/rpc/nfsd.fh/content:# expiry=1114555041 refcnt=0<BR>
/proc/net/rpc/nfsd.fh/content:10.113.1.0/26 0 0x1100080000000002 /home<BR>
<BR>
[root@venus ~]# ls -l /proc/fs/nfsd/<BR>
total 0<BR>
-r--r--r--&nbsp; 1 root root 0 Apr 22 19:14 exports<BR>
-rw-------&nbsp; 1 root root 0 Apr 22 19:14 filehandle<BR>
-rw-------&nbsp; 1 root root 0 Apr 22 19:14 nfsv4leasetime<BR>
-rw-------&nbsp; 1 root root 0 Apr 22 19:14 threads<BR>
<BR>
[root@venus ~]# cat /proc/fs/nfs/exports<BR>
# Version 1.1<BR>
# Path Client(Flags) # IPs<BR>
/home&nbsp;&nbsp; 10.113.1.0/26(rw,no_root_squash,sync,no_wdelay,no_subtree_check)<BR>
[root@venus ~]#<BR>
<BR>
Hope this helps! <BR>
Thanks for taking a look at this, <BR>
Kris<BR>
<BR>
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>
might help.

Thanks,
NeilBrown</I></FONT></PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-Exnnqur/e56lO4z2JdM6--



-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
