From: Tim Pickard <tpickard@crossref.org>
Subject: RE: NFS configuration question + ext3 question
Date: Wed, 07 May 2003 09:19:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <PGEKLHJLLGLFPCINFLBLCEIFDJAA.tpickard@crossref.org>
References: <shsd6iv8uep.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta8.algx.net ([67.92.168.237] helo=chimta03.algx.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DOjC-00058O-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 06:12:58 -0700
Received: from TPICKARD
 (ip67-89-23-170.z23-89-67.customer.algx.net [67.89.23.170])
 by chimmx03.algx.net
 (iPlanet Messaging Server 5.2 HotFix 1.10 (built Jan 23 2003))
 with SMTP id <0HEI003ZIQ1CFW@chimmx03.algx.net> for nfs@lists.sourceforge.net;
 Wed, 07 May 2003 08:12:49 -0500 (CDT)
In-reply-to: <shsd6iv8uep.fsf@charged.uio.no>
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

Thanks for the input.

I am thinking that my simple test is not a valid one.  It does work on same
machine but not on different machines with a shared volume.

I will be implementing the file locking.

Secondarily, how much of an increase in reliability/speed is there in moving
to ext3 from ext2 file system?  I am following the optimization steps.

Tim Pickard
Systems Support Analyst and Administrator
40 Salem Street
Lynnfield, MA  01940
p.781-295-0072
f.781-295-0077
tpickard@crossref.org

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent: Tuesday, May 06, 2003 8:37 PM
To: Tim Pickard
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS configuration question



     > What am I missing?

The basic fact that NFS was never designed with data cache consistency
in mind. The only way to ensure that processes on different machines
consistently see the same data is to use file locking in order to
synchronize their caches.

Cheers,
  Trond




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
