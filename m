From: Olaf Kirch <okir@suse.de>
Subject: Re: xprt_bindresvport
Date: Thu, 9 Dec 2004 12:01:24 +0100
Message-ID: <20041209110124.GA15055@suse.de>
References: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcM3A-0002zR-Jd
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:01:32 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CcM35-0004ku-PC
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:01:32 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
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

On Wed, Dec 08, 2004 at 06:33:15AM -0800, Lever, Charles wrote:
> > port by counting down from 800 to 0. I think this is a bug, because it
> > will potentially interfere with services trying to bind to 
> > low ports as
> > well.
> 
> is this idle speculation, or do you actually have a test case that
> fails?  :^)

I've seen many cases of glibc's bindresvport (which allocates from
600-1023) snatching ports used by other services, e.g. cups. The way
we solve this in user space is by having a file in /etc with a blacklist
of ports bindresvport isn't allowed to touch.

I admit that I haven't seen NFS step on someone else toes yet. But it
all depends on the number of mounts you have, and on coincidence.

At any rate, it really looks like a bug to me. Why should our scan include
ports in the low range (which is a no-no) but refuse to touch ports in the
800-1023 range? It's just an inverted test, IMO.

> i don't agree.  you're just making the bad behavior more rare by
> choosing ports at random; you are not actually addressing the root
> problem you describe.  is it possible to fix the RPC client to retry the
> connection in this case?  and/or fix the server to recognize and remove
> the context for the old connection?

You cannot fix the RPC client. It will not see any packets from the
server, so it simply sits there until it times out and retries the
connection. This can cause system boot to take quite a long time.

You can fix the firewall, this is currently being tossed around on the
netfilter list. Unfortunately not all routers out there run the latest and
greatest netfilter code; so we don't really have much control over that.

> introducing randomness here will make reproducing problems in this area
> very difficult.

I agree. And I would only enable randomization if we change the port
range to 600-up or something like this.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
