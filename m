From: Brad Barnett <lists@L8R.net>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp
 operation
Date: Tue, 1 Mar 2005 18:10:07 -0500
Message-ID: <20050301181007.382a1422@be.back.l8r.net>
References: <20050226082854.2a496ec3@be.back.l8r.net>
	<20050228100633.GA4822@suse.de>
	<20050228102307.3788a184@be.back.l8r.net>
	<20050228154455.GS4822@suse.de>
	<20050228112018.34fdeb2b@be.back.l8r.net>
	<20050301095548.GJ14402@suse.de>
	<20050301065703.7e52cf4e@be.back.l8r.net>
	<20050301143732.GA22324@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6GVZ-00083f-6s
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 15:10:29 -0800
Received: from l8r.net ([64.26.155.43] ident=aliens)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D6GVE-0003ue-SA
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 15:10:28 -0800
Received: from be.back.l8r.net (bbarnett@be [10.10.10.10])
	by l8r.net (8.12.3/8.12.3/Debian-7.1) with ESMTP id j21N9Nuu011779
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 1 Mar 2005 18:09:23 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20050301143732.GA22324@suse.de>
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

On Tue, 1 Mar 2005 15:37:32 +0100
Olaf Kirch <okir@suse.de> wrote:

> On Tue, Mar 01, 2005 at 06:57:03AM -0500, Brad Barnett wrote:
> > Within 10 seconds, the output of ls -R /home slows.  Within 20
> > seconds, it_stop_.  It then sits there for seconds, and spews out a
> > page in small jumps.  Again, a ls /raid/home on the _server_ barely
> > slows, and is constant.
> > 
> > I'm really scratching my head here.
> 
> Well, it sounds like something's eating the network bandwidth,
> or otherwise interfering with nfsd responsiveness. Again, are
> you using UDP or TCP? If UDP, look at nfsstat output to see if
> you have a high retransmit count.
> 

In my original post, I did mention that I can copy large files (isos) over
the network at excellent speeds.  That is, I get over 6M/sec transfer
speed...


> If it's really a problem with scheduling, it should make a difference
> if you run the rsync job with lower priority, and/or renice the
> nfsd threads to run with higher priority.

You can't really renice the kernel nfsd threads though :((


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
