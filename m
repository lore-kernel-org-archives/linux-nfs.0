From: Razvan Gavril <razvan.g@plutohome.com>
Subject: Buf starting 2.6.16 - rpc: bad TCP reclen
Date: Tue, 18 Jul 2006 14:36:01 +0300
Message-ID: <44BCC7A1.30104@plutohome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2ns0-0002sW-Nn
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 04:36:08 -0700
Received: from k2smtpout02-02.prod.mesa1.secureserver.net ([64.202.189.91])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G2nrz-0002nw-Oi
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 04:36:09 -0700
To: nfs@lists.sourceforge.net
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

I posted on the linux kernel mailing list but got no answer till now.

I have a nfs server and some diskless computers that that have there 
root mounted via  nfs from the server. In certain situations the 
diskless computers fail to write correctly to their nfs mounted 
filesystem (some files get corrupted). Looking into the nfs server's 
dmesg, i see this messages:

RPC: bad TCP reclen 0x5e9c5bec (non-terminal)
RPC: bad TCP reclen 0x29db3277 (large)
RPC: bad TCP reclen 0x698f6ccf (large)
RPC: bad TCP reclen 0x336160a9 (large)
RPC: bad TCP reclen 0x773ffdff (large)
RPC: bad TCP reclen 0x231b8d5c (non-terminal)
RPC: bad TCP reclen 0x39902af4 (large)
RPC: bad TCP reclen 0x6048d9cc (non-terminal)
RPC: bad TCP reclen 0x212f7e14 (non-terminal)

This errors start to happen when upgrading to 2.6.16 from 2.6.15 but the 
problem is still present in 2.6.17 kernel. For now i tested like this:

Client - Server - State
------------------------
2.6.15 - 2.6.15 - Works
2.6.15 - 2.6.16 - Errors
2.6.16 - 2.6.16 - Errors
2.6.16 - 2.6.17 - Errors
2.6.17 - 2.6.17 - Errors

 From the looks of it the problem seems to be related to the nfs server 
implemetation from the kernels newer that 2.6.15.

Those corrupted writes on client + dmesg messages on the server are easy 
to duplicate when using Debian on the client computers and running this 
script in parallel on more that 1 client:

while /bin/true ;do
        apt-get update
        err=$?
        [[ $err != 0 ]] && echo "Exiting $err" && exit $err

        # you can replace gdb with any other package
        apt-get -y install gdb
        err=$?
        [[ $err != 0 ]] && echo "Exiting $err" && exit $err

        apt-get -y remove gdb
        err=$?
        [[ $err != 0 ]] && echo "Exiting $err" && exit $err

        sleep $(( $RANDOM % 3 ))
done

After a couple o minutes (1-5min) apt should give a segmentation fault 
because one of its state files got corrupted (/lib/dpkg/status or 
other). FYI, the clients DON'T have any common files/dirs so a race 
condition in apt can't be the cause. It's easy to see that for every apt 
segfault on the client you'll have a rpc error message on the server.

I also tried with some different script to reproduce the problem, for 
example to copy a lot of files(small, big ..) from a nfs share to 
another but the md5sum reported that every time the copying was 
happening without corruption so using apt is the only solution to 
reproduce the bug for now.

I'm here if you need any other info related to this problem.

--
Razvan Gavril



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
