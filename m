From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: auto-discovery of exports?
Date: Thu, 08 Apr 2004 17:07:25 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4074FA2D.C7002C3B@melbourne.sgi.com>
References: <41089CB27BD8D24E8385C8003EDAF7AB084850@karl.alexa.com> <4074B2BD.7936CF93@melbourne.sgi.com> <20040408065413.GA19702@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guolin Cheng <guolin@alexa.com>, Ian Kent <raven@themaw.net>,
        Michael <mogmios@mlug.missouri.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBTdS-0007RT-Eq
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 00:07:38 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBTdS-0001zz-8L
	for nfs@lists.sourceforge.net; Thu, 08 Apr 2004 00:07:38 -0700
To: Olaf Kirch <okir@suse.de>
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

Olaf Kirch wrote:
> 
> Some portmaps may actually allow calls to the NFS NULL procedure, but
> many don't.

The ones based on modern ONC code, like Solaris and IRIX, explicitly
allow NULL calls before doing their fancy checks based on program numbers.
I'd be interested to hear of actual counterexamples.

> I wrote a tool for enumerating NFS servers a long time back, and found
> the only way to go about it is to enumerate all hosts first, then do a
> pmap_getport(100005), and then call each mountd i turn.

Sure, a two stage approach will work: broadcast RPC to find hosts
running portmappers, then try showmount -e on each.

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
