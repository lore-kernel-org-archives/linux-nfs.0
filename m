From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Mon, 09 Feb 2004 18:46:36 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40273ADC.58AE1887@melbourne.sgi.com>
References: <40209B6D.56ED461E@melbourne.sgi.com> <402239C3.AD21DDAD@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aq69M-0007jN-KS
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 23:48:12 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aq69M-0005yq-31
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 23:48:12 -0800
To: James Pearson <james-p@moving-picture.com>
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

James Pearson wrote:
> 
> I notice this patch doesn't apply cleanly with Trond's fix_unlink patch

The second smaller version applies cleanly over fix_unlink.dif (with a 6 line
offset).

> - can the two patches live together?

Yes.  But...

If all you want is to prevent busy inodes and the subsequent oops, my patch
will do that in all cases.   As discussed earlier, Trond's patch still allows
busy inodes if the mount is "intr" and the last close is interrupted.  I have
a small test case which triggers this on a kernel with only Trond's patch.

OTOH, Trond's patch serialises the last close so that umount cannot proceed
until the .nfsXXX file is removed, which greatly reduces the chances of
short-lived mounts leaving turds on the server.  This is obviously a good
thing.

So I would recommend using both patches.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
