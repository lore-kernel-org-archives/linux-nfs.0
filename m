From: Ian Kent <raven@themaw.net>
Subject: Re: udp ports not being released
Date: Tue, 23 Nov 2004 09:34:12 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0411230919420.27086@wombat.indigo.net.au>
References: <41A2413A.9020800@analog.com> <41A24453.6000907@sun.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dwight Marzolf <dwight.marzolf@analog.com>,
	nfs@lists.sourceforge.net, autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWPYc-00016s-I2
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 17:33:26 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CWPYZ-0007iU-8d
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 17:33:26 -0800
To: Mike Waychison <Michael.Waychison@Sun.COM>
In-Reply-To: <41A24453.6000907@sun.com>
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

On Mon, 22 Nov 2004, Mike Waychison wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Dwight Marzolf wrote:
> > We are running RedHat 8, kernel 2.4.20-20.8smp and autofs 4.1.2.  We
> > were having a variety of automount problems until a kernel patch was
> > recommended.  We added this patch, recompiled our kernel, and
> > distributed the patched kernel to all of our workstations.  About 90% of
> > our problems disappeared.  But one problem seems to remain.
> > 
> > When /net is used to mount directories, most of the time the udp port
> > used for that nfs mount operation is not released once the /net mount
> > times out.   Depending on the level of activity on a machine, over the
> > period of several days, all the available reserved ports are used up. 
> > At that point the user on the workstation cannot cd to any mount points
> > in our automount maps except the ones already mounted.  In the
> > /var/log/messages the following error occurs for attempted mounts:
> 
> IIRC, automount 4.1.2 had a fd leak, that was fixed in 4.1.3

Yes and also in 4.1.3. There is a patch on kernel.org but it has been 
superceeded and not updated. I'll update it soon as I can (called 
autofs-4.1.3-sock-leak-fix.patch).

I'm not sure about the socket leaks anyway. We fix them because it's good 
practice but it appears that most of this happens in sub-processes, which 
once finished close all their open fds. This certainly seems to work 
correctly from what I've tested.

For Redhat Jeff Moyers' rpms track the important fixes. Dwight, you should 
try using one of them since you have problems.

> 
> Ian?
> 
> > 
> > RPC: Can't bind to reserved port
> > 
> > In my experiments I found that doing a "umount -l /net" releases all the
> > udp ports immediately.  Our workaround has been to kill all the autofs
> > processes, do a umount -l on all mount points in /etc/mtab, and them
> > restart the autofs process.
> > 
> > My question is (1) is there any fix for this problem or some switch I
> > need to turn on/off in order for these udp ports to be released when the
> > mount point times out and (2) is there some command that I can use to
> > release these ports rather than going through the multiple step process
> > I described above to clean up a machine?

See above.

There is of course the possiblity this is a new problem so let us know 
about your progress if any.

Ian



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
