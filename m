From: Greg Banks <gnb@sgi.com>
Subject: Re: NAS server avalanche overload
Date: Thu, 4 Mar 2004 11:04:38 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040304000438.GA25910@sgi.com>
References: <1078302718.825.67.camel@localhost> <1078351343.821.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AygRj-0003Zn-5M
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 16:10:39 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ayg2w-0004Hr-AM
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 15:45:02 -0800
To: Erik Walthinsen <omega@pdxcolo.net>
In-Reply-To: <1078351343.821.28.camel@localhost>
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

On Wed, Mar 03, 2004 at 02:02:23PM -0800, Erik Walthinsen wrote:
> Greg Banks said:
> > Are you using the "async" export option on the server?  It causes
> > similar symptoms when used with large NFS writes.  Use "sync".
> 
> Mount options as reported by /proc/mounts are:
> rw,noatime,rsize=4096,wsize=4096,intr,soft,noac,tcp

And the export options are?  cat /etc/exports on the server.

The noatime option has no effect over NFS.  Your [rw]sizes are
really quite small, try 8K.  Also, try turning off noac.

> I'm pretty sure the default here is async, as I had sync on there
> earlier and it actually caused a noticeable drop in performance.

So did you get the collapse with sync ?

> What I'm wondering is if the default bdflush settings are putting a hard
> cap on how much data can be write-cached, forcing the system to block
> writes too early.  With 512MB of RAM, say half available as write-cache,
> even at the rate of 5MB/sec, we should be able to run for almost a
> minute with complete disk starvation before things start to wedge.  And
> since this doesn't look like complete starvation at all (graphs show
> I/O's are completing the whole time), it should last even longer.

The problem I've seen is that the data is written out from the page
cache with the BKL held, which prevents any nfsd thread from waking up
and responding to incoming requests, and NFS traffic drops to zero.
In addition, if any of the nfsd's owned some other lock when this
happened, some local processes can be blocked too.  This is an
inevitable result of the "async" export option.

> If anyone has any ideas on what to tweak in bdflush, it seems that there
> *is* some pattern in the spikes, with them occurring at 11:25pm and
> 12:00am every day for at least the last 3 days.

You could try reducing the 1st parameter in /proc/sys/vm/bdflush
to say 5 and decrease the 5th parameter by a similar factor.  This
will activate kupdated more frequently and it will write data out
earlier.  But, did I mention the "sync" export option?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
