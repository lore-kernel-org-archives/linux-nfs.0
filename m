From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Mon, 30 Aug 2004 10:25:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830082510.GD28454@suse.de>
References: <4124DB86.9060505@steeleye.com> <16677.22269.988036.787320@cse.unsw.edu.au> <412E1C10.5020703@steeleye.com> <20040827073049.GA23324@suse.de> <412F3362.5040707@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1hTZ-0007Ob-PV
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 01:25:17 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C1hTY-0002Ow-Sa
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 01:25:17 -0700
To: Paul Clements <paul.clements@steeleye.com>
In-Reply-To: <412F3362.5040707@steeleye.com>
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

On Fri, Aug 27, 2004 at 09:13:06AM -0400, Paul Clements wrote:
> With so many things moving out of the kernel to userland, it's 
> surprising to see statd moving into the kernel. And it certainly does 
> make modifications, such as this, much more difficult.

Well, the issue with statd is that it exists _only_ to make lockd happy.
But what it really does is make lockd awfully complicated because we
have to do upcalls all the time.

So my rationale for moving statd into the kernel is to actually eliminate
a lot of code and have a minimal set up functionality in there that does
exactly what lockd needs, no more. In particular, no more SM_MON and
SM_UNMON support that allows untrusted hosts to do sneaky stuff - instead,
lockd writes the /var/lib/nfs/sm files directly. The only thing my kernel
statd supports is SM_NOTIFY, and that even is delivered directly to the
locking code.

> But the callout happens before statd replies to the client, so there's 
> no chance that we lose any clients if there's a failure. If we use 
> dnotify then we only find out there's been a change after the change has 
> occurred, which means the client may have already gotten a reply saying 
> he's been added to the notify list. If we get a failure at this point, 
> we've lost a client, and upon failover the client's locks are no longer 
> valid.

Doesn't a HA NFS deployment require a shared disk anyway? Why not just
move /var/lib/nfs to this file system so it gets shared the same way you
share the rest of your data?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
