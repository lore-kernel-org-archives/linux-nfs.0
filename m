From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: Configuring NFS service for speed - Re: async vs. sync
Date: Tue, 23 Nov 2004 00:36:39 +0100
Message-ID: <41A27807.1010503@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>	<20041122153655.GH1291@suse.de>	<41A2280B.1010005@int-evry.fr> <16802.27027.931420.574610@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWNjj-0000eK-LT
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 15:36:47 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWNji-0007Im-GJ
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 15:36:47 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16802.27027.931420.574610@cse.unsw.edu.au>
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

>On Monday November 22, jehan.procaccia@int-evry.fr wrote:
>  
>
>>My users won't accept the sync performances ! . I have no choice, but is 
>>running in async mode is really evil as you mentioned it ? is there a 
>>way to have better performances in sync in my case ?  As anyone had the 
>>same gap in performance as me ( here 55 times longer in sync mode !)  ?
>>    
>>
>
>The best way to get good nfs performance with a sync export is to use
>a data-journalling filesystem, and have the journal somewhere fast.
>
>I use ext3.  I believe that some other filesystems support data
>journalling, but I don't know the details.
>
>An ext3 filesystem exported with "data=journal" is significantly
>faster that with the default "data=ordered".
>
>With ext3, it also helps to export with the "no_wdelay" export
>option.  I'm not entirely sure why this helps, and I haven't confirmed
>that it is still the case (I discovered this at least 2 years ago) but
>it is worth checking in your environment.
>  
>
OK, I've just tested with a FS mounted with data=journal in /etc/fstab 
(but journal isn't somewhere else ..) and no_wdelay in exports

NFS server FS and exports:
[root@cobra3 ]
$ grep emc /var/lib/nfs/xtab
/mnt/emcpowerl1 
arvouin.int-evry.fr(rw,sync,no_wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,subtree_check,secure_locks,no_acl,mapping=identity,anonuid=-2,anongid=-2)
$ grep emcpowerl1 /etc/fstab
/dev/emcpowerl1         /mnt/emcpowerl1         ext3    
defaults,data=journal,usrquota,grpquota 1 2

NFS client:
cobra3:/mnt/emcpowerl1 /mnt/cobra3journal nfs 
rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0
Trond Myklebust 's test script apparently goes faster :-)
[root@arvouin /mnt/cobra3journal/test/Nfs]
$./test2.sh
Test without directory sync after file creation

real    0m12.243s
user    0m0.016s
sys     0m0.094s
Test2 with directory sync after file creation

real    0m12.195s
user    0m0.090s
sys     0m0.342s


It took 31s for test1 and 49s for test2 before data=journal and 
no_wdelay, now it takes 12s in both cases :-) ,  finally, that's my 
first performance enhencement tonight !.

However tar xvfz is still very long :-(
[root@arvouin /mnt/cobra3journal/test/Nfs]
$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    12m5.968s
user    0m1.026s
sys     0m4.362s

I still miss something ...

>Ext3 supports having the journal on a separate device.  If you put it
>on a fast device, you will get faster response.
>
>One option is to buy an NV-RAM card and put the journal on that.
>www.umem.com is one supplier that I know of.  There are doubtlessly
>others.
>
>Another option is to put it on a separate drive, or preferably a
>separate mirrored pair.  As journal writes are sequential, you won't
>suffer seek time on the journal device and it will be quite fast.
>
>My typical fileserver configuration is to have a pair of small (36gig
>is the smallest I can easily get) 15K SCSI drives as a mirrored pair,
>and to put root, swap, and a journal partition on this.
>Then a separate box contains a dozen or so drives of whatever size I
>want in a raid5 configuration.  The ext3 filesystem is on the raid5
>array, the journal is on the mirrored pair with root and swap.  There
>is almost no IO to root and swap, so the journal gets the drives
>almost to itself.
>This configuration is adequately fast.
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
