From: Greg Banks <gnb@sgi.com>
Subject: Re: Strange delays on NFS server
Date: Wed, 25 Aug 2004 12:02:41 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040825020241.GB16037@sgi.com>
References: <20040811164135.GA11101@suse.de> <411B8987.1030609@stams.strath.ac.uk> <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <20040816131434.GL3510@suse.de> <4120C8D5.3040606@stams.strath.ac.uk> <20040816145435.GQ3510@suse.de> <4124CD95.7020007@stams.strath.ac.uk> <20040820095854.GC23176@suse.de> <412B0EDE.5010206@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bzn7n-00049v-5M
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 19:02:55 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bzn7l-0001ST-KS
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 19:02:54 -0700
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

On Tue, Aug 24, 2004 at 10:48:14AM +0100, Ian Thurlbeck wrote:
> 
> What on earth could be writing up to 3GB of data to the drive ?
> As before the usual suspects of kjournald, kupdated, bdflush and
> nfsd turn up on the process list.
> 
> Just how big is the nfs write cache on a typical server ?

It can be most of RAM.

> Is it
> writing the whole lot one go ?

It might be.  What ratio of COMMIT to WRITE calls are you
seeing in nfsstat?  Does the export have "sync" or "async"
in its options?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
