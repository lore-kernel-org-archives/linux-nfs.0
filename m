From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: knfsd brought to its knees, by a simple rsync or cp operation
Date: Tue, 1 Mar 2005 08:21:29 -0600
Message-ID: <EXCHG20031XvpFVjCRG00000008@EXCHG2003.microtech-ks.com>
References: <20050301065703.7e52cf4e@be.back.l8r.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D68Cu-0002ch-0T
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 06:18:40 -0800
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D68Cq-00022e-0N
	for nfs@lists.sourceforge.net; Tue, 01 Mar 2005 06:18:39 -0800
To: "'Brad Barnett'" <lists@L8R.net>, <nfs@lists.sourceforge.net>
In-Reply-To: <20050301065703.7e52cf4e@be.back.l8r.net>
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

Brad,

My post will bounce, so it won't go to the list, my email and domain
name don't agree.

The problem is simple, I have never found a decent solution to it.

The basic issue is that a large local cp quickly fills up the buffer cache
on the local machine and can cause the nfsd processes to starve and have
difficulty getting in their io.  Watch what happens to the buffer cache
and disk when this is happening.   The later versions of linux should 
be worse as they fill the buffer cache faster.    I suspect that the 
problem is that there is always a long line of operations to take care
of and when NFS comes along it has to get in line behind whatever is
already queued up.

I have seen it on older versions of linux (2.2) and it took around 2-3
to make things really bad, but 1 would do a good job of making response
bad.   

                                 Roger

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Brad Barnett
> Sent: Tuesday, March 01, 2005 5:57 AM
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] knfsd brought to its knees, by a simple 
> rsync or cp operation
> 
> On Tue, 1 Mar 2005 10:55:48 +0100
> Olaf Kirch <okir@suse.de> wrote:
> 
> > On Mon, Feb 28, 2005 at 11:20:18AM -0500, Brad Barnett wrote:
> > > I start a long and extensive cp -a process on the nfs 
> server.  Local 
> > > 'ls' responses are instant.  Write and read operations 
> are instant 
> > > (it's a raid 10) on the local box, as well.  However, my single 
> > > remote client's "ls" operation changes to a jerky, slow 
> operation.. 
> > > with upwards of 5 second pauses in reads.
> > 
> > Are you using NFS over UDP? If you ping the server from the 
> client, do 
> > the round trip time and packet loss rate change when you start the 
> > heavy IO jobs on the server?
> 
> I just tried, and ping times do not visibly change (0.1ms 
> before and after).
> 
> However, this is what is really erking me.  This isn't a 
> heavy I/O job. 
> This is just _one_ cp.  Nothing else is happening on the 
> entire server!  I just did, in the above test:
> 
> client: ls -R /home
> 
> The client is fine, for very long periods of time...
> 
> Then, while the above command is still happening:
> 
> server: cp -a /raid/home /raid/hometest
> 
> Within 10 seconds, the output of ls -R /home slows.  Within 
> 20 seconds, it _stop_.  It then sits there for seconds, and 
> spews out a page in small jumps.  Again, a ls /raid/home on 
> the _server_ barely slows, and is constant.
> 
> I'm really scratching my head here.
> 
> 
> 
> 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide Read honest & 
> candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net 
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
