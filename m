From: Jan Bruvoll <jan@bruvoll.com>
Subject: Re: Strange delays on NFS server
Date: Tue, 24 Aug 2004 11:27:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412B17F6.3030700@bruvoll.com>
References: <411A17F2.2060203@RedHat.com> <411A448D.3080205@stams.strath.ac.uk> <20040811164135.GA11101@suse.de> <411B8987.1030609@stams.strath.ac.uk> <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <20040816131434.GL3510@suse.de> <4120C8D5.3040606@stams.strath.ac.uk> <20040816145435.GQ3510@suse.de> <4124CD95.7020007@stams.strath.ac.uk> <20040820095854.GC23176@suse.de> <412B0EDE.5010206@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzYWT-0004q9-DI
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 03:27:25 -0700
Received: from homer.brvl.com ([213.61.99.172])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BzYWR-0004kr-Oa
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 03:27:25 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <412B0EDE.5010206@stams.strath.ac.uk>
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

Dear all,

Ian Thurlbeck wrote:

> I have tested the patched kernel - it is no different. In fact
> I'd say it's slightly worse.  I've been running "atop" to monitor
> net/disk io and during an "event" I see that the main 3ware raid
> array is writing at 100% (60MB/sec+) for up to 50 seconds.  There
> is little network traffic. During this period client machines are
> unusable if they are requesting stuff off the server.


I haven't had the opportunity to test things this thoroughly yet, but I 
see the same symptoms on our server here - when the "hick-up" comes, the 
server, if under heavy fire, will be completely unresponsive for as long 
as it is trying to get out of the mess. After a little while, things 
will clear up again (I guess that could have to do with clients just 
giving up on things), just to clog up about a minute later.

And as Ian mentions, the clients will be stuck for as long as this goes on.

Thanks very much for your continued efforts - if there is anything I 
could do to help debug this issue or otherwise contribute to the fixing 
of this problem, I'd happily oblige!

Best regards
Jan



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
