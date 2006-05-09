From: Neil Brown <neilb@suse.de>
Subject: Re: trace attached - Re: Folder in NFS-Share-Permission denied-but
 the user is group member
Date: Tue, 9 May 2006 10:44:10 +1000
Message-ID: <17503.58842.535096.648874@cse.unsw.edu.au>
References: <445B30FD.9040103@vwi.tu-dresden.de>
	<17499.15037.908665.125536@cse.unsw.edu.au>
	<445F05BD.8010503@vwi.tu-dresden.de>
	<17503.11043.7670.762241@cse.unsw.edu.au>
	<445F3A91.2030809@vwi.tu-dresden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdGKz-0003Fm-Jl
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 17:44:29 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FdGKx-00040I-V4
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 17:44:29 -0700
To: kolbe@vwi.tu-dresden.de
In-Reply-To: message from Steffen Kolbe on Monday May 8
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

On Monday May 8, kolbe@vwi.tu-dresden.de wrote:
> >>-----------------------------------------------------------
> >>general question:
> >>Is their a real solution to use ~50 groups with nfs? Because we've many 
> >>project groups, some team leaders, many crossover memberships over some 
> >>departments and .......
> >>How is this solved in bigger environments?
> >>    

No easy answers I'm afraid.

One option is a hack on the client to get it to sort the gids so that
the gid of the file being accessed appears first in the list.
I believe there were patches to do this floating around a while ago.
However Trond didn't like them and that is quite understandable.  It
is, after all, a hack.

Another option is to do something on the server side.  When a request
arrives, the uid could be mapped to a list of gids, and these could be
added to the list in the request.
I think this is a sensible approach and I have thought about it a few
times, but never got around to actually doing it ... and nor did
anyone else.

Finally you can ditch AUTH_UNIX altogether and use AUTH_GSS.  This
requires you to have a Kerberos authentication infrastructure set up
and requires bleeding edge kernel and tools.  It is similar to option
two in that the list of gids is calculated on the server rather than
on the client.  It is different in that it is actually implemented (I
think).

Finally+1 ... if you feel like recompiling all your own kernels, you
could change one constant on the server and client and raise the limit
to 128 groups.  This would work fine, but you could have
interoperability problems.  I recall that Tru64 Unix simply sent all
the gids in the NFS request, and our Solaris servers rejected any
request from any user wit more than 16 - not good.

I don't know how "bigger environments" handle this.  My approach has
always been to find some group that wasn't really needed, and remove
it.

NeilBrown


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
