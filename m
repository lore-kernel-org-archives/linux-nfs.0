From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Bug starting 2.6.16 - rpc: bad TCP reclen
Date: Wed, 19 Jul 2006 11:22:22 -0400
Message-ID: <76bd70e30607190822o1b76b04w906729300160f7d0@mail.gmail.com>
References: <44BCC7A1.30104@plutohome.com> <44BE45CA.3050603@plutohome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3E0y-0005Hx-Lv
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 08:31:08 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1G3Dsb-0005v8-97
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 08:22:29 -0700
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G3Dsa-0003sO-DS
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 08:22:29 -0700
Received: by nf-out-0910.google.com with SMTP id m19so212143nfc
	for <nfs@lists.sourceforge.net>; Wed, 19 Jul 2006 08:22:23 -0700 (PDT)
To: "Razvan Gavril" <razvan.g@plutohome.com>
In-Reply-To: <44BE45CA.3050603@plutohome.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 7/19/06, Razvan Gavril <razvan.g@plutohome.com> wrote:
> Razvan Gavril wrote:
> > I posted on the linux kernel mailing list but got no answer till now.
> >
> > I have a nfs server and some diskless computers that that have there
> > root mounted via  nfs from the server. In certain situations the
> > diskless computers fail to write correctly to their nfs mounted
> > filesystem (some files get corrupted). Looking into the nfs server's
> > dmesg, i see this messages:
> >
> > RPC: bad TCP reclen 0x5e9c5bec (non-terminal)
> > RPC: bad TCP reclen 0x29db3277 (large)
> > RPC: bad TCP reclen 0x698f6ccf (large)
> > RPC: bad TCP reclen 0x336160a9 (large)
> > RPC: bad TCP reclen 0x773ffdff (large)
> > RPC: bad TCP reclen 0x231b8d5c (non-terminal)
> > RPC: bad TCP reclen 0x39902af4 (large)
> > RPC: bad TCP reclen 0x6048d9cc (non-terminal)
> > RPC: bad TCP reclen 0x212f7e14 (non-terminal)
> >
> > This errors start to happen when upgrading to 2.6.16 from 2.6.15 but the
> > problem is still present in 2.6.17 kernel. For now i tested like this:
> >
> > Client - Server - State
> > ------------------------
> > 2.6.15 - 2.6.15 - Works
> > 2.6.15 - 2.6.16 - Errors
> > 2.6.16 - 2.6.16 - Errors
> > 2.6.16 - 2.6.17 - Errors
> > 2.6.17 - 2.6.17 - Errors
> >
> >  From the looks of it the problem seems to be related to the nfs server
> > implemetation from the kernels newer that 2.6.15.
> >
> > Those corrupted writes on client + dmesg messages on the server are easy
> > to duplicate when using Debian on the client computers and running this
> > script in parallel on more that 1 client:
> >
> > while /bin/true ;do
> >         apt-get update
> >         err=$?
> >         [[ $err != 0 ]] && echo "Exiting $err" && exit $err
> >
> >         # you can replace gdb with any other package
> >         apt-get -y install gdb
> >         err=$?
> >         [[ $err != 0 ]] && echo "Exiting $err" && exit $err
> >
> >         apt-get -y remove gdb
> >         err=$?
> >         [[ $err != 0 ]] && echo "Exiting $err" && exit $err
> >
> >         sleep $(( $RANDOM % 3 ))
> > done
> >
> > After a couple o minutes (1-5min) apt should give a segmentation fault
> > because one of its state files got corrupted (/lib/dpkg/status or
> > other). FYI, the clients DON'T have any common files/dirs so a race
> > condition in apt can't be the cause. It's easy to see that for every apt
> > segfault on the client you'll have a rpc error message on the server.
> >
> > I also tried with some different script to reproduce the problem, for
> > example to copy a lot of files(small, big ..) from a nfs share to
> > another but the md5sum reported that every time the copying was
> > happening without corruption so using apt is the only solution to
> > reproduce the bug for now.
> >
> > I'm here if you need any other info related to this problem.
> >
> > --
> > Razvan Gavril
> >
> >
> >
> > -------------------------------------------------------------------------
> > Take Surveys. Earn Cash. Influence the Future of IT
> > Join SourceForge.net's Techsay panel and you'll get the chance to share your
> > opinions on IT & business topics through brief surveys -- and earn cash
> > http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> Razvan Gavril wrote:
> > I posted on the linux kernel mailing list but got no answer till now.
> >
> > I have a nfs server and some diskless computers that that have there
> > root mounted via  nfs from the server. In certain situations the
> > diskless computers fail to write correctly to their nfs mounted
> > filesystem (some files get corrupted). Looking into the nfs server's
> > dmesg, i see this messages:
> >
> > RPC: bad TCP reclen 0x5e9c5bec (non-terminal)
> > RPC: bad TCP reclen 0x29db3277 (large)
> > RPC: bad TCP reclen 0x698f6ccf (large)
> > RPC: bad TCP reclen 0x336160a9 (large)
> > RPC: bad TCP reclen 0x773ffdff (large)
> > RPC: bad TCP reclen 0x231b8d5c (non-terminal)
> > RPC: bad TCP reclen 0x39902af4 (large)
> > RPC: bad TCP reclen 0x6048d9cc (non-terminal)
> > RPC: bad TCP reclen 0x212f7e14 (non-terminal)
> >
> > This errors start to happen when upgrading to 2.6.16 from 2.6.15 but the
> > problem is still present in 2.6.17 kernel. For now i tested like this:
> >
> > Client - Server - State
> > ------------------------
> > 2.6.15 - 2.6.15 - Works
> > 2.6.15 - 2.6.16 - Errors
> > 2.6.16 - 2.6.16 - Errors
> > 2.6.16 - 2.6.17 - Errors
> > 2.6.17 - 2.6.17 - Errors
> >
> >  From the looks of it the problem seems to be related to the nfs server
> > implemetation from the kernels newer that 2.6.15.
> >
> > Those corrupted writes on client + dmesg messages on the server are easy
> > to duplicate when using Debian on the client computers and running this
> > script in parallel on more that 1 client:
> >
> > while /bin/true ;do
> >         apt-get update
> >         err=$?
> >         [[ $err != 0 ]] && echo "Exiting $err" && exit $err
> >
> >         # you can replace gdb with any other package
> >         apt-get -y install gdb
> >         err=$?
> >         [[ $err != 0 ]] && echo "Exiting $err" && exit $err
> >
> >         apt-get -y remove gdb
> >         err=$?
> >         [[ $err != 0 ]] && echo "Exiting $err" && exit $err
> >
> >         sleep $(( $RANDOM % 3 ))
> > done
> >
> > After a couple o minutes (1-5min) apt should give a segmentation fault
> > because one of its state files got corrupted (/lib/dpkg/status or
> > other). FYI, the clients DON'T have any common files/dirs so a race
> > condition in apt can't be the cause. It's easy to see that for every apt
> > segfault on the client you'll have a rpc error message on the server.
> >
> > I also tried with some different script to reproduce the problem, for
> > example to copy a lot of files(small, big ..) from a nfs share to
> > another but the md5sum reported that every time the copying was
> > happening without corruption so using apt is the only solution to
> > reproduce the bug for now.
> >
> > I'm here if you need any other info related to this problem.
> >
> >
> Can someone at least confirm this bug and give me an idea where to start
> debugging ?

I haven't seen other reports like this recently.  It could be a
hardware problem on your server or in your network (like a bad server
NIC).   A network trace would be the way to start tracking this down.

sudo tcpdump -s0 -w /tmp/dump

on your server.  Stop the dump when the server starts reporting the
TCP stream problems.  Then take a look at the end of the dump with
tethereal.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
