From: Brad Barnett <lists@L8R.net>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp
 operation
Date: Wed, 2 Mar 2005 11:41:47 -0500
Message-ID: <20050302114147.3ceb47e0@be.back.l8r.net>
References: <20050226082854.2a496ec3@be.back.l8r.net>
	<20050228100633.GA4822@suse.de>
	<20050228102307.3788a184@be.back.l8r.net>
	<20050228154455.GS4822@suse.de>
	<20050228112018.34fdeb2b@be.back.l8r.net>
	<20050301095548.GJ14402@suse.de>
	<20050301065703.7e52cf4e@be.back.l8r.net>
	<20050301143732.GA22324@suse.de>
	<20050301181007.382a1422@be.back.l8r.net>
	<20050302090312.GA5003@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Brad Barnett <lists@L8R.net>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6Wv8-0002I2-AK
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 08:41:58 -0800
Received: from l8r.net ([64.26.155.43] ident=aliens)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D6Wux-0008Qu-W3
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 08:41:58 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050302090312.GA5003@suse.de>
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

On Wed, 2 Mar 2005 10:03:13 +0100
Olaf Kirch <okir@suse.de> wrote:

> On Tue, Mar 01, 2005 at 06:10:07PM -0500, Brad Barnett wrote:
> > > Well, it sounds like something's eating the network bandwidth,
> > > or otherwise interfering with nfsd responsiveness. Again, are
> > > you using UDP or TCP? If UDP, look at nfsstat output to see if
> > > you have a high retransmit count.
> > > 
> > 
> > In my original post, I did mention that I can copy large files (isos)
> > over the network at excellent speeds.  That is, I get over 6M/sec
> > transfer speed...
> 
> Stil you won't answer: UDP or TCP? :-)

Sorry Olaf, heh.  UDP.

> 
> And the question about retransmits referred to the situation where you
> see the slow-downs.

I did check this before, in was in an NFS howto someplace, and I did not
notice a large number of retransmits (there were one or two per several
minutes)..

> 
> > > If it's really a problem with scheduling, it should make a
> > > difference if you run the rsync job with lower priority, and/or
> > > renice the nfsd threads to run with higher priority.
> > 
> > You can't really renice the kernel nfsd threads though :((
> 
> renice -20 -p <pid of nfsd> works for me.
> 

Right, but that doesn't effect anything in the kernel...

Anyhow, the problem is solved, please see my other message about changing
i/o schedulers...

Thanks!




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
