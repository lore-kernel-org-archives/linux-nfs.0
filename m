From: Debian User <debian-user@zerocrossings.com>
Subject: Re: cannot mount via nfs
Date: Wed, 30 Apr 2003 09:49:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <10319.8961158798$1051710815@news.gmane.org>
Reply-To: debian-user@zerocrossings.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso8859-1
Cc: debian-user@zerocrossings.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-182d9afe.dyn.optonline.net
	([24.45.154.254] helo=development ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ary4-0005Wb-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 06:49:52 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

in /etc/init.d there is a init script nfs-kernel-server. when i run 
as root

/etc/init.d/# ./nfs-kernel-server start

the script executes the following:

DESC="NFS kernel daemon"

RPCNFSDCOUNT=8  # Number of servers to be started up by default
RPCMOUNTDOPTS=

# See how we were called.
case "$1" in
  start)
        cd /    # daemons should have root dir as cwd
        if grep -q '^/' /etc/exports
        then
                printf "Exporting directories for $DESC..."
                $PREFIX/sbin/exportfs -r
                echo "done."

                printf "Starting $DESC:"
                printf " nfsd"
                start-stop-daemon --start --quiet \
                    --exec $PREFIX/sbin/rpc.nfsd -- $RPCNFSDCOUNT
                printf " mountd"
                $PREFIX/bin/rpcinfo -u localhost nfs 3 >/dev/null 
2>&1 ||
                    RPCMOUNTDOPTS="$RPCMOUNTDOPTS --no-nfs-version 3"
                start-stop-daemon --start --quiet \
                    --exec $PREFIX/sbin/rpc.mountd -- $RPCMOUNTDOPTS
                echo "."
        else
                echo "Not starting $DESC: No exports."
        fi
        ;;

based on this, i think nfsd should be running but it is not. even 
when i try:

rpc.nfsd 8

there is no error reported but the nfsd is still not running.

At 30 April 2003, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

>>>>>> " " == Debian User <debian-user@zerocrossings.com> writes:
>
>     > I have had nfs mounting working in the past ... do not
>     > understand why this is not working now. Can anyone help?
>
>     > NFS server:
>
>     > # rpcinfo -p
>     >    program vers proto port
>     >     100000 2 tcp 111 portmapper 100000 2 udp 111 portmapper
>     >     100024 1 udp 2098 status 100024 1 tcp 2079 status 100005 1
>     >     udp 2099 mountd 100005 1 tcp 2080 mountd 100005 2 udp 2099
>     >     mountd 100005 2 tcp 2080 mountd
>
>You are not starting any NFS daemons. Only mountd is shown to be
>running in the above listing.
>
>man rpc.nfsd
>
>Cheers,
>  Trond
>












-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
