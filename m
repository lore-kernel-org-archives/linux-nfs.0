From: Steve Wampler <swampler@noao.edu>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!"
	message?
Date: Wed, 21 Jan 2004 09:12:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074701572.18082.55.camel@weaver.tuc.noao.edu>
References: <43397.68.42.103.198.1074701040.squirrel@webmail.uio.no>
Reply-To: swampler@noao.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjKyV-0006s8-En
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 08:13:03 -0800
Received: from noao.edu ([140.252.1.54])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjKyV-0004xw-6d
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 08:13:03 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <43397.68.42.103.198.1074701040.squirrel@webmail.uio.no>
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

On Wed, 2004-01-21 at 09:04, trond.myklebust@fys.uio.no wrote:
> P=E5 on , 21/01/2004 klokka 10:22, skreiv Steve Wampler:
> > The above message still appears from time to time and
> > files don't always appear on some clients until an unmount/mount cycle
> > of the NFS partitions.  This is a problem, of course.
> >
> > Any ideas?  Is the 2.4.18smp kernel flakey with respect to
> > NFS?
>=20
> Which filesystem are you using on your server?

ext2

> It certainly is a bug for a server to be setting nlink to 0. That
> indicates after all that the file has been deleted. It shouldn't be
> served up at all in that case, and certainly not for a LOOKUP request.

Hmmm, while I don't know how to identify which file, I suspect
it's one where the following action takes place:

Client A:
       Builds a new version of files locally and copies them over
       to server, replacing existing files.

Client B:
       Accesses files on server

Might this be a timing issue of some sort, where client B
accesses the file in the middle of the replacement?  (so it
then is referencing the original (deleted on replacement)
copy)?  I wouldn't think so, but know so little about NFS.

Thanks again for your help!
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
