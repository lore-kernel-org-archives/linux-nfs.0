From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Mon, 30 Aug 2004 20:19:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830101947.GE5745@sgi.com>
References: <4124DB86.9060505@steeleye.com> <16677.22269.988036.787320@cse.unsw.edu.au> <412E1C10.5020703@steeleye.com> <20040827073049.GA23324@suse.de> <412F3362.5040707@steeleye.com> <20040830082510.GD28454@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Clements <paul.clements@steeleye.com>,
        Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1jGx-0004zl-5G
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 03:20:23 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C1jGw-00039e-Nv
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 03:20:23 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040830082510.GD28454@suse.de>
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

On Mon, Aug 30, 2004 at 10:25:11AM +0200, Olaf Kirch wrote:
> On Fri, Aug 27, 2004 at 09:13:06AM -0400, Paul Clements wrote:
> > With so many things moving out of the kernel to userland, it's 
> > surprising to see statd moving into the kernel. And it certainly does 
> > make modifications, such as this, much more difficult.
> 
> Well, the issue with statd is that it exists _only_ to make lockd happy.
> But what it really does is make lockd awfully complicated because we
> have to do upcalls all the time.

How is that any different from the other rpc calls lockd has to do?

> So my rationale for moving statd into the kernel is to actually eliminate
> a lot of code and have a minimal set up functionality in there that does
> exactly what lockd needs, no more. In particular, no more SM_MON and
> SM_UNMON support that allows untrusted hosts to do sneaky stuff - instead,

Didn't you fix that for CERT CA-99.05?  If configured correctly, statd
rejects calls not from localhost.  Probably it should also reject calls
not from a privileged port.

> Doesn't a HA NFS deployment require a shared disk anyway?

Shared data disks, not a shared root disk.

> Why not just
> move /var/lib/nfs to this file system so it gets shared the same way you
> share the rest of your data?

This would have to be done manually on a per-site basis because you
can't predict where the mountpoint of any particular shared disk will
be when NFS starts.  So packaging an HA solution based on that
arrangement would be a mite tricky.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
