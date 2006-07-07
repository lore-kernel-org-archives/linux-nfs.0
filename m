From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Question about the nocto option in 2.4 and 2.6
Date: Fri, 07 Jul 2006 11:00:53 -0700
Message-ID: <1152295253.5385.5.camel@dyn9047022153>
References: <1152293821.5385.2.camel@dyn9047022153>
	<1152294191.5714.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyudM-0007Ja-Rz
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 11:00:56 -0700
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FyudL-0008BQ-T2
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 11:00:57 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k67I0l6q002836
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Fri, 7 Jul 2006 14:00:47 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k67I02gR302676
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 7 Jul 2006 12:00:02 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k67I0k5q001956
	for <nfs@lists.sourceforge.net>; Fri, 7 Jul 2006 12:00:46 -0600
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1152294191.5714.2.camel@lade.trondhjem.org>
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

On Fri, 2006-07-07 at 13:43 -0400, Trond Myklebust wrote:
> On Fri, 2006-07-07 at 10:37 -0700, Frank Filz wrote:
> > I'm consulting on an issue where we are seeing an increase in network
> > traffic between 2.4.21 and 2.6.9 kernels with the use of the nocto
> > option. This is raising a performance concern.
> > 
> > I'm wondering what has changed with this option between the two kernel
> > levels.
> 
> Nothing much. What does nfsstat tell you has changed?

I currently don't have access to the machines involved. I'm trying to
get a bit more information. Looking at the code, I do see that the check
for the nocto option has moved from nfs_open to nfs_lookup_verify_inode.

Frank



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
