From: Christopher Huhn <C.Huhn@gsi.de>
Subject: Re: executable but not readable
Date: Fri, 26 Mar 2004 11:48:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40640A7E.5040601@gsi.de>
References: <40631E32.1020707@gsi.de> <1080239856.2584.18.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------020301070701000406040702"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6otE-0003ym-8s
	for nfs@lists.sourceforge.net; Fri, 26 Mar 2004 02:48:40 -0800
Received: from lxmta2.gsi.de ([140.181.67.43])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B6otD-00018X-Jt
	for nfs@lists.sourceforge.net; Fri, 26 Mar 2004 02:48:39 -0800
Received: from localhost (localhost [127.0.0.1])
	by lxmta2.gsi.de (Postfix) with ESMTP id 0F6721926C9
	for <nfs@lists.sourceforge.net>; Fri, 26 Mar 2004 11:48:32 +0100 (CET)
Received: from lxmta2.gsi.de ([127.0.0.1])
	by localhost (lxmta2 [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 16559-60 for <nfs@lists.sourceforge.net>;
	Fri, 26 Mar 2004 11:48:30 +0100 (CET)
Received: from gsi.de (lxg0815.gsi.de [140.181.70.60])
	by lxmta2.gsi.de (Postfix) with ESMTP id 3005A1926C1
	for <nfs@lists.sourceforge.net>; Fri, 26 Mar 2004 11:48:30 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <1080239856.2584.18.camel@lade.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------020301070701000406040702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Trond,

thanks first for your prompt answer.

Trond Myklebust wrote:

>P=E5 to , 25/03/2004 klokka 13:00, skreiv Christopher Huhn:
> =20
>
>>The clients are able to run these scripts with server kernel version 2.=
4.20.
>>Now we switched the server to 2.4.25 and get "permission denied" on=20
>>execution.
>>   =20
>>
>On page 99, RFC1813 states explicitly that
>
>   A similar problem has to do with paging in an executable
>   program over the network.=20
>
The point is that I'm not talking about (ELF) executables but shell=20
scripts!
IMHO in local semantics the shell interpreter cannot execute scripts the=20
executor has not read permissions for (How should he without beeing=20
setuid root?).

I made these tests with ls and a script ls.sh that simply calls ls :

    -rwxr-x--x    1 root     root        43784 Mar 18  2002 /bin/ls
    -rwxr-x--x    1 root     root           30 Mar 26 10:20 /bin/ls.sh

    nobody@client[2.4.25-gsi]# /bin/ls
    ... works ...

    nobody@client[2.4.25-gsi]# /bin/ls.sh
    /bin/ls.sh: /bin/ls.sh: Permission denied

and on the server:

    nobody@server[2.4.20]# /bin/ls
    ... works ...

    nobody@server[2.4.20]# /bin/ls.sh
    /bin/ls.sh: /bin/ls.sh: Permission denied

> To make this work, the server allows
>   reading of files if the uid given in the call has either
>   execute or read permission on the file.=20
>
This happens over NFS:

    root@client[2.4.25-gsi]# /nfs/mount/2.4.20/ls
    ...works ...

    root@client[2.4.25-gsi]# /nfs/mount/2.4.20/ls.sh
    ... works ...

    root@client[2.4.25-gsi]# cat /nfs/mount/2.4.20/ls.sh
    ... works (so no security improvements by setting sensitive scripts=20
--x over nfs ) ...

*but*

    root@client[2.4.25-gsi]# /nfs/mount/2.4.25/ls
    ... works ...

    root@client[2.4.25-gsi]# /nfs/mount/2.4.25/ls.sh
    /nfs/mount/2.4.25/ls.sh: /nfs/mount/2.4.25/ls.sh: Permission denied

and to complete this:

    root@client[2.4.20]# /nfs/mount/2.4.25/ls
    ... works ...

    root@client[2.4.20]# /nfs/mount/2.4.25/ls.sh
    /nfs/mount/2.4.25/ls.sh: /nfs/mount/2.4.25/ls.sh: Permission denied

Btw: Nor ls neither ls.sh can be cat'ed in these constellations.

>Again, this departs from
>   correct local file system semantics.
> =20
>
With 2.4.25 it seems to comply with the local  semantics rather than=20
RFC1813.

>So if the server is denying read access in 2.4.25, then someone must
>have introduced a bug...
> =20
>
That's what it seems, even though I like it the way it is now :-)

These are our specs:

Vanilla kernels 2.4.20 with

    CONFIG_NFS_FS=3Dm
    CONFIG_NFS_V3=3Dy
    # CONFIG_ROOT_NFS is not set
    CONFIG_NFSD=3Dy
    CONFIG_NFSD_V3=3Dy
    # CONFIG_NFSD_TCP is not set
    # CONFIG_NCPFS_NFS_NS is not set

and 2.4.25 with

    CONFIG_NFS_FS=3Dy
    CONFIG_NFS_V3=3Dy
    # CONFIG_NFS_DIRECTIO is not set
    CONFIG_ROOT_NFS=3Dy
    CONFIG_NFSD=3Dm
    CONFIG_NFSD_V3=3Dy
    CONFIG_NFSD_TCP=3Dy
    # CONFIG_NCPFS_NFS_NS is not set

The exports are rw,root_squash

The mount options are rw,sync,v3,rsize=3D8192,wsize=3D8192,hard,intr,udp,=
lock

We are using the nfs-common and nfs-kernel-server debian packages=20
version 1.0-2woody1.

Regards,
    Christopher



--------------020301070701000406040702
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Hi Trond,<br>
<br>
thanks first for your prompt answer. <br>
<br>
Trond Myklebust wrote:
<blockquote cite="mid1080239856.2584.18.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap="">P&aring; to , 25/03/2004 klokka 13:00, skreiv Christopher Huhn:
  </pre>
  <blockquote type="cite">
    <pre wrap="">The clients are able to run these scripts with server kernel version 2.4.20.
Now we switched the server to 2.4.25 and get "permission denied" on 
execution.
    </pre>
  </blockquote>
  <pre wrap=""><!---->On page 99, RFC1813 states explicitly that

   A similar problem has to do with paging in an executable
   program over the network. </pre>
</blockquote>
The point is that I'm not talking about (ELF) executables but shell
scripts! <br>
IMHO in local semantics the shell interpreter cannot execute scripts
the executor has not read permissions for (How should he without beeing
setuid root?).<br>
<br>
I made these tests with ls and a script ls.sh that simply calls ls :<br>
<br>
&nbsp;&nbsp;&nbsp; -rwxr-x--x&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 43784 Mar 18&nbsp; 2002 /bin/ls<br>
&nbsp;&nbsp;&nbsp; -rwxr-x--x&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 30 Mar 26 10:20 /bin/ls.sh<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:nobody@client[2.4.25-gsi">nobody@client[2.4.25-gsi</a>]# /bin/ls<br>
&nbsp;&nbsp;&nbsp; ... works ...<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:nobody@client[2.4.25-gsi">nobody@client[2.4.25-gsi</a>]# /bin/ls.sh<br>
&nbsp;&nbsp;&nbsp; /bin/ls.sh: /bin/ls.sh: Permission denied<br>
<br>
and on the server:<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:nobody@server[2.4.20">nobody@server[2.4.20</a>]# /bin/ls<br>
&nbsp;&nbsp;&nbsp; ... works ...<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:nobody@server[2.4.20">nobody@server[2.4.20</a>]# /bin/ls.sh<br>
&nbsp;&nbsp;&nbsp; /bin/ls.sh: /bin/ls.sh: Permission denied<br>
<blockquote cite="mid1080239856.2584.18.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap=""> To make this work, the server allows
   reading of files if the uid given in the call has either
   execute or read permission on the file. </pre>
</blockquote>
This happens over NFS:<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.25-gsi">root@client[2.4.25-gsi</a>]# /nfs/mount/2.4.20/ls<br>
&nbsp;&nbsp;&nbsp; ...works ...<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.25-gsi">root@client[2.4.25-gsi</a>]# /nfs/mount/2.4.20/ls.sh<br>
&nbsp;&nbsp;&nbsp; ... works ...<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.25-gsi">root@client[2.4.25-gsi</a>]# cat /nfs/mount/2.4.20/ls.sh<br>
&nbsp;&nbsp;&nbsp; ... works (so no security improvements by setting sensitive scripts
--x over nfs ) ...<br>
<br>
*but*<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.25-gsi">root@client[2.4.25-gsi</a>]# /nfs/mount/2.4.25/ls<br>
&nbsp;&nbsp;&nbsp; ... works ...<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.25-gsi">root@client[2.4.25-gsi</a>]# /nfs/mount/2.4.25/ls.sh<br>
&nbsp;&nbsp;&nbsp; /nfs/mount/2.4.25/ls.sh: /nfs/mount/2.4.25/ls.sh: Permission denied<br>
<br>
and to complete this:<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.20">root@client[2.4.20</a>]# /nfs/mount/2.4.25/ls<br>
&nbsp;&nbsp;&nbsp; ... works ...<br>
<br>
&nbsp;&nbsp;&nbsp; <a class="moz-txt-link-abbreviated" href="mailto:root@client[2.4.20">root@client[2.4.20</a>]# /nfs/mount/2.4.25/ls.sh<br>
&nbsp;&nbsp;&nbsp; /nfs/mount/2.4.25/ls.sh: /nfs/mount/2.4.25/ls.sh: Permission denied<br>
<br>
Btw: Nor ls neither ls.sh can be cat'ed in these constellations.<br>
<blockquote cite="mid1080239856.2584.18.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap="">Again, this departs from
   correct local file system semantics.
  </pre>
</blockquote>
With 2.4.25 it seems to comply with the local&nbsp; semantics rather than
RFC1813.<br>
<blockquote cite="mid1080239856.2584.18.camel@lade.trondhjem.org"
 type="cite">
  <pre wrap="">So if the server is denying read access in 2.4.25, then someone must
have introduced a bug...
  </pre>
</blockquote>
That's what it seems, even though I like it the way it is now <span
 class="moz-smiley-s1"><span> :-) </span></span><br>
<br>
These are our specs:<br>
<br>
Vanilla kernels 2.4.20 with <br>
<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFS_FS=m<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFS_V3=y<br>
&nbsp;&nbsp;&nbsp; # CONFIG_ROOT_NFS is not set<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFSD=y<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFSD_V3=y<br>
&nbsp;&nbsp;&nbsp; # CONFIG_NFSD_TCP is not set<br>
&nbsp;&nbsp;&nbsp; # CONFIG_NCPFS_NFS_NS is not set<br>
<br>
and 2.4.25 with <br>
<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFS_FS=y<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFS_V3=y<br>
&nbsp;&nbsp;&nbsp; # CONFIG_NFS_DIRECTIO is not set<br>
&nbsp;&nbsp;&nbsp; CONFIG_ROOT_NFS=y<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFSD=m<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFSD_V3=y<br>
&nbsp;&nbsp;&nbsp; CONFIG_NFSD_TCP=y<br>
&nbsp;&nbsp;&nbsp; # CONFIG_NCPFS_NFS_NS is not set<br>
<br>
The exports are rw,root_squash<br>
<br>
The mount options are
rw,sync,v3,rsize=8192,wsize=8192,hard,intr,udp,lock<br>
<br>
We are using the nfs-common and nfs-kernel-server debian packages
version 1.0-2woody1.<br>
<br>
Regards, <br>
&nbsp;&nbsp;&nbsp; Christopher<br>
<br>
<br>
</body>
</html>

--------------020301070701000406040702--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
