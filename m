From: Brad Barnett <lists@L8R.net>
Subject: Re: knfsd brought to its knees, by a simple rsync or cp
 operation
Date: Tue, 1 Mar 2005 06:57:03 -0500
Message-ID: <20050301065703.7e52cf4e@be.back.l8r.net>
References: <20050226082854.2a496ec3@be.back.l8r.net>
	<20050228100633.GA4822@suse.de>
	<20050228102307.3788a184@be.back.l8r.net>
	<20050228154455.GS4822@suse.de>
	<20050228112018.34fdeb2b@be.back.l8r.net>
	<20050301095548.GJ14402@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D65zx-0004x3-7g
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 03:57:09 -0800
Received: from l8r.net ([64.26.155.43] ident=aliens)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D65zv-0007j1-IJ
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 03:57:09 -0800
Received: from be.back.l8r.net (bbarnett@be [10.10.10.10])
	by l8r.net (8.12.3/8.12.3/Debian-7.1) with ESMTP id j21BuLuu001353
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 1 Mar 2005 06:56:22 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20050301095548.GJ14402@suse.de>
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

On Tue, 1 Mar 2005 10:55:48 +0100
Olaf Kirch <okir@suse.de> wrote:

> On Mon, Feb 28, 2005 at 11:20:18AM -0500, Brad Barnett wrote:
> > I start a long and extensive cp -a process on the nfs server.  Local
> > 'ls' responses are instant.  Write and read operations are instant
> > (it's a raid 10) on the local box, as well.  However, my single remote
> > client's "ls" operation changes to a jerky, slow operation.. with
> > upwards of 5 second pauses in reads.
> 
> Are you using NFS over UDP? If you ping the server from the client, do
> the round trip time and packet loss rate change when you start the
> heavy IO jobs on the server?

I just tried, and ping times do not visibly change (0.1ms before and
after).

However, this is what is really erking me.  This isn't a heavy I/O job. 
This is just _one_ cp.  Nothing else is happening on the entire server!  I
just did, in the above test:

client: ls -R /home

The client is fine, for very long periods of time...

Then, while the above command is still happening:

server: cp -a /raid/home /raid/hometest

Within 10 seconds, the output of ls -R /home slows.  Within 20 seconds, it
_stop_.  It then sits there for seconds, and spews out a page in small
jumps.  Again, a ls /raid/home on the _server_ barely slows, and is
constant.

I'm really scratching my head here.






-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
