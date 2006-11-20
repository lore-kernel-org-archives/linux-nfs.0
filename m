From: Michael Walker <Michael.Walker@Cassatt.COM>
Subject: Re: NFS mounts being mounted read-only depending upon mount
 order???
Date: Mon, 20 Nov 2006 13:22:15 -0800
Message-ID: <45621C87.1050307@Cassatt.COM>
References: <455DFE02.7050801@Cassatt.COM> <456216CC.40006@Cassatt.COM>
	<1164057026.5723.65.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmGal-0005Yl-Qv
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 13:22:16 -0800
Received: from 63-192-139-32.cassatt.com ([63.192.139.32]
	helo=GREYHOUND.cassatt.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmGam-0001cH-NQ
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 13:22:17 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1164057026.5723.65.camel@lade.trondhjem.org>
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



feature - Wow - I'm surprised part of this could be
integrated without having the full solution put
together.

At the moment we have a diskless NFS system setup
for booting our systems.  We have the root as read-only and other
mount points mounted read-write (/usr, /var, ...)

With this feature integrated we have to make sure our read-only
and our read-write directories are in different physical partitions
on the server?  Wow - in my mind this is a drastic change
to integrate without having the full solution present?  Previously
the only thing we had to worry about on the server was how
the NFS exports were setup.

Can you point me to where the required 'mount --bind' fixes are
being discussed?  I haven't been able to find the
thread in the 'lkml' (not that it isn't there somewhere).

Without the matching 'mount --bind' fixes this is a very serious
regression for us?

Thanx for info.

_Mike_



Trond Myklebust wrote:
> On Mon, 2006-11-20 at 12:57 -0800, Michael Walker wrote:
>> All,
>>
>> Any insights on this?
>>
>> I did find the following post from Trond which appears
>>
>>    http://lkml.org/lkml/2006/10/18/264
>>
>> Which seems to imply that this is a 'feature' and not
>> a 'bug'?  Is that true - or have I missed something?
> 
> That is quite correct (thanks for taking the time to search the list
> archives). For various reasons, we're trying to tighten the NFS cache
> consistency. That means that practices that were previously allowed
> (such as mounting different directories from the same filesystem using
> different mount options) have been restricted.
> The ability to have the same filesystem mounted both read-only and
> read-write will hopefully soon be allowed again, but it needs to be
> fixed at the VFS level. The patches to do so have circulated for quite
> some time now, but have not been merged due to disagreements over how
> the user interface for 'mount --bind' should be in this case.
> 
> Cheers
>   Trond
> 
>> Thanx,
>>    _Mike_
>>
>>
>> Michael Walker wrote:
>>> All,
>>>
>>> I'm having problems with the latest version of FC5 which
>>> contains kernel 2.6.18 - the problem is that NFS mounts
>>> of read-write file-systems are being mounted read-only, sometimes.
>>>
>>> Whether a mount is mounted read-only or read-write seems
>>> to very depending upon what other directories were
>>> mounted from the same server and with what options.
>>>
>>> Take the following file-systems exported from my
>>> Linux Server server:
>>>
>>>    root@polyslo:/proc/fs/nfs# cat /etc/exports
>>>    /disk1/dir_ro   *(ro,no_root_squash,sync,wdelay,no_subtree_check)
>>>    /disk1/dir_rw   *(rw,no_root_squash,sync,wdelay,no_subtree_check)
>>>    root@polyslo:/proc/fs/nfs# showmount -e 10.20.20.48
>>>    Export list for 10.20.20.48:
>>>    /disk1/dir_rw *
>>>    /disk1/dir_ro *
>>>    root@polyslo:/proc/fs/nfs#
>>>
>>> If I now do the following mounts (in this order):
>>>
>>>    # Mount initial directory read-only - this is intentional
>>>    mount -t nfs -o ro 10.20.20.48:/disk1/dir_ro /tmp/dir_ro
>>>
>>>    # Attempt to mount second directory read-write
>>>    mount -t nfs -o rw 10.20.20.48:/disk1/dir_rw /tmp/dir_rw
>>>
>>>    # Now I attempt to touch a file in the rw directory:
>>>    [root@vt-1 tmp]# touch /tmp/dir_rw/hello
>>>    touch: cannot touch `/tmp/dir_rw/hello': Read-only file system
>>>
>>>    # And if I take a look in the /proc/mounts directory - I see
>>>    # that the directory was truly mounted read-only
>>>
>>>    [root@vt-1 tmp]# grep 10.20.20.48 /proc/mounts
>>>    10.20.20.48:/disk1/dir_ro /tmp/dir_ro nfs 
>>> ro,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.20.20.48 
>>> 0 0
>>>    10.20.20.48:/disk1/dir_rw /tmp/dir_rw nfs 
>>> ro,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.20.20.48 
>>> 0 0
>>>    [root@vt-1 tmp]#
>>>
>>> The above seems wrong to me - can someone clarify what's going on.
>>> I know that this is new behavior that was not true in the past.  My
>>> RHEL_4U4 server running 2.6.9 kernel does not have this problem.
>>>
>>> Notice that if I change the order of the mounts I get different behavior:
>>>
>>>    # Initially mount the read-write directory:
>>>    mount -t nfs -o rw 10.20.20.48:/disk1/dir_rw /tmp/dir_rw
>>>
>>>    # Then mount the read-only directory:
>>>    mount -t nfs -o ro 10.20.20.48:/disk1/dir_ro /tmp/dir_ro
>>>
>>>    # Now the directories are mounted as I wish, I can write to the
>>>    # read-write mount:
>>>    [root@vt-1 tmp]# touch /tmp/dir_rw/hello
>>>    [root@vt-1 tmp]#
>>>
>>>    # And the read-only directory is read-only:
>>>    [root@vt-1 tmp]# touch /tmp/dir_ro/hello
>>>    touch: cannot touch `/tmp/dir_ro/hello': Read-only file system
>>>    [root@vt-1 tmp]#
>>>
>>>    # And the /proc/mounts file reflects the states I expect
>>>    [root@vt-1 tmp]# grep 10.20.20.48 /proc/mounts
>>>    10.20.20.48:/disk1/dir_rw /tmp/dir_rw nfs 
>>> rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.20.20.48 
>>> 0 0
>>>    10.20.20.48:/disk1/dir_ro /tmp/dir_ro nfs 
>>> rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.20.20.48 
>>> 0 0
>>>    [root@vt-1 tmp]#
>>>
>>>
>>> Note that previously the order did not matter and the permissions
>>> always reflected the permissions of the individual mount requests.
>>>
>>> If someone could provide insights on what's going on above that
>>> would be great.  This is a artificial test case - but it's actually
>>> hitting code we have in production and will be a significant
>>> issue for us.
>>>
>>> Thanx much!
>>>
>>> _Mike_
>>
>> -------------------------------------------------------------------------
>> Take Surveys. Earn Cash. Influence the Future of IT
>> Join SourceForge.net's Techsay panel and you'll get the chance to share your
>> opinions on IT & business topics through brief surveys - and earn cash
>> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
