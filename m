From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: More Stale NFS handles
Date: Wed, 29 Jun 2005 17:04:47 -0400
Message-ID: <1120079087.8521.53.camel@lade.trondhjem.org>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
	 <1120076887.8751.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eiwe Lingefors <eiwe@jhu.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnjkD-0004Pm-Mp
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 14:05:17 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DnjkB-0007nv-9w
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 14:05:17 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: <1120076887.8751.34.camel@localhost.localdomain>
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

on den 29.06.2005 Klokka 13:28 (-0700) skreiv Kris Vassallo:

> > I'm not sure what additional information might be helpful. The  
> > problems I'm having essentially mirror those of others who have  
> > posted regarding stale NFS handles in the past few months on this  
> > list. I'm at my wits end after having fought with this problem for  
> > weeks.
> YES YES YES!!! It almost brings a state of insanity with it!! Plus,
> atop my insanity I have a group of 30 developers who are complaining
> about not being able to do work because of stale file handles. 

So have you all tried any of the newer server kernels?

There were some important fixes for the server ESTALE problems that went
into 2.6.10 IIRC 

http://linux.bkbits.net:8080/linux-2.6/cset@415b3380pxf4sB97gM8ujLqDxi6GfQ

and

http://linux.bkbits.net:8080/linux-2.6/cset@41997cc5nwxi8SY_jN4yhIPUSu_yVA?nav=index.html|src/|src/fs|related/fs/dcache.c

Do the kernels you've tested have these two patches?

Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
