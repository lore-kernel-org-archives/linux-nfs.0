From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: nfsd write throughput
Date: Tue, 03 Aug 2004 17:10:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091578243.4797.52.camel@dyn319492.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: okir@suse.de, gnb@sgi.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bs9Mu-0006Lz-6Q
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 17:10:56 -0700
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bs9Mt-0006re-RQ
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 17:10:56 -0700
To: nfs@lists.sourceforge.net
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

Greg Banks <gnb@sgi.com> wrote on 08/02/2004 07:10:18 PM:

<snip>
> First, the way the v3 server is supposed to work is that normal
> page cache pressure pushes pages from unstable writes to disk
> before the COMMIT call arrives from the client.  The best way to
> achieve this for a dedicated NFS server box is tuning the pdflush
> parameters to be more aggressive about writing back dirty pages,
> e.g. bumping down the following in /proc/vm:
> dirty_background_ration, dirty_ratio, dirty_writeback_centisecs,
> and dirty_expire_centisecs.  I have to admit I've not tried this
> yet on 2.6 but the equivalent on 2.4 has been generally useful.
<snip>

This information (and the comparable info for 2.6) should be in Chapter
5. Optimizing NFS Performance of the NFS-HOWTO
(http://nfs.sourceforge.net/nfs-howto/performance.html).  Greg, can you
throw together a documentation patch?  If you don't have the time and/or
inclination, I could give it a shot if you care to review the content. 
Or will this be a wasted effort if Olaf's changes (or something along
those lines) gets in.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
