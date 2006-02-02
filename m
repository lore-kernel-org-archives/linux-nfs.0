From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: NFS reliability in Enterprise Environment
Date: Wed, 01 Feb 2006 16:33:46 -0800
Message-ID: <1138840427.26648.178.camel@seki.nac.uci.edu>
References: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
	 <b83c9e30602011608s6ba5b8d9sc2c9b01e27740ce0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4SQI-0006mT-2z
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 16:34:06 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4SQF-00035W-6c
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 16:34:06 -0800
To: Brian Kerr <kerrboy@gmail.com>
In-Reply-To: <b83c9e30602011608s6ba5b8d9sc2c9b01e27740ce0@mail.gmail.com>
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

On Wed, 2006-02-01 at 19:08 -0500, Brian Kerr wrote:
> On 2/1/06, David Sullivan <david.sullivan@activant.com> wrote:
> >
> > Does anyone have any data they can share on the reliability of Linux NFS
> > servers (not clients) in an enterprise environment (e.g. server uptimes,
> > number of volumes shared, number of clients, IO rates)?  I have a large
> > enterprise application set (about 10K programs) that uses NFS for
> > file-sharing.  A movement is afoot at my company to port the applications
> > from the more expensive "big iron" Unix systems it is currently deployed on
> > to less expensive Linux x86 servers.  I'm trying to do a baseline risk
> > assessment of this move, and I'd like some empirical data (or some
> > speculative) on the reliability of NFS.  Even better would be a contrast in
> > reliability to shared-storage filesystems like GFS or OCFS2.
> er tcp(only).
> 
> While I can't share exact IO and stats I can tell you that it keeps up
> with netapp filers that consistently push 40-80MBit/second 24/7/365. 
> Be sure to do some research on kernel and hardware obviously and you
> should be good.
> 
> I would be interested to hear of anyone else using GFS in an NFS
> implmentation.  Shortly we will be moving some NFS servers to large
> storage arrays and we need all NFS servers to see the same filesystems
> for redundancy and scalability.  From what I've gathered GFS is ready
> for primetime - I would love to hear how it works from a NFS
> perspective.
> 
> -Brian

We tried GFS served out over NFS, and it didn't work out well at all.

In fact, since we had a bunch of 2 terabyte slices that were made
available via GFS, we could've just eliminated GFS altogether, because
32 bit linux can do that -without- GFS.  Sorry my GFS notes are a little
sketchy, but my manager seemed to want to do the GFS stuff himself :)  I
mostly just documented how to start it up and shut it down:

        http://dcs.nac.uci.edu/~strombrg/gfs_procedures.html


We later tried Lustre, but that didn't work out well in combination with
NFS either, despite our having contracted with the vendor to -make- it
work.  It was just iteration after iteration and patch after patch, and
"it's the hardware" vs "it's the software" because we had so many
vendors involved.  My lustre notes are far less sketchy, because I got
to take a lead role in that one for the most part:

        http://dcs.nac.uci.edu/~strombrg/Lustre-notes.html

I also still have reams of log data that I shared with the vendor:

        http://dcs.nac.uci.edu/~strombrg/lustre-info-for-CFS.html

...and as I skim through it, I'm recalling that I eventually discovered
that we were getting errors even on the lustre NAS head that was serving
data out over NFS - IE, with no NFS involved at all.  Then again, we
were using a fork off the lustre mainline that wasn't to be merged back
into the mainline (which means if we ever needed to upgrade, we'd
probably end up contracting with them again to merge the needed changes
into either the mainline, or -another- fork).


We eventually got IBM to buy back the PC hardware they sold us for the
storage farm, got a StorEdge 3511 and a sparc box from Sun, and we had
about 16 terabytes up in short order.  We're using a sparc with Solaris
on it as a NAS head for all that data, and then an AIX system accesses
the data over NFS.


QFS, the filesystem we're using on it, is actually kind of cool.  It
allows you to easily aggregate data into one huge filesystem, and it
merges the volume management and filesystem layers for performance - but
I'm glad it's them maintaining the combination and not me :)




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
