From: Chris Newbold <cnewbold@laurelnetworks.com>
Subject: Revisting mmap() and truncate() related corruption
Date: 05 Feb 2004 20:56:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1076032596.30653.24.camel@s4>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AovEU-0001l9-JH
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 17:56:38 -0800
Received: from paperclip.laurelnetworks.com ([63.94.127.69] ident=nobody)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AovEU-0008Av-5H
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 17:56:38 -0800
Received: from postit.laurelnetworks.com (postit.laurelnetworks.com [63.94.127.21])
	by paperclip.laurelnetworks.com (Laurel/Laurel) with ESMTP id i161ubgq021492
	for <nfs@lists.sourceforge.net>; Thu, 5 Feb 2004 20:56:37 -0500
Received: from localhost.localdomain (vpn-cnewbold.vpn.pit.laurelnetworks.com [10.0.12.123])
	by postit.laurelnetworks.com (Laurel/Laurel) with ESMTP id i161ua4K008764
	for <nfs@lists.sourceforge.net>; Thu, 5 Feb 2004 20:56:36 -0500
To: nfs@lists.sourceforge.net
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

We're running a large farm of compile servers, recently upgraded to
kernel 2.4.20 from 2.2.14. We use distcc for compilation. Shortly after
the upgrade, we started noticing object files were occasionally
corrupted, having the right length but full of nulls.

A little Googling turned up this thread
http://marc.theaimsgroup.com/?l=linux-nfs&m=104948555032343&w=2 that
pretty much sums up what we're seeing. I built fsx and tried in on our
network and it reveals the same type of corruption we're seeing during
compilation.

(I also tested a 2.4.24 kernel, which exhibited the same problem, and a
2.6.0-testXX kernel which did not exhibit any problems. The original
2.2.14 kernel also survived several hours of fsx without incident.)

distcc writes object files received from the network to disk by
mmap()'ing a file, using ftruncate() on it to get it to the right length
and then writing the data into it.

I have also seen mention of this issue in the distcc FAQ, where they
recommend using "no_subtree_check" when exporting NFS filesystems, but
our servers are NetApps, not Linux. So I don't think this is applicable.

After reading the thread cited above, I could not find any further
discussion of the problem or any evidence of the patch making it into a
released kernel.

So, I'd like to find out what ever happened with this issue and if there
ever were, or will be, any official fixes against the 2.4.x line...

Thanks.

-Chris Newbold
Laurel Networks, Inc.




-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
