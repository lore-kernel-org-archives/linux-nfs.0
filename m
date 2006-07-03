From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Mon, 03 Jul 2006 17:33:36 +1000
Message-ID: <1151912016.18333.4.camel@hole.melbourne.sgi.com>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxIww-0002NE-Gs
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 00:34:30 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FxIwv-0002GM-Je
	for nfs@lists.sourceforge.net; Mon, 03 Jul 2006 00:34:30 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17576.25386.427824.894874@cse.unsw.edu.au>
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

On Mon, 2006-07-03 at 10:22, Neil Brown wrote:
> If anyone has patches that are ready and that I haven't included, now
> might be a good time to send them to me.

I believe I've managed to wrestle git to the ground, can you try

git pull git://oss.sgi.com:8090/gnb/nfs-utils

It's a bunch of mostly harmless warning fixes.  I can now
build nfs-utils on sles10 with no warnings except from the
generated *xdr.c files.  You may not agree with the way
I've used socklen_t conditionally, any feedback appreciated.

Thanks to Keith Owens and Nathan Scott for git help.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
