From: Adrian Phillips <a.phillips@met.no>
Subject: Re: Lock recovery doesn't work in debian statd/lockd ordering
Date: 12 Sep 2002 06:00:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <wv1y7z6en4.fsf@freeze.oslo.dnmi.no>
References: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp1.oslo.dnmi.no ([157.249.32.202])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pL9n-00078l-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 21:00:43 -0700
Received: from uucp by freeze.oslo.dnmi.no with spam-scanned (Exim 3.35 #1)
	id 17pL9c-0008FM-00
	for nfs@lists.sourceforge.net; Thu, 12 Sep 2002 06:00:32 +0200
Received: from tandem by freeze.oslo.dnmi.no with local (Exim 3.35 #1)
	id 17pL9b-0008FJ-00
	for nfs@lists.sourceforge.net; Thu, 12 Sep 2002 06:00:31 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> "Neil" == Neil Brown <neilb@cse.unsw.edu.au> writes:

    Neil>  I just noticed that lock recovery doesn't work with a
    Neil> Debian NFS server.  i.e.  server shuts down, restarts, and
    Neil> the client *Doesn't* reclaim the locks.

Um, which version ? On my woody box lockd is started in nfs-common
after statd still though :-

#!/bin/sh
#
# nfs-common    This shell script takes care of starting and stopping
#               common daemons required for NFS clients and servers.
#
# chkconfig: 345 20 80
# description: NFS is a popular protocol for file sharing across \
#	       TCP/IP networks. This service provides NFS file \
#	       locking functionality.
#

PREFIX=

NEED_LOCKD=yes
if test -f /proc/ksyms
then
    # We need to be conservative and run lockd,
    # unless we can prove that it isn't required.
    grep -q lockdctl /proc/ksyms || NEED_LOCKD=no
fi

[ -x $PREFIX/sbin/rpc.statd ] || exit 0
[ -x $PREFIX/sbin/rpc.lockd ] || [ "$NEED_LOCKD" = no ] || exit 0

# What is this?
DESC="NFS common utilities"

# See how we were called.
case "$1" in
  start)
	cd /	# daemons should have root dir as cwd
	printf "Starting $DESC:"
	printf " statd"
	start-stop-daemon --start --quiet \
	    --exec $PREFIX/sbin/rpc.statd
	if [ "$NEED_LOCKD" = yes ]
	then
	    printf " lockd"
	    start-stop-daemon --start --quiet \
		--exec $PREFIX/sbin/rpc.lockd
	fi
	echo "."
	;;

  stop)
	printf "Stopping $DESC:"
	if [ "$NEED_LOCKD" = yes ]
	then
	    printf " lockd"
	    start-stop-daemon --stop --oknodo --quiet \
		--exec $PREFIX/sbin/rpc.lockd
	fi
	printf " statd"
	start-stop-daemon --stop --oknodo --quiet \
	    --exec $PREFIX/sbin/rpc.statd
	echo "."
	;;

  restart | force-reload)
	$0 stop
	sleep 1
	$0 start
	;;

  *)
	echo "Usage: nfs-common {start|stop|restart}"
	exit 1
	;;
esac

exit 0

Sincerely,

Adrian Phillips

-- 
Your mouse has moved.
Windows NT must be restarted for the change to take effect.
Reboot now?  [OK]


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
