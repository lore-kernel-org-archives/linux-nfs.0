From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: client apps not surviving nfsd restart
Date: Fri, 20 Aug 2004 14:12:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4125EA9F.3040304@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1By8Fp-0004AN-75
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 05:12:21 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1By8Fo-0006Dm-E7
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 05:12:21 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 85E6A435A3
	for <nfs@lists.sourceforge.net>; Fri, 20 Aug 2004 14:12:16 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 741B043571
	for <nfs@lists.sourceforge.net>; Fri, 20 Aug 2004 14:12:16 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

we are running a diskless client system. For a long time, we used kernel
2.4 (.16-.21, SuSE versions) and nfs-over-udp. We never encountered any
problems when the server had to reboot. All of the clients (about 40, of
which about 20 are work- stations running KDE or gnome with several apps)
survived the server reboot without problems. Especially without stale NFS
handles (at least no one has complained about them for 1.5 years :-))

Now we got some problems:

1) After installing SusE 9.0, the default was set to nfs-over-tcp. I didn't
    know that, but suddenly after every server reboot I had at least 4-5
    of the work station users complaining about stale NFS handles, e.g.,
    /usr was stale and so java didn't start anymore etc. It's not really
    reproducable by some certain sequence of starting apps and rebooting
    the server etc., but it happens every time the server has to reboot
    with a few clients.

    In the NFS howto I read that the disadvantage of nfs-over-tcp is that
    "If your server crashes in the middle of a packet transmission, the
     client will hang and any shares will need to be unmounted and remounted."

    But I thought a clean reboot with a clean stop and later start of the
    nfsserver shouldn't make a problem.

    Is there any way to work around these problems? Any known reasons
    why with nfs-over-tcp we have these stales which we did not experience
    with udp before?
    Note that we do not change export options or anything on the file
    system during these server reboots.

    Trying to debug I was also able to make /usr stale by just restarting
    the nfsd (with sleeping, not to run into the race condition Neil
    solved with the recent patch :-)) a few times. Again, not safely
    reproducible...

2) We are currently testing kernel 2.6.8.1. The nfs behaviour seems
    to have changed in some ways. Running e.g. "find /" on a diskless
    client with kernel 2.4 would just hang when the server rebootet
    and later go on when the server was back.
    With 2.6.8.1, the find command will immediately abort and report
    some stale nfs handles.
    This causes much more client applications to abort when the server
    reboots (we have many programs doing a lot I/O, creating files,
    deleting, tracing through directories etc. And they are good
    candidates for such failures).

    This happens the same way with udp/tcp, with intr/nointr. Is there
    a way to  make the clients behave like with the 2.4 kernel? So they
    just get stuck when the server shuts down and wait and continue when
    the server is back?

3) This is a general problem with 2.6 and 2.4:
    When e.g. copying a large file from an nfs-mounted directory to a
    local partition and the nfs server goes down, the cp immediately
    breaks with
    cp: reading `SLES-8-SP-3a-ppc-RC3-CD1.iso': Stale NFS file handle

    This is also independent from udp/tcp or intr/nointr. Should that
    happen? Is there a way to make cp just hang until the server comes
    back?

    Similar things happen with other apps. Using rsync instead of cp
    will indeed just stop and wait until the server is back, but when
    is has finished copying the file it will complain

    read errors mapping "SLES-8-SP-3a-ppc-RC3-CD1.iso": (5) Input/output error


So I end up with three questions:

- is it possible to make all applications just hang and wait until the
   nfs server comes back instead of they abort their work (like find/cp)?
- are there some general hints how to avoid stale nfs handles during a server
   reboot? I didn't find much about this in google.
- How do they after all happen when the file system on the server is not
   changed at all during the reboot? Especially things like /usr don't move
   away or sth., so how can a stale nfs handle for "/usr" happen?


Thanks for any help!

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
