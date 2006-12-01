From: Weikuan Yu <wyu@ornl.gov>
Subject: Re: NFS export of TMPFS
Date: Fri, 01 Dec 2006 16:56:43 -0500
Message-ID: <4570A51B.3080800@ornl.gov>
References: <4570A2C1.3060707@ornl.gov> <4570A407.6020007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqGNB-0004iq-3z
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 13:56:45 -0800
Received: from emroute1.ornl.gov ([160.91.4.119])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GqGNC-0005ip-Bv
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 13:56:46 -0800
Received: from emroute1.ornl.gov ([127.0.0.1])
	by emroute1.ornl.gov (PMDF V6.3-x3 #31246)
	with ESMTP id <0J9M00HKI7MK3Q@emroute1.ornl.gov> for
	nfs@lists.sourceforge.net; Fri, 01 Dec 2006 16:56:44 -0500 (EST)
In-reply-to: <4570A407.6020007@redhat.com>
To: Peter Staubach <staubach@redhat.com>
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

Thansk for your prompt reply. Forgot to add that they are exported. Here 
  is the output from exportfs. The problem is I can nfs-mount /data 
(/dev/hda2) fine, but not /nfs (tmpfs).

Weikuan

-bash-3.00# exportfs
/nfs            160.91.202.127/255.255.255.128
/data           160.91.202.127/255.255.255.128
/nfs            192.168.120.*
/data           192.168.120.*


Peter Staubach wrote:
> Weikuan Yu wrote:
> 
>> Hi,
>>
>> I am trying to export a memory-based file system via NFS. However, I 
>> am not able to do with either ramfs or tmpfs. Here is the reported 
>> error. Is there a protection in NFS server to prevent this?
>>
>> I also tried to use ramdisk. That worked, however, I am not able to 
>> create a ramdisk of more than 1G. I need to create a ramdisk that is 
>> 2G or more. Any insights on this.
>>
>> I will be happy if I can get solutions for either of the approaches. 
>> Or is there any other alternatives?
>>
>> Thanks,
>> Weikuan
>>
>> [root@yoda1 ~]# mount -t tmpfs none /nfs
>> [root@yoda1 ~]# df -h /nfs
>> Filesystem            Size  Used Avail Use% Mounted on
>> none                  506M     0  506M   0% /nfs
>> [root@yoda1 ~]# ssh node0002
>> -bash-3.00# mount 192.168.1.254:/nfs /nfs
>> mount: 192.168.1.254:/nfs failed, reason given by server: Permission 
>> denied
> 
> 
> You might try exportfs(8)'ing the file system before trying to mount it...
> 
>       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
