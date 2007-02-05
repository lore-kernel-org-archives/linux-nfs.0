From: "Suresh Jayaraman" <sjayaraman@novell.com>
Subject: Re: Move .nfsXXXX files
Date: Mon, 05 Feb 2007 10:51:11 -0700
Message-ID: <45C7BD8B.8E99.00F4.0@novell.com>
References: <6ffeae550701310533p3bc731b3of53e4da4dd05d98d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "Trinabh Shukla" <trinabh@gmail.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HE7xG-0001pc-T3
	for nfs@lists.sourceforge.net; Mon, 05 Feb 2007 09:48:38 -0800
Received: from lucius.provo.novell.com ([137.65.248.127])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HE7xF-0004C5-5X
	for nfs@lists.sourceforge.net; Mon, 05 Feb 2007 09:48:40 -0800
In-Reply-To: <6ffeae550701310533p3bc731b3of53e4da4dd05d98d@mail.gmail.com>
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

>On January 31, 2007 at 7:03 PM, "Trinabh Shukla" <trinabh@gmail.com> wrote:

> The .nfsXXXX file get created when I remove a file while it's being kept
> open by one of the process. Due to this I can't remove directory which hold
> this file. So I want to move this .nfsXXXX file on different temp directory
> on the same nfs file system and delete that directory. Here it's working
> properly.
>
> But let me know that is it a correct solution? And removal of .nfs files
> does not cause the server serious integrity.
 
If you're not bothered about the process which has that file open,
better kill the process. Moving to temp dir has problems as Trond 
mentioned, even if sticky bit(chmod 777+t) is set for the temp dir.

> Also it will be good, if you lead some pointers about how this .nfsXXXX
> files handle by the NFS server.

As the server has no clue of file opens, it cannot implement "delete on 
last close". Also, there is a possibility that client could crash or 
neglect to remove the hidden files. So server may want to cleanup
these files periodically. Some servers (eg. Solaris servers) have a cron 
script which searches exported filesystem for these files that
haven't not been accessed for a while and deletes them.

Thanks,
Suresh


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
