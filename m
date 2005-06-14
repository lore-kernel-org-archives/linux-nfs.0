From: Larry Alkoff <labradley@mindspring.com>
Subject: Re: Exportfs does not accept Knoppix /ramdisk/home
Date: Tue, 14 Jun 2005 00:07:29 -0500
Message-ID: <42AE6611.4000709@mindspring.com>
References: <42AE148E.80904@mindspring.com> <17070.5793.185404.226427@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Di3dc-0002D1-F4
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 22:07:00 -0700
Received: from smtpauth06.mail.atl.earthlink.net ([209.86.89.66])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Di3db-0008Vd-SB
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 22:07:00 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17070.5793.185404.226427@cse.unsw.edu.au>
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

Neil Brown wrote:
> On Monday June 13, labradley@mindspring.com wrote:
> 
>>Can you tell me why exportfs isn't working with the home ramdisk and
>>suggest any workarounds?
> 
> 
> I assume it is actually a tmpfs rather than a regular filesystem on a
> true ramdisk ? (what does 'cat /proc/mounts' show?)
> 
> A tmpfs doesn't have a stable identifier (like a device number) to use
> to identify the filesystem.  You need to give it one.
> Try adding
>    fsid=27
> to the export options for the problematic filesystem. e.g.
> 
> /ramdisk/home/knoppix   knoppix(sync,rw,no_root_squash,fsid=27)
> 
> NeilBrown
> 
> 


Thanks for answering my plea for help.
I had tried to contact both you and Olaf Kirch, listed as exportfs 
maintainers in the man page, but in both cases my emails bounced.
In your case the bounce message was:
     SMTP error from remote mailer after MAIL 
FROM:<labradley@mindspring.com>:
     host tone.orchestra.cse.unsw.edu.au [129.94.242.59]:
     550 Sorry, that From address is rejected

I fully expect that the reply to your To: address in au will bounce 
also.  Do you have a really tight whitelist or does unsw hate 
mindspring.com?


The good news - I tried your line exactly as above and
exportfs -rav
worked as expected.

Bad news - for some reason I'm getting the error message:
Mounting knoppix
mount: RPC: Remote system error - No route to host

I've seen that before but it was always fixed by making sure
portmap, nfsd, mountd and statd were running.

They are running on both machines except that on knoppix it's
just "portmap" and on my normal Slackware machine it's "RPC.portmap" 
plus a new one "RPC.quotad".

It's been a while since I fooled with nfs.  Do I need entries in fstab?

You were correct about a tmpfs and
here are my cat /proc/mounts and cat mtab from Knoppix:

cat /proc/mounts
----------------
rootfs / rootfs rw 0 0
/dev/root.old / ext2 rw 0 0
/proc /proc proc rw,nodiratime 0 0
/sys /sys sysfs rw 0 0
/dev/hdd /cdrom iso9660 ro 0 0
/dev/cloop /KNOPPIX iso9660 ro 0 0
/ramdisk /ramdisk tmpfs rw 0 0
/UNIONFS /UNIONFS unionfs 
rw,noatime,dirs=/ramdisk=rw:/KNOPPIX=ro,debug=0,err=tryleft,delete=all,copyup=preserve,setattr=left 
0 0
/dev/pts /UNIONFS/dev/pts devpts rw 0 0
/proc/bus/usb /proc/bus/usb usbfs rw 0 0
automount(pid2172) /mnt/auto autofs rw 0 0


cat /etc/mtab/dev/root / ext2 rw 0 0
-------------------------------------
/dev/hdd /cdrom iso9660 ro 0 0
/dev/cloop /KNOPPIX iso9660 ro 0 0
/ramdisk /ramdisk tmpfs rw,size=399824k 0 0
/UNIONFS /UNIONFS unionfs rw,noatime,dirs=/ramdisk=rw:/KNOPPIX=ro 0 0
/dev/pts /dev/pts devpts rw 0 0
/proc/bus/usb /proc/bus/usb usbfs rw,devmode=0666 0 0
automount(pid2172) /mnt/auto autofs 
rw,fd=4,pgrp=2172,minproto=2,maxproto=4 0 0


Larry

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
