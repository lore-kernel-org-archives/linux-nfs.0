From: Gavin Hamill <gdh@acentral.co.uk>
Subject: Re: lockd / statd fun (sorry)
Date: Tue, 27 Apr 2004 14:43:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040427134343.GB1330@acentral.co.uk>
References: <200404231137.29216.gdh@acentral.co.uk> <200404231332.07891.bernd-schubert@web.de> <200404231248.30956.gdh@acentral.co.uk> <20040423115702.GQ3491@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BISqV-0007oO-At
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 06:41:59 -0700
Received: from acentral.co.uk
	([213.232.83.29] helo=eddie.acentral.co.uk ident=klub)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BISqN-0006ls-48
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 06:41:55 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040423115702.GQ3491@suse.de>
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

On Fri, Apr 23, 2004 at 01:57:04PM +0200, Olaf Kirch wrote:
> On Fri, Apr 23, 2004 at 12:48:30PM +0100, Gavin Hamill wrote:
> > OK, I did see your message in the archives, but wasn't sure that it was 
> > relevant here (I'm getting error -13 when you got -5) but I'm game for a 
> > laugh :)
> 
> 13 is EACCESS, and is probably returned by statd. So I would say you
> are able to talk to statd, only there's something wrong with the setup.
> 
> statd wants the following files available and writable:
> 
> /var/lib/nfs/state	(at start-up only; to store seq# number)
> /var/lib/nfs/sm		to store the NFS peer's address
> /var/lib/nfs/sm.bak	(at start-up only; for lock recovery)

OK, I'm assuming here that statd is only run by the machine  running nfsd and
exporting filesystems, and /usr/sbin/rpc.statd is definately in the process list

Moving onto the files in /var/lib, everything seems to be in order, but I never see any
files written to /var/lib/nfs/sm.

statd is running as root, and here's the structure of /var/lib/nfs:

drwxr-xr-x    4 root     root         4096 Apr 27 11:05 nfs

mop:/var/lib# ls -lR nfs/
nfs/:
total 24
-rw-r--r--    1 root     root          614 Apr 27 11:05 etab
-rw-r--r--    1 root     root           68 Apr 27 13:49 rmtab
drwxr-xr-x    2 root     root         4096 Jul  9  2003 sm
drwxr-xr-x    2 root     root         4096 Jul  9  2003 sm.bak
-rw-------    1 root     root            4 Apr 27 10:42 state
-rw-r--r--    1 root     root          288 Apr 27 11:10 xtab

nfs/sm:
total 0

nfs/sm.bak:
total 0
mop:/var/lib#

There is nothing in the log for 'statd' other than

Apr 27 10:42:53 mop rpc.statd[478]: Version 1.0 Starting

This is not a life-or-death issue because the network is working,
but this is functonality that shoudl work, and it's bugging me :)

As always, any advice warmly received!

Cheers,
Gavin




-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
