From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: kernel Oops in rpc.mountd
Date: Tue, 8 Feb 2005 15:19:36 +1100
Message-ID: <16904.15832.499603.624714@cse.unsw.edu.au>
References: <200502080403.j1843mxO011918@m27.ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyMqn-0001Tj-16
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 20:19:45 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyMql-0004UW-HS
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 20:19:44 -0800
To: Stuart Anderson <anderson@ligo.caltech.edu>
In-Reply-To: message from Stuart Anderson on Monday February 7
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

On Monday February 7, anderson@ligo.caltech.edu wrote:
> I just had a physically different node Oops with an identical stack trace
> in rpc.mountd:

Well, that's pretty convincing!!!

The code in question is walking down a hash chain looking for old
entries to discard.  It finds an entry at 0x00100100.
My guess is that some entry is being freed without being unlinked
properly and the memory gets reused so that the ->next point becomes
corrupt.

If it is convenient, recompiling the kernel with
  CONFIG_DEBUG_SLAB=y

might help narrow down the problem, as the memory will be "poisoned"
as soon as it is freed.

I will also try to review the code and see if I can find a race that
might get lost.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
