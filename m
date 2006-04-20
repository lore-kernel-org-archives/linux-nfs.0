From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Cache on NFS
Date: Thu, 20 Apr 2006 05:37:53 -0400
Message-ID: <44475671.4070204@RedHat.com>
References: <17088.195.6.25.114.1145518879.squirrel@vaala.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWVbo-0002RE-R3
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 02:37:56 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FWVbn-0003eX-In
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 02:37:56 -0700
To: squale@vaala.mine.nu
In-Reply-To: <17088.195.6.25.114.1145518879.squirrel@vaala.mine.nu>
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

squale@vaala.mine.nu wrote:
> hi,
> 
> i d like to get you experience on the following problem.
> 
> I want to access a NFS server but also to have a cache of all the files to
> access those if (and only if) the NFS server is unreachable.
> 
> What would better work for that case ?
I think what your looking for is the Coda Filesystem
(see http://www.coda.cs.cmu.edu/). Its not NFS but it does have has
disconnected operations...

steved.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
