From: Peter Astrand <peter@cendio.se>
Subject: RE: [autofs] umount fails with NFS mounts
Date: Thu, 23 Sep 2004 15:49:17 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409231438370.23756-100000@maggie.lkpg.cendio.se>
References: <482A3FA0050D21419C269D13989C611302B07E14@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Cc: autofs@linux.kernel.org, <nfs@lists.sourceforge.net>,
	Erik Forsberg <forsberg@cendio.se>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CATyO-000583-HH
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 06:49:24 -0700
Received: from cheddar.cendio.se ([193.12.253.77] helo=mail.cendio.se)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CATyL-0004tC-PH
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 06:49:24 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07E14@lavender-fe.eng.netapp.com>
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


> > We are using autofs for mounting home directories, but are 
> > experiencing two major problems wrt unmounting NFS mounts:
> > 
> > 1) The umount command indicates that the umount succeeded, 
> > but even so, 
> > the NFS export is still mounted. This can be confirmed by looking in 
> > /etc/mtab and /proc/mounts. 
> 
> in other words, you are able to replicate this problem without autofs
> (ie, using only static mount points)?

Sorry for the delay. This is a production system, so we cannot experiment 
with it very much. It's a bit hard to use to reproduce this problem. 

Usually, it happens when we are running a script which sets correct 
permissions for the users home directories. It does, basically:

stat /home/theuser
chown theuser /home/theuser
umount /home/theuser

It iterates through several thousands of users. After that, there are 
usually several hundreds home directory mounts which cannot be umounted. 

Today, I've managed to reproduce the problem by doing several
mounts/umounts for the same user. I've used the following shell script:

#!/bin/sh
while true; do
    usleep 50000
    echo statting
    stat /home/94azajmi >/dev/null
    echo umounting
    umount /home/94azajmi
    echo checking mounts
    mount | grep 94azajmi
done

First, I've ran it for about a minut, then terminated. No problems. Then I 
ran it for another minute. No problems. Then I recieved a phone call. 
After that, I started the script again, and now it immediately failed to 
umount the home directory:

# ./foo.sh
statting
umounting
checking mounts
10.201.1.10:/VOL1/Arb/94AZAJMI on /home/94azajmi type nfs (rw,nfsvers=2,hard,intr,addr=X.X.X.X)

When this happened, I did a static mount on /mnt/floppy. It could be 
umounted without problems. 

I've noticed one very interesting thing: Each time I do a "umount 
/home/94azajmi", this ends up in the system logg:

Sep 23 15:03:38 foobar last message repeated 3 times
Sep 23 15:03:42 foobar automount[1565]: attempting to mount entry /home/94azajmi
Sep 23 15:03:42 foobar automount[6586]: >> mount: 10.201.1.10:/VOL1/Arb/94azajmi failed, reason given by server: No such file or directory
Sep 23 15:03:42 foobar automount[1565]: attempting to mount entry /home/94azajmi
Sep 23 15:03:42 foobar automount[6591]: >> mount: 10.201.1.10:/VOL1/Arb/94azajmi failed, reason given by server: No such file or directory

At this point, I need to mention that our script tl-nds-mountpath is
slightly modified on this system: Because Netware is case sensitive when
speaking mount/nfs, tl-nds-mountpath does a test-mount (in another
directory) before returning the mount path. So, during the automount, the 
script calls the mount command. Perhaps this confuses automount?

Of course, the question is why a umount triggers a mount in the first 
place...


>   sudo sysctl -w sunrpc.rpc_debug=32767
 
Is this safe to run on a production system?


-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00








-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
