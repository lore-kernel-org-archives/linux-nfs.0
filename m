From: Greg Banks <gnb@sgi.com>
Subject: Re: nfsd write throughput
Date: Wed, 4 Aug 2004 18:18:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040804081821.GQ5581@sgi.com>
References: <1091578243.4797.52.camel@dyn319492.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, okir@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsGz1-0000NV-2L
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 01:18:47 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BsGz0-0000R5-Hj
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 01:18:46 -0700
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: <1091578243.4797.52.camel@dyn319492.beaverton.ibm.com>
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

On Tue, Aug 03, 2004 at 05:10:44PM -0700, Bruce Allan wrote:
> Greg Banks <gnb@sgi.com> wrote on 08/02/2004 07:10:18 PM:
> 
> <snip>
> > First, the way the v3 server is supposed to work is that normal
> > page cache pressure pushes pages from unstable writes to disk
> > before the COMMIT call arrives from the client.  The best way to
> > achieve this for a dedicated NFS server box is tuning the pdflush
> > parameters to be more aggressive about writing back dirty pages,
> > e.g. bumping down the following in /proc/vm:
> > dirty_background_ration, dirty_ratio, dirty_writeback_centisecs,
> > and dirty_expire_centisecs.  I have to admit I've not tried this
> > yet on 2.6 but the equivalent on 2.4 has been generally useful.
> <snip>
> 
> This information (and the comparable info for 2.6) should be in Chapter
> 5. Optimizing NFS Performance of the NFS-HOWTO
> (http://nfs.sourceforge.net/nfs-howto/performance.html).

Yes.

> Greg, can you
> throw together a documentation patch?  If you don't have the time and/or
> inclination, I could give it a shot if you care to review the content. 

That document has several wrong or outdated pieces of advice, e.g. in
sections 5.1, 5.4, 5.7.  If you want me to write a diff it won't be
a trivial one and you'll have to wait while I plow through some of
the other four dozen bugs I have queued up.  I'm happy to do it if
you're happy to wait.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
