From: "Bryan J. Smith" <b.j.smith@ieee.org>
Subject: Re: recursive NFS export of mounted ISO images -- Automounter Maps?
Date: Wed, 23 Oct 2002 16:44:13 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035405853.3db70a1d229ae@webmail.smithconcepts.com>
References: <Pine.LNX.4.44.0210231520230.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Bryan J. Smith" <b.j.smith@ieee.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from knight.01.dios.net ([65.222.230.112] helo=taz2.fiberhosting.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184SMU-00034i-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:44:18 -0700
To: Dave Ingram <davei@wolfram.com>
In-Reply-To: <Pine.LNX.4.44.0210231520230.31286-100000@wopr.wolfram.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Quoting Dave Ingram <davei@wolfram.com>:
> I understand. But I think it's odd that I did the following 
> successfully:
> 1. Mounted 3 ISO images from the /Source partition to /Jukebox
> 2. Added entries for each of the /Jukebox/... directories into
> 'exports'
> 3. Reloaded NFS
> 4. Successfully NFS mounted and used the files from the server
> How is that possible if one cannot cross filesystem boundaries on 
> the server side? The source partition is different than the destination
> partition.

And you're mounting the source partition too, right?  That should work then.

> Ah. That's provided that all your clients can deal with autofs. We 
> have every *NIX flavor you can think of here. The single common 
> denominator for them is NFS.
> Well, you're lucky - Linux and Solaris support autofs and have 
> consistent mechanisms for configuring them. Some of our *NIX's either 
> don't have anything like autofs/NIS or have completely different ways of
> configuring them.

Really?  I've messed with AIX and Irix too and it had both as well.

Sometimes I've had to create maps named "auto_master_irix" and similiar, but it
worked.

> I'm still confused then how I was able to perform the experiment 
> quoted earlier. From all appearances, I *did* cross filesystems (which
> as I said confuses me greatly)

If you mount _both_ the .iso source _and_ the loopback mount, it _will_ work.

> You're assuming again that all the client machines HAVE something 
> even remotely like "mkisofs". A lot of them do not.

First off, mkisofs runs on _everything_ I've seen, even Windows.

Secondly, run "mkisofs" on the server, but write on the client.

> Unfortunately that just isn't how our software engineering system 
> works. SQA is explicit about having the files they test be directly
> FROM the ISO image.

As an engineer myself, used to working in production testing environments, I
find this logic rather flawed.  You aren't really running from the .iso image
anyway.  ;-P

> Burning many CDs every day and shuffling them around is a
> nightmare, which is why we're trying to do this.

Again, I think your QA process is not exactly true.

> No, I *have* worked with automounter, under Solaris several years
> ago.

What UNIX client flavors are you running anyway?

-- 
Bryan J. Smith, E.I.            Contact Info:  http://thebs.org
A+/i-Net+/Linux+/Network+/Server+ CCNA CIWA CNA SCSA/SCWSE/SCNA
---------------------------------------------------------------
           limit      guilt   =     { psychopath,
         remorse->0                    innocent }



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
