From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Fri, 04 May 2007 15:30:30 -0500
Message-ID: <463B97E6.4030009@amd.com>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com> <462CFC92.2080201@amd.com>
Reply-To: Paul Krizak <paul.krizak@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Ian Kent <raven@themaw.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hk4QU-0000B7-0z
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 13:30:53 -0700
Received: from mail-dub.bigfish.com ([213.199.154.10]
	helo=mail132-dub-R.bigfish.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hk4QV-0007D5-Og
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 13:30:52 -0700
In-Reply-To: <462CFC92.2080201@amd.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Are all NFS options from an export inherited by subsequent mounts since 
the upstream commit 54ceac4515986030c2502960be620198dd8fe25b?

I'm pasting an email from a colleague at AMD that's also trying to gain 
an understanding of the new mount behavior (Paul Krizak)...

Thanks,

--Greg

[...snip...]

* Here are the various automount points that mount to eng:/vol/vol18, 
which is a single entry in eng's exports file:

[skaven@byleth /tool/eng-vol0/etc]$ ypcat -k auto.tool | grep eng.*vol18
arc_syslog -intr           eng:/vol/vol18/&
site-lib -intr   eng:/vol/vol18/site-config/provision/site-lib
site-config -intr       eng:/vol/vol18/&
eng-vol18 -intr           eng:/vol/vol18
sysadmin_tmp -intr        eng:/vol/vol18/&
linux -intr     eng:/vol/vol18/&

[skaven@byleth /tool/eng-vol0/etc]$ grep vol18 exports
/vol/vol18      -sec=sys,rw=@pcd,root=@tx_admin_nodes,anon=4058

* So perhaps the problem is that things using the same *export* inherit 
the same options?

* First mount sysadmin_tmp as the first (and only) mount to eng:/vol/vol18:

[root@adcgar05 mnt]# grep eng.*vol18 /proc/mounts
[root@adcgar05 mnt]# mount -t nfs -o rsize=1024,wsize=1024 
eng:/vol/vol18/sysadmin_tmp local
[root@adcgar05 mnt]# grep eng.*vol18 /proc/mounts
eng:/vol/vol18/sysadmin_tmp /mnt/local nfs 
rw,vers=3,rsize=1024,wsize=1024,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0

* Now let's mount something else with "default" options:
[root@adcgar05 mnt]# mount -t nfs eng:/vol/vol18/arc_syslog local2
[root@adcgar05 mnt]# grep eng.*vol18 /proc/mounts
eng:/vol/vol18/sysadmin_tmp /mnt/local nfs 
rw,vers=3,rsize=1024,wsize=1024,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0
eng:/vol/vol18/arc_syslog /mnt/local2 nfs 
rw,vers=3,rsize=1024,wsize=1024,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0

Ah ha!  That seems to be it!!!

My "mental model" of how mount/automount should work does *not* think 
this is correct.  While multiple mounts may occur on a single export 
from a filer, the options from the client side for each individual mount 
(especially for separate subdirs) should be customizable.

Inheriting the options from the previous mount to that export is asinine 
and simply unsupportable in our environment.  I did some further testing 
and found that this "inheritance" model even happens for ro/rw 
attributes, causing HUGE security implications.  For example, what if 
something like this happened:

1. mount an innocuous directory like /tool/sysadmin_tmp read-write
2. mount an important directory like /tool/finance_data from the same 
filer:/vol/volume, but with -o ro
3. My experimentation shows that the "finance_data" mount will be 
read-write due to inheritance!!!

The obvious implications of usage of automount and such, I believe this 
to be very *bad* behavior.  I could see how a sysadmin could set up 
something like this expecting it to be secure.  For example, a filer 
could be set up with one exported dir, depending on its clients (with, 
say, static /etc/fstab mounts) setting up whether the NFS mount is 
read-only or read-write.

But with the way RHEL5 appears to act, a clever user could carefully 
"cd" to a read-write dir first, then to the read-only one, and they'd 
get read-write privileges where they were not supposed to!

Comments?

-- 

Paul Krizak                         5900 E. Ben White Blvd. MS 625
Advanced Micro Devices              Austin, TX  78741
Linux/Unix Systems Engineering      Phone: (512) 602-8775
Silicon Design Division             Cell:  (512) 791-0686

[...snip...]

[...followup from Ian Kent (autofs) on rhelv5-list...]

I first noticed this (in my opinion) regression more than 6 months ago.
For a long time I thought it was only restricted to the ro/rw attributes
but recently I've see the rsize/wsize issue mentioned.

There have been several bugs logged and posts made to the NFS list but I
haven't seen much more than an acknowledgment that it's a limitation of
the NFS implementation.

So it would be good to be counted by posting this comprehensive analysis
to the NFS list (https://lists.sourceforge.net/lists/listinfo/nfs).
Maybe that will increase the priority of fixing this issue.
    .
    .
    .
Sure is and it causes several of the autofs Connectathon tests to fail
which makes me look bad when it's not actually something I have control
over, grrr!

Ian

[...snip...]


Gregory Baker wrote:
> 
> ...closing the loop on what we've found out... it doesn't appear that a 
> convenient workaround (at the mount level) exists.  We'll play around 
> with local executable automount maps to see if that will work for us.
> 
> Thanks,
> 
> --Greg
> 
> *****
> Indeed, now that I read that comment by Trond and went to the source 
> code, I found out about upstream commit 
> 54ceac4515986030c2502960be620198dd8fe25b.
> 
> The idea is that having a single super_block structure per server per 
> FSID prevents corner cases that can lead to corrupt dentry cache trees, 
> prevents conflicting buffer cache contents to what ends up being the 
> same file, and some other scary situations.
> 
> So the deal is, the mount flags (and NFS options) are set only the first 
> time that a given combination of server and filesystem are mounted. If 
> you ever mount the same filesystem from the same server on another 
> mountpoint, you'll get the flags and options that were passed on to the 
> first mount. There's no working around that.
> *****
> 
> Gregory Baker wrote:
>> Trond Myklebust wrote:
>>  > On Thu, 2007-04-19 at 15:37 -0500, Gregory Baker wrote:
>>  >
>>  >> ---+ BAD RHEL 5 64 system
>>  > ...
>>  >> [root@adcgar04 mnt2]# cat /proc/mounts | grep mnt2
>>  >> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs
>>  >> 
>> ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
>>
>>  >> 0 0
>>  >
>>  > That would be your problem right there. Is the same volume perhaps
>>  > mounted read-only somewhere else on the same client? That is no longer
>>  > allowed.
>>  >
>>  > Cheers
>>  >   Trond
>>  >
>>
>> Ah, news to me!
>>
>> So if you mount a volume ro at one mount point /mnt1 and then try to 
>> mount the same volume rw at a second mount point /mnt2 you'll run into 
>> problems?  Apologies, didn't catch this in release notes.  Thanks!
>>
>> --Greg
>>
>> ---+ A New Beginning
>>
>> [root@adcgar04 /]# umount -a -t nfs
>>
>> [root@adcgar04 /]# mount -v | grep pandora
>>
>> [root@adcgar04 /]# cat /proc/mounts | grep pandora
>>
>> [root@adcgar04 /]# mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
>>
>> [root@adcgar04 /]# mount -v | grep pandora
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
>> (rw,addr=163.181.34.137)
>>
>> [root@adcgar04 /]# cat /proc/mounts | grep pandora
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
>> rw,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
>> 0 0
>>
>> [root@adcgar04 /]# touch /mnt2/asdf
>>
>> ---+ The ro Strikes Back
>>
>> [root@adcgar04 /]# mount -o ro 
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt1
>>
>> [root@adcgar04 /]# mount -o rw 
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2
>>
>> [root@adcgar04 /]# mount -v | grep mnt
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt1 type nfs 
>> (ro,addr=163.181.34.137)
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
>> (rw,addr=163.181.34.137)
>>
>> [root@adcgar04 /]# cat /proc/mounts | grep mnt
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt1 nfs 
>> ro,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
>> 0 0
>> eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
>> ro,vers=3,rsize=65536,wsize=65536,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
>> 0 0
>>
>> [root@adcgar04 /]# touch /mnt2/asdf
>> touch: cannot touch `/mnt2/asdf': Read-only file system
>>
>>
>>
>>
>>
> 

-- 
----------------------------------------------------------------------
Greg Baker                                         512-602-3287 (work)
gregory.baker@amd.com                              512-602-6970 (fax)
5204 E. Ben White Blvd MS 625                      512-555-1212 (info)
Austin, TX 78741




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
