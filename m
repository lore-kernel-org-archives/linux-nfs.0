From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc which isn't checked...
Date: Sun, 8 Feb 2004 15:30:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208203018.GA27482@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org> <20040208043723.GC13391@fieldses.org> <20040207214637.387d3018.akpm@osdl.org> <20040208055921.GA14053@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ApvZU-0001jT-Il
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:30:28 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1ApvZU-0005UI-3l
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:30:28 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040208055921.GA14053@fieldses.org>
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

On Sun, Feb 08, 2004 at 12:59:21AM -0500, J. Bruce Fields wrote:
> Yeah, I took a look and noticed there's an exit from that lookup
> function that doesn't release the lock.  Something like the following
> (untested) probably fixes it; I'll test and resubmit revised patches if
> Neil doesn't first.

Alright, I reproduced the hang here and verified that this fixes it.
(Note: the nfsd filesystem must be unmounted and the export must be to a
non-wildcard client to see the hang.  And the kernel probably needs to
be SMP.)  The revised patch series follows, though, with the fix and the
reordering, in case that's more convenient.

--Bruce Fields


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
