From: Larry Alkoff <labradley@mindspring.com>
Subject: Exportfs does not accept Knoppix /ramdisk/home
Date: Mon, 13 Jun 2005 18:19:42 -0500
Message-ID: <42AE148E.80904@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhyD6-0001Vw-2U
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 16:19:16 -0700
Received: from smtpauth03.mail.atl.earthlink.net ([209.86.89.63])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DhyD3-0002bO-EZ
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 16:19:15 -0700
Received: from [69.91.95.238] (helo=[192.168.0.5])
	by smtpauth03.mail.atl.earthlink.net with asmtp (Exim 4.34)
	id 1DhyD2-0000V4-Fi
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 19:19:12 -0400
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

Please forgive me for bothering you but I and other Knoppix users have a
vexing problem trying to export the Knoppix home directory which is on a
ram disk.

Each time I try to issue
exportfs -rav
an "invalid argument" error message is produced.
However the root / directory is exported without error.

Some background on Knoppix:
Knoppix boots entirely from a cdrom and, in my case, does not use a hard
disk at all.  In fact, there is no hard disk in the Knoppix machine I'm
using now.

Knoppix creates a ram disk when it boots with soft links to the cdrom.
You can delete a soft line to a file and write your own.   In this case
I deleted the soft link to /etc/exports and wrote one for my exports.

Once everything is running satisfactorily you can save the entire /etc
and subdirectories to a thumb drive.

Knoppix boots with a user "knoppix" and its home is mounted as
/ramdisk/home/knoppix
with a symlink
/home -> /ramdisk/home

Tried several variations on below but keep getting an error message.
I suspect that /ramdisk is not considered a file system by exportfs.

This is a portion of /etc/exports:
/       knoppix(sync,rw,no_root_squash)
/ramdisk/home/knoppix   knoppix(sync,rw,no_root_squash)
#/home  knoppix(sync,rw,no_root_squash)

This is the result of exportfs:

root@Knoppix etc # exportfs -rav
exporting knoppix:/ramdisk/home/knoppix
exporting knoppix:/
exporting knoppix:/ramdisk/home/knoppix to kernel
knoppix:/ramdisk/home/knoppix: Invalid argument
reexporting knoppix:/ to kernel

In searching the Knoppix mailing list it appears that others are having
the same trouble trying to mount the Knoppix home directory for NFS.
Some have said that the owner of Knoppix is not interested in NFS, only
Samba.

If I cannot mount using NFS I'll have to go to Samba but am not sure yet
how to go about mounting a Linux share on Samba or whether Samba would
accept the ramdisk part.

Can you tell me why exportfs isn't working with the home ramdisk and
suggest any workarounds?

I have experience with NFS on several Linux machines and have portmap,
nfsd and rpc.mountd running.

I hope the knowledgable people on this list can help solve this puzzle.
Thank you.


-- 
Larry Alkoff N2LA - Austin TX
Using Thunderbird on Slackware Linux


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
