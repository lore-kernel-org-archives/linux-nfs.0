From: Joseph Landman <landman@scalableinformatics.com>
Subject: RE: Re: network storage solutions
Date: 15 May 2003 18:25:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1053037542.10395.16.camel@protein.scalableinformatics.com>
References: <482A3FA0050D21419C269D13989C6113127DD1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Beowulf <beowulf@beowulf.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl093-000-201.det1.dsl.speakeasy.net ([66.93.0.201] helo=crunch.scalableinformatics.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GRAb-0004OU-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 15:25:49 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113127DD1@lavender-fe.eng.netapp.com>
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

On Thu, 2003-05-15 at 17:01, Lever, Charles wrote:

> > I would like to know that as well.  I would like to believe 
> > it will not
> > continue with corrupt data, but return an error code/condition which
> > should be handled.
> 
> to quote:
> 
>   If a soft time-out interrupts a write operation, there is no
>   guarantee that the file on the server is correct, nor is there
>   any guarantee that the client's cached version of the file matches
>   what is on the server.

This text isn't in my man page for mount (RH8.0).  Thanks for the
pointer.  The semantics of "soft" exist then for what purpose?  Is this
a "performance" switch that benchmark folks like?

I used it for remote file backup purposes, mount the file system to be
backed up with the soft, intr options (and large rsize/wsize, and
vers=3), and then dump.  With the hard option, when there was an error,
I had machine crashes.  With soft, I could recover.


-- 
Joseph Landman, Ph.D
Scalable Informatics LLC
email: landman@scalableinformatics.com
  web: http://scalableinformatics.com
phone: +1 734 612 4615



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
