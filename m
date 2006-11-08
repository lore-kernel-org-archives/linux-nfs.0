From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: PROBLEM: can't mkdir() in 2.6.19-rc3
Date: Wed, 8 Nov 2006 18:45:15 -0500
Message-ID: <20061108234515.GD16390@fieldses.org>
References: <20061101021647.GA4203@schwan.zoo>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ghx6i-0001CU-Uu
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 15:45:25 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ghx6i-00036s-UZ
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 15:45:26 -0800
To: Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
In-Reply-To: <20061101021647.GA4203@schwan.zoo>
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

On Wed, Nov 01, 2006 at 03:16:47AM +0100, Ingo Saitz wrote:
> [2.] Full description of the problem/report:
> 
> When I call "mkdir foo" on an nfs mounted volume, the strace of mkdir shows
> 
>     mkdir("foo", 0777)                      = -1 EPERM (Operation not permitted)
> 
> and the command fails. But if I do a "ls -ld foo" afterwards, the directory got
> created:
> 
>     drwxr-xr-x 2 ingo ingo 4096 2006-11-01 02:54 foo
> 
> The server is running 2.6.19-rc3, the client 2.6.18. The version of the
> nfs-kernel-server ist 1.0.10. This did work with 2.6.18 as nfs server.

Do you have the "async" option set on this export?  (What does

	exportfs -v

say?)

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
