From: Steve Wampler <swampler@noao.edu>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!"
	message?
Date: Thu, 22 Jan 2004 06:58:42 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074779922.18082.93.camel@weaver.tuc.noao.edu>
References: <38129.68.42.103.198.1074755215.squirrel@webmail.uio.no>
Reply-To: swampler@noao.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: neilb@cse.unsw.edu.au, Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjfM8-0005o3-H6
	for nfs@lists.sourceforge.net; Thu, 22 Jan 2004 05:58:48 -0800
Received: from lsstmail.org ([140.252.1.54] helo=noao.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AjfM8-00007b-84
	for nfs@lists.sourceforge.net; Thu, 22 Jan 2004 05:58:48 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <38129.68.42.103.198.1074755215.squirrel@webmail.uio.no>
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

On Thu, 2004-01-22 at 00:06, trond.myklebust@fys.uio.no wrote:
> P=E5 to , 22/01/2004 klokka 01:08, skreiv Neil Brown:
> > > It is still a bug, though. Neil?
> >
> > Is it?
> > Does the spec say I cannot return nlink =3D=3D 0   ?-)
>=20
> Not explicitly. However implicitly, yes it does. The all attributes are
> supposed to be
> read _atomically_ with the lookup and a file with nlink =3D=3D 0 could no=
t be
> looked up.

I have to agree with with Trond here (of course, I have a vested
interest...):  if 9 out of 10 identical clients correctly see a file
as updated on an NFS partition but the 10th doesn't (and won't until
an unmount/mount cycle of the partition) there's a bug there somewhere!

--=20
Steve Wampler -- swampler@noao.edu
The gods that smiled on your birth are now laughing out loud.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
