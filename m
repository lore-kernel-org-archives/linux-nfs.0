From: <trond.myklebust@fys.uio.no>
Subject: Re: What might cause:  "NFS: Buggy server - nlink == 0!" message?
Date: Wed, 21 Jan 2004 17:04:00 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <43397.68.42.103.198.1074701040.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AjKpw-0004X9-5t
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 08:04:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AjKpv-0000rL-P0
	for nfs@lists.sourceforge.net; Wed, 21 Jan 2004 08:04:11 -0800
To: <swampler@noao.edu>
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

På on , 21/01/2004 klokka 10:22, skreiv Steve Wampler:
> The above message still appears from time to time and
> files don't always appear on some clients until an unmount/mount cycle
> of the NFS partitions.  This is a problem, of course.
>
> Any ideas?  Is the 2.4.18smp kernel flakey with respect to
> NFS?

Which filesystem are you using on your server?

It certainly is a bug for a server to be setting nlink to 0. That
indicates after all that the file has been deleted. It shouldn't be
served up at all in that case, and certainly not for a LOOKUP request.

Cheers,
  Trond





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
