From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: [NFS] fcntl locks prevent unmounting of underlying
	filesystem
Date: Fri, 04 Jun 2004 08:03:10 -0400
Sender: linux-ha-bounces@lists.linux-ha.org
Message-ID: <1086350590.21500.19.camel@tesla.mmt.bellhowell.com>
References: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
	<16569.5128.54766.582893@cse.unsw.edu.au>
Reply-To: General Linux-HA mailing list <linux-ha@lists.linux-ha.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-ha@lists.linux-ha.org, nfs@lists.sourceforge.net
Return-path: <linux-ha-bounces@lists.linux-ha.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16569.5128.54766.582893@cse.unsw.edu.au>
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Archive: <http://lists.community.tummy.com/pipermail/linux-ha>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
Errors-To: linux-ha-bounces@lists.linux-ha.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 2004-05-29 at 18:51, Neil Brown wrote:
> If lockd has gone away at this point but locks are still being held,
> then that is a real problem and I will try to look into it.
> 
> NeilBrown

Ok, I think we have a test case where even a SIGKILL to lockd won't
help. When I did a single POSIX lock on the filesystem, sending the
SIGKILL to lockd did seem to clear up the problem unmounting the
filesystem. The folks on the linux-ha list were still having problems
and suggested I try a Connectathon test to see if the SIGKILL still
worked after that.

I downloaded connectathon:

http://www.connectathon.org/nfstests.html

And ran the locking test on a filesystem I had mounted from the server.
I then did on the server:

exportfs -u <filesystem>
exportfs -f
pkill -KILL -x lockd

And tried to unmount the filesystem. It wouldn't unmount. I then killed
connectathon and tried to unmount it. It wouldn't unmount. I then
unmounted the filesystem from the client, and still I couldn't unmount
the underlying filesystem. At this point, I rebooted the box, as I
didn't see any alternative.

So whatever connectathon does, it seems to hose up Linux NFS locking
pretty solidly. One thing it seems to do is reserve _a_lot_ of locks, so
perhaps it's a problem with the amount of them. If you could download
and try it, perhaps you could get to the bottom of the problem.

FWIW, I'm using 2.6.6 kernel on the server, with /proc/fs/nfsd mounted
and nfs-utils 1.0.6-3 from Debian archive, but Guochun Shi said that
he's been able to replicate this problem on recent 2.4 kernels as well.

Many thanks for your help!
-- Jeff


_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
