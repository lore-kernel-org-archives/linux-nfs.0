From: Christian Reis <kiko@async.com.br>
Subject: Re: NFS client locking hangs for period
Date: Fri, 25 Apr 2003 01:57:30 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030425015730.A29574@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


Well, since I've more or less moved on from my original problems, I
should probably post a summary of what was going on, and what I did to
work around it.

Details can be read out from [1]: after a certain amount of time a
number diskless clients, which were mounting everything from the same
NFS server, started getting hung lock requests from the server. The
server ran 2.4.20, reiserfs over RAID-1 mounted with 2 SCSI disks on an
Adaptec 29160. The clients were debian woodys running 2.4.20.

Our diskless setup is a bit unusual: all the clients mount the same root
partition. I tried to be very careful to make sure no files were written
to on /, but I never got to the point where the clients could mount the
directory read-only. I used devfs to make sure that the /dev directories
were `localized' and syslog/console ownership and permissions kept sane.

The locking problem, however, was not related to the root filesystem --
it seems to have happened with files on the /var/log mount, which is
separate for each box (but still coming from a shared filesystem
/export/root on the server, which contains all the client directories).
If I mounted /var/log with the nolock option, they ran fine. This took
me a very long time to figure out, and I'd advise anyone with locking
problems to give it a go.

I should point out that this *does* seem to be a bug in the NFS server
code. I think it is associated with reiserfs, being that I haven't seen
it happen on other partition types. Rebooting the server cleared up the
problem. Erasing or changing files in /var/lib/nfs did not. While I was
initially using a volatile /var/lib/nfs directory on the *clients*, I
changed this on Trond's suggestion [2]. It did not fix the problem.

However, since I know little about the code itself, and it's not very
clear how one should debug, I was unable to pinpoint the exact source of
the problem, which very much saddens me.  The workaround, however, was
quite effective.

[1] http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&th=9db70994c3458f46&rnum=1
[2] http://groups.google.com/groups?q=christian+reis+nfs+locking&hl=en&lr=&ie=UTF-8&scoring=d&selm=20030126231006%246e11%40gated-at.bofh.it&rnum=3

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
