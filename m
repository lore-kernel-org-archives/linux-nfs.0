From: Olaf Kirch <okir@suse.de>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp operation
Date: Mon, 28 Feb 2005 11:06:33 +0100
Message-ID: <20050228100633.GA4822@suse.de>
References: <20050226082854.2a496ec3@be.back.l8r.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5hnX-0001Se-NG
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 02:06:43 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D5hnV-0000AV-76
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 02:06:43 -0800
To: Brad Barnett <lists@L8R.net>
In-Reply-To: <20050226082854.2a496ec3@be.back.l8r.net>
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

On Sat, Feb 26, 2005 at 08:28:54AM -0500, Brad Barnett wrote:
> There is obviously something wacky in the way the kernel is scheduling
> things here.  Any ideas, patches, suggestions?

That's because knfsd will write things to disk synchronously unless you
tell it not to. That can throttle other NFS activity in two locations:

 -	by tying up all knfsd threads on the server. Try to bump the
 	number of nfsd processes

 -	by tying up all RPC slots on the client. Make sure your wsize
 	isn't too big (8k is reasonable)

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
