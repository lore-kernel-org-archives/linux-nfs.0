From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Strange delays on NFS server
Date: Wed, 11 Aug 2004 08:58:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411A17F2.2060203@RedHat.com>
References: <4119FB15.7010205@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Busgc-0003dN-Gc
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 05:58:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Busgc-0002ul-3m
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 05:58:34 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <4119FB15.7010205@stams.strath.ac.uk>
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



Ian Thurlbeck wrote:

> I am getting strange delays on our NFS server. Everything will
> be fine for maybe 5 to 10 minutes, then saving a small text file
> from a client machine will suddenly take 15 seconds or more.
> Similarly, mozilla will pause accessing a page for ages ~30secs
> (I assume it's poking about in ~/.mozilla). Everything pops back to 
> normal afterwards. NFS server is lightly used at the moment.

Boy... it sure sounds to me like some type of daemon or something is 
starting up
that is bring the machine to its knees... . Would it be possible to have 
a top -i running
on the server when this pause occurs?

SteveD.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
