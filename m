From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Tue, 23 Nov 2004 10:50:55 +0100
Message-ID: <41A307FF.3080300@int-evry.fr>
References: <EXCHG20034NQhEP9w0z00007249@EXCHG2003.microtech-ks.com>	 <41A25DCB.6020700@int-evry.fr>  <41A25FA3.6060000@int-evry.fr> <1101162043.11196.88.camel@lade.trondhjem.org> <41A26EF1.8040404@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Roger Heflin <rheflin@atipa.com>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net, mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWXKK-0004RZ-Kt
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 01:51:12 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWXKG-0001uZ-Mw
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 01:51:12 -0800
To: jehan procaccia <jehan.procaccia@int-evry.fr>
In-Reply-To: <41A26EF1.8040404@int-evry.fr>
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

I found something interesting ! If I export an internal scsi disk of my=20
NFS server (/home) I get good performances,  My problem is with exports=20
from the Dell/EMC Storage Processor , I will open a ticket about that on=20
the hotline ...

Nfs servor exporting an Internal scsi disk in sync mode
$ cat /var/lib/nfs/xtab
/home  =20
arvouin.int-evry.fr(rw,sync,no_wdelay,hide,nocrossmnt,secure,no_root_squa=
sh,no_all_squash,subtree_check,secure_locks,no_acl,mapping=3Didentity,ano=
nuid=3D-2,anongid=3D-2)

Client mount in sync an NFS export in sync also !:
cobra3:/home /mnt/cobra3home nfs=20
rw,sync,v3,rsize=3D8192,wsize=3D8192,hard,tcp,lock,addr=3Dcobra3 0 0
[root@arvouin /mnt/cobra3home/Nfs-test]
$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
real    0m27.719s
user    0m1.002s
sys     0m4.296s

[root@arvouin /mnt/cobra3home/Nfs-test]
$./test2.sh
Test without directory sync after file creation
=20
real    0m0.568s
user    0m0.031s
sys     0m0.114s
Test2 with directory sync after file creation
=20
real    0m0.904s
user    0m0.094s
sys     0m0.266s


This is what I expect in term of performances . I will continue my=20
requests on the DEll/EMC hotline , but maybe the security of that AX100=20
storage Processor (raid5, spare disk, double fiber attachement, UPS)=20
allows me to use async export mode in such a case ?

thanks .

jehan procaccia wrote:

> Trond Myklebust wrote:
>
>> m=E5 den 22.11.2004 Klokka 22:52 (+0100) skreiv jehan procaccia:
>> =20
>>
>>>> [root@arvouin tmp]# mount cobra3:/p2v5f1 -o=20
>>>> async,wsize=3D32768,rsize=3D32768,soft /mnt/cobra3
>>>> [root@arvouin /mnt/cobra3/mci/test/Test-sync]
>>>> $time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
>>>>
>>>> sorry I don't want to wait more than 10 minutes to send that mail,=20
>>>> but again seeing the files apperaing very slowly on the tty it=20
>>>> seems not to be the solution :-( .
>>>>    =20
>>>
>>
>> The following script may help you understand why things are slower in
>> the case of "async" on an untar. It basically just creates a bunch of
>> files: in the first test it does not sync the directory to disk after
>> each file creation, in the second case it does. The test does no
>> reads/writes to the file.
>>
>> Run it on the server and you will see  a clear difference in time
>> between test1 and test2. Run it on the client, and there should be
>> little difference between test1 and test2 (but there will be a heavy
>> dependency on the "async" vs "sync" export flag on the server).
>> =20
>>
> These prediction are perfect, this is exaclty  what happened:
> I reduce the loop from 1000 to 100, it was too long on the client in=20
> sync mode ....
>
> [root@cobra3 /p2v5f1/mci/test/Test-sync]
> $ ./test2.sh
> Test without directory sync after file creation
>
> real    0m0.037s
> user    0m0.010s
> sys     0m0.000s
> Test2 with directory sync after file creation
>
> real    0m6.040s
> user    0m0.000s
> sys     0m0.000s
>
> NFS client, while server export in sync mode
> cobra3:/p2v5f1 /mnt/cobra3 nfs=20
> rw,v3,rsize=3D8192,wsize=3D8192,soft,tcp,lock,addr=3Dcobra3 0 0
> $./test2.sh
> Test without directory sync after file creation
>
> real    0m31.144s
> user    0m0.042s
> sys     0m0.373s
> Test2 with directory sync after file creation
>
> real    0m49.030s
> user    0m0.073s
> sys     0m0.694s
>
> Now NFS server exports in async mode to the client, performances are=20
> far better , even better than direclty on the server when forcing a=20
> sync call after every creation !
> $./test2.sh
> Test without directory sync after file creation
>
> real    0m0.446s
> user    0m0.026s
> sys     0m0.078s
> Test2 with directory sync after file creation
>
> real    0m0.785s
> user    0m0.076s
> sys     0m0.305s
>
> Hopefully I'll try to capture traffic next wednesday when I'll be back=20
> at work ..
>
> Thanks.
>
>> NFSv3 mandates that all directory-related operations should behave as =
in
>> test 2. Only writes to ordinary files may be cached by the server, and
>> when the client sends a COMMIT request, the server should do an fsync(=
)
>> on that file.
>>
>> Cheers,
>>  Trond
>> =20
>>
>
>
>
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users=
.
> Discover which products truly live up to the hype. Start reading now.=20
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nf
> s




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
