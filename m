From: Greg Banks <gnb@sgi.com>
Subject: Re: auto-discovery of exports?
Date: Sun, 11 Apr 2004 19:44:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040411094422.GA19914@sgi.com>
References: <41089CB27BD8D24E8385C8003EDAF7AB084850@karl.alexa.com> <4074B2BD.7936CF93@melbourne.sgi.com> <20040408065413.GA19702@suse.de> <4074FA2D.C7002C3B@melbourne.sgi.com> <20040408085557.GA19482@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>, Guolin Cheng <guolin@alexa.com>,
        Ian Kent <raven@themaw.net>, Michael <mogmios@mlug.missouri.edu>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BCbW9-0006CV-N5
	for nfs@lists.sourceforge.net; Sun, 11 Apr 2004 02:44:45 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BCbW9-0003FF-Kr
	for nfs@lists.sourceforge.net; Sun, 11 Apr 2004 02:44:45 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040408085557.GA19482@suse.de>
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

On Thu, Apr 08, 2004 at 10:55:57AM +0200, Olaf Kirch wrote:
> [...]calling the MOUNT NULL procedure via PMAP_CALL
> should work.

Righto.

> You could even broadcast a DUMP call...

Except that the reply might blow the libc 8800 byte limit for
UDP RPC replies (I've seen this happen).

> Calling NFS NULL will not work, though.

Indeed.

So it seems an approach that would work is to a broadcast
RPC call to MOUNT NULL followed by showmount -e to each
of the repliers.  Something like...

/usr/sbin/rpcinfo -b mountd 1 | while read IPADDR NAME ; do
    showmount -e --no-headers $NAME | ...
done

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
