From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 18:55:23 +0100
Message-ID: <41A2280B.1010005@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com> <20041122153655.GH1291@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no,
	mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWIPd-0002xM-Ps
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 09:55:41 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWIPc-00070Y-6T
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 09:55:41 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041122153655.GH1291@suse.de>
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

Olaf Kirch wrote:

>On Tue, Nov 16, 2004 at 10:48:12AM -0800, Lever, Charles wrote:
>  
>
>>i'm just looking for clarification so i can provide a good explanation
>>in the Linux NFS FAQ about the evils of using "async."  i'll cruise
>>through the server code.
>>    
>>
>
>Just about the only reason for async I can think of is if you have an
>incoming data stream you need to write at a constant rate (think of a
>diskless set top box writing an mpeg2 stream)
>
>Olaf
>  
>
OK, but using sync at my site is really really slow ... compare to async 
! here's a detailed (options printed) demonstration for an untar 
operation that takes 13 minutes in async mode and only 14 secondes in 
sync mode !!

1) Export in sync mode
NFS server  (RedHat ES3 kernel 2.4.21-4.ELsmp) options for that export:
$ cat /proc/fs/nfs/exports | grep arvouin
/p2v5f1 arvouin.int-evry.fr(rw,no_root_squash,sync,wdelay,acl) # 
157.159.21.55
$ cat /var/lib/nfs/xtab  | grep arvouin
/p2v5f1 
arvouin.int-evry.fr(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,subtree_check,secure_locks,acl,mapping=identity,anonuid=-2,anongid=-2)

Client running Fedora Core 2, kernel 2.6.8-1.521
[root@arvouin /mnt/cobra3/mci/test/Test-sync]
$cat /proc/mounts
cobra3:/p2v5f1 /mnt/cobra3 nfs 
rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0
$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    13m3.686s
user    0m1.055s
sys     0m4.354s

2) Export in async mode:
Same NFS server, options for that export:
$ cat /proc/fs/nfs/exports | grep arvouin
/p2v5f1 arvouin.int-evry.fr(rw,no_root_squash,async,wdelay,acl) # 
157.159.21.55
$ cat /var/lib/nfs/xtab  | grep arvouin
/p2v5f2 
arvouin.int-evry.fr(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,subtree_check,secure_locks,acl,mapping=identity,anonuid=-2,anongid=-2)

Same client running Fedora Core 2, kernel 2.6.8-1.521
cobra3:/p2v5f1 /mnt/cobra3 nfs 
rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0
[root@arvouin /mnt/cobra3/mci/test/Test-sync]
$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    0m14.802s
user    0m0.867s
sys     0m2.886s

My users won't accept the sync performances ! . I have no choice, but is 
running in async mode is really evil as you mentioned it ? is there a 
way to have better performances in sync in my case ?  As anyone had the 
same gap in performance as me ( here 55 times longer in sync mode !)  ?

Thanks.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
