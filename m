From: Stefan Palme <kleiner@hora-obscura.de>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 17:13:43 +0200
Message-ID: <1152890024.28625.70.camel@devel.office.ancoso-development.de>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
	<20060714092612.GA11555@janus>
	<1152870249.28636.34.camel@devel.office.ancoso-development.de>
	<1152879442.28635.40.camel@devel.office.ancoso-development.de>
	<1152879562.28633.42.camel@devel.office.ancoso-development.de>
	<76bd70e30607140615x606fb651r61d09d636147336b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1PMT-0003le-V8
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 08:13:49 -0700
Received: from moutng.kundenserver.de ([212.227.126.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1PMS-0002NM-Lp
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 08:13:50 -0700
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 5959B878048
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 17:13:47 +0200 (CEST)
Received: from devel.office.ancoso-development.de
	(p54B98F43.dip0.t-ipconnect.de [84.185.143.67])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id EEECA878022
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 17:13:44 +0200 (CEST)
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <76bd70e30607140615x606fb651r61d09d636147336b@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


> However, there is another alternative for your application.  NFS
> implements "close-to-open" caching.  This means an "open()" will force
> the client to revalidate its cache.  Since the *directory* is updated
> during a create, you need to open() the directory to force a cache
> refresh.  An opendir() on the directory containing the new file should
> enable your application to see the freshly created file immediately.

Because my application is written in Python, I have no access to the
opendir()-syscall directly. But the Python-Function "listdir()" from 
the os module uses this syscall (according to the Python source code).

But after using listdir(), the problem still persists:


  callToRemoteApplicationToCreateFile('file1')
  os.listdir('/my/imported/directory')
  f = file('/my/imported/directory/file1')

--> "No such file or directory"


An "ls /my/imported/directory" shows the file. Are you sure, that
opendir() causes the cache refresh? If yes, the problem must be
on the Python-side, so I have to look there...

thanks and regards
-stefan-





-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
