From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Thu, 25 Nov 2004 00:14:36 +0100
Message-ID: <41A515DC.7010408@int-evry.fr>
References: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com>	<41A3AFC4.6080404@int-evry.fr>	<41A4D6C5.2060902@int-evry.fr> <16805.2572.79895.275921@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX6Lj-0002Qr-5L
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:14:59 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CX6Lg-0000eV-FO
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:14:58 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16805.2572.79895.275921@cse.unsw.edu.au>
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

>On Wednesday November 24, jehan.procaccia@int-evry.fr wrote:
>  
>
>>However now the tar extraction goes very fast but stops 1 or 2  or  and 
>>restart fast -> there are some hangs. Here with a 16MB journal I got 15 
>>hangs of 1-2 seconds, with a 128 MB I get only 3 hangs but they last 4or 
>>5 seconds. I checked at a momment of an hang on the nfs server with 
>>iostat, and disk utilisation goes from a few % to  316 % in the exemple 
>>below (for 128 MB journal withing the 4 seconds hangs it goes to 4700 % !)
>>Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
>>avgrq-sz avgqu-sz   await  svctm  %util
>>/dev/emcpowerl2
>>             0.00 150.67 97.33 224.00  768.00 3018.67   384.00  
>>1509.33    11.78    33.33   19.79   9.83 316.00
>>
>>Maybe it hangs because the journal commits on the SP ! ?
>>
>>    
>>
>
>It hangs because of some clumsy code in ext3 that no-one has bothered
>to fix yet - I had a look once but it was a little beyond the time I
>had to spare.
>
>When information is written to the journal, it stays in memory as well
>and is eventually written out to the main filesystem using normal
>lazy-flushing mechanisms (data is pushed out either due to memory
>pressure or because it has been idle for too long).
>When ext3 wants to add information to the head of the journal, it
>needs to clean up the tail to make space.
>If it finds that the data that was written to the tail is already
>safe in the main filesystem, it just frees up some of the  tail and
>starts using it for a new head.
>HOWEVER, if it finds that the data in the tail hasn't made it to the
>main filesystem, it flushes *ALL* of the data in the journal out to
>the main filesystem. (It should only flush some fraction or fixed
>number of blocks or something).  This flushing causes a very
>noticeable pause.  The larger the journal, the less often the flush is
>needed, but the longer the flush lasts for.
>
>There are two ways to avoid this pause.  One I have tested and works
>well.  The other only just occurred to me and I haven't tried.
>
>The untested one involves making the journal larger than main memory.
>If it is that large, then memory pressure should flush out journal
>blocks before the journal wraps back to them, and so the flush should
>never happen.  However such a large journal may cause other problems
>(slow replay) as mentioned in my other email.
>
>The way that works if to adjust the "bdflush" parameters so that data
>is flushed to disk more quickly.  The default is to flush data once it
>is 30 seconds old.  If you reduce that to 5 seconds, the problem goes
>away. 
>
>For 2.4, I put
>vm.bdflush =  30 500 0 0 100 500 60 20 0
>
>in my /etc/sysctl.conf, which is equivalent to running
>  echo   30 500 0 0 100 500 60 20 0 > /proc/sys/vm/bdflush
>  
>

$ uname -r
2.4.21-4.ELsmp
here's what I had before setting the above:
$ cat /proc/sys/vm/bdflush
50      500     0       0       500     3000    80      50      0

Now indeed pauses seems to be shorter (I've seen 12 instead of 15 and 
they latest less than 1s )
[root@arvouin Nfs-test]# time tar xvfz 
/usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    1m22.504s
user    0m0.898s
sys     0m2.846s

On a 128MB journal it's even better, I don't see any pauses (I had a 
least 3 of each 4-5 seconds before) .
[root@arvouin Nfs-test]# time tar xvfz 
/usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    0m25.038s
user    0m0.914s
sys     0m2.477s

Very good :-)

just for the record so that I'am sure how I got that performance, here 
is the server's export options: (data=journal in /etc/fstab for that FS !)
$ cat /var/lib/nfs/xtab
/mnt/emcpowerm1 
arvouin.int-evry.fr(rw,sync,no_wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,subtree_check,secure_locks,no_acl,mapping=identity,anonuid=-2,anongid=-2)
and client mount option
[root@arvouin Nfs-test]# cat /proc/mounts
cobra3:/mnt/emcpowerm1 /mnt/cobra3extjournal nfs 
rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0

To be sure of the improvement of the "hack" on /proc/sys/vm/bdflush I've 
set it back to the original values:
$ echo 50 500 0 0 500 3000 80 50 0 > /proc/sys/vm/bdflush

and dynamically (no unmount or remont anything on either side) test again

[root@arvouin Nfs-test]# time tar xvfz 
/usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    1m19.655s
user    0m0.860s
sys     0m2.612s

time is longer and pauses are worst than I though -> 3 pauses of 
approximately 10 to 15 seconds each !

So it seem to be a very good advice to echo   30 500 0 0 100 500 60 20 0 
 > /proc/sys/vm/bdflush  :-)
however this is a general configuration, will it disturb other devices ? 
what means every figures here ? why where they set to an non optimal 
value iin the 1st place ?

PS:  different optimisation:
I've read this "the maximum block size is
defined by the value of the kernel constant *NFSSVC_MAXBLKSIZE*,
found in the Linux kernel source file ./include/linux/nfsd/const.h"
is there a way to change my actual 8K buffer size to 32 K without 
recompiling the kernel ?

thanks.


>For 2.6, I assume you would
>   echo 500 > /proc/sys/vm/dirty_expire_centisecs
>but I haven't tested this.
>
>
>  
>
>>Well, finally, is this safer in terms of performances to externalize 
>>journal than using async export ?
>>    
>>
>
>Absolutely, providing you trust the hardware that you are storing your
>journal on.
>An external journal is perfectly safe.
>async export is not.
>
>NeilBrown
>  
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
