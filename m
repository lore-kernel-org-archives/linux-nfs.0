From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 10:27:57 -0500
Message-ID: <20060714102757.A29831@yoda.lmcg.wisc.edu>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
	<20060714092612.GA11555@janus>
	<1152870249.28636.34.camel@devel.office.ancoso-development.de>
	<1152879442.28635.40.camel@devel.office.ancoso-development.de>
	<1152879562.28633.42.camel@devel.office.ancoso-development.de>
	<76bd70e30607140615x606fb651r61d09d636147336b@mail.gmail.com>
	<1152890024.28625.70.camel@devel.office.ancoso-development.de>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1PaD-000537-ML
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 08:28:01 -0700
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1PaD-000697-NV
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 08:28:02 -0700
To: Stefan Palme <kleiner@hora-obscura.de>
In-Reply-To: <1152890024.28625.70.camel@devel.office.ancoso-development.de>;
	from kleiner@hora-obscura.de on Fri, Jul 14, 2006 at 05:13:43PM
	+0200
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

Stefan,

> Because my application is written in Python, I have no access to the
> opendir()-syscall directly. But the Python-Function "listdir()" from 
> the os module uses this syscall (according to the Python source code).
> 
> But after using listdir(), the problem still persists:
> 
> 
>   callToRemoteApplicationToCreateFile('file1')
>   os.listdir('/my/imported/directory')
>   f = file('/my/imported/directory/file1')
> 
> --> "No such file or directory"
> 
> 
> An "ls /my/imported/directory" shows the file. Are you sure, that
> opendir() causes the cache refresh? If yes, the problem must be
> on the Python-side, so I have to look there...

What I have done in similar cases is the following:

1.) Remote site creates file1
2.) Local site creates foo
3.) Local site tries to link foo to file1 (this should fail)
4.) Local site removes foo
5.) Local site opens file1

In bash the last 4 steps are:

$ touch foo
$ ln foo file1
ln: `file1': File exists
$ rm foo
$ cat file1

Perhaps you could try something similar in Python?

-- 
Dan


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
