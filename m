From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: read(2) hangs on the client side
Date: Sun, 8 May 2005 13:33:43 +0200
Message-ID: <20050508113343.GA629@fox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DUk2j-0007sm-Bo
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 04:33:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DUk2i-00040k-Jd
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 04:33:53 -0700
Received: from mail-mx1.uio.no ([129.240.10.29])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1DUk2e-0004rA-1k
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 13:33:48 +0200
Received: from 115.80-203-46.nextgentel.com ([80.203.46.115] helo=fox.venod.com)
	by mail-mx1.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1DUk2b-00084e-GV
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 13:33:45 +0200
To: nfs@lists.sourceforge.net
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

I have noticed that there is a specific case that can lock up the
client while doing read(2), and it seems to be a race condition that
only occures in a very specific situation.  I will try to describe
this in as much detail as possible, since it is unlikely that you'll
be able to reproduce the bug for yourselves:

A big file (~ 250 MB) is shared on the NFS server.  The NFS server
also acts as a Samba server, so that Windows machines can use it.
One of the Windows machines is running the eMule P2P client,
and it makes some of the Samba-hosted files available on the
eMule network.

The hang has _only_ happened when I try to access a shared file
via NFS while it is _simultaneously_ being accessed (via Samba)
by the eMule machine.  To reproduce the hang from the NFS client's
side, I use this C program:

        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>

        int main(int argc, char *argv[])
        {
                for (;;) {
                        char buf[4096];
                        int fd = open(argv[1], O_RDONLY);
                        read(fd, buf, 4096);
                        close(fd);
                }
                return 0;
        }

It always hangs in the read() call, usually in the first iteration,
and after it does, _nothing_ can kill it, not even SIGKILL,
and until the next reboot, _any_ NFS operation -- even stat() --
on the accessed file will now hang.

I have no idea how Samba + eMule's access patterns look like,
but I know with 100 % certainty that it is the cause.  If I move
the file in question out of eMule's shared directory, I can never
hang the NFS client no matter how long I run the above program.
If I move it back in, it hangs almost instantly. :-(

Note that only the Linux NFS client machine is seemingly affected by
this -- both the NFS/Samba server and the eMule-running Samba client
are doing just fine while the hang happens on the Linux client.

Some system info:

NFS client:
  Slackware 10.1
  Linux 2.6.11
  nfs-utils 1.0.7
  glibc 2.3.4
  util-linux 2.12p

NFS server:
  Fedora Core 3 (fully updated)
  Linux 2.6.11-1.14_FC3
  nfs-utils-1.0.6-52
  glibc-2.3.5-0.fc3.1
  Samba 3.0.15pre2-1
  util-linux-2.12a-24.2

Any help in further analysis would be greatly appreciated!

-- 
 Haakon


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
