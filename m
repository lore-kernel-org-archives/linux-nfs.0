From: Olaf Kirch <okir@suse.de>
Subject: Re: auto-discovery of exports?
Date: Thu, 8 Apr 2004 10:55:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040408085557.GA19482@suse.de>
References: <41089CB27BD8D24E8385C8003EDAF7AB084850@karl.alexa.com> <4074B2BD.7936CF93@melbourne.sgi.com> <20040408065413.GA19702@suse.de> <4074FA2D.C7002C3B@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Guolin Cheng <guolin@alexa.com>, Ian Kent <raven@themaw.net>,
	Michael <mogmios@mlug.missouri.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBVO1-0003k4-4E
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 01:59:49 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BBVO0-0001y1-Mp
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 01:59:48 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <4074FA2D.C7002C3B@melbourne.sgi.com>
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

On Thu, Apr 08, 2004 at 05:07:25PM +1000, Greg Banks wrote:
> The ones based on modern ONC code, like Solaris and IRIX, explicitly
> allow NULL calls before doing their fancy checks based on program numbers.
> I'd be interested to hear of actual counterexamples.

Wietse Venema's portmapper which I think all Linux distributors
use has this:

    if (prog == PMAPPROG || prog == NFSPROG || prog == YPXPROG ||
        (prog == MOUNTPROG && aproc == MOUNTPROC_MNT) ||
        (prog == YPPROG && aproc != YPPROC_DOMAIN_NONACK)) {
        log_no_forward(addr, proc, prog);
        return (FALSE);
    }

so you're right, calling the MOUNT NULL procedure via PMAP_CALL
should work. You could even broadcast a DUMP call...

Calling NFS NULL will not work, though.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
