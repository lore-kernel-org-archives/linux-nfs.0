From: Patrick - South Valley Internet <patrickm@garlic.com>
Subject: Re: Creating a Load Balanced E-mail Server with NFS mounts
 with CentOS - how to optimize for performance?
Date: Sat, 14 Jul 2007 16:38:09 -0700
Message-ID: <46995E61.4050503@garlic.com>
References: <4698100A.1070702@garlic.com>
	<1184427086.7115.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9rBf-00061f-WB
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 16:38:08 -0700
Received: from sequoia.garlic.com ([216.139.0.84])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9rBj-0006nG-ID
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 16:38:11 -0700
In-Reply-To: <1184427086.7115.13.camel@heimdal.trondhjem.org>
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

Trond Myklebust wrote:
> On Fri, 2007-07-13 at 16:51 -0700, Patrick - South Valley Internet
> wrote:
>   
>> Hi all,
>>
>> I'm finishing up our new load balanced e-mail server which consists of 
>> two Dell dual cpu Opterons NFS mounting our 1.6TB RAID 5 server - all 3 
>> machines run CentOS.  I have VMWare server installed on both Dell 
>> Opterons which both machines run a CentOS LDAP server (uses 256mb RAM), 
>> and a CentOS Postfix server.  I have noticed no performance loss running 
>> VMWare, as far as I can tell.  The reason I mention this is because I've 
>> had experience in the past with other applications, such as 
>> Trixbox/Asterisk that require you to NOT run this on a VM due to issues 
>> with real time processing and such.  Just want to make sure that this 
>> isn't the case for this scenerio (which I don't think, since I'm only 
>> experiencing issues on the NFS mounted directories)
>>
>> Anyhow, I can successfully mount the NFS from both Postfix VM's without 
>> a problem.  I created a /vol/vol0/home directory on the NFS, and mount 
>> that to /home on both Postfix VM's.  Doing a 'ls -l' in /home takes 
>> forever, sometimes longer than I wish (30+ seconds, sometimes longer).  
>> I read the NFS performance documentation on testing the read and write 
>> speeds and timing them, and I've come up with these:
>>
>> #####################
>> [root@somebox mnt]# time dd if=/dev/zero of=/home/testfile bs=16k 
>> count=16384
>> 16384+0 records in
>> 16384+0 records out
>>
>> real    0m43.282s
>> user    0m0.010s
>> sys     0m2.043s
>>
>>
>>
>> [root@somebox mnt]# time dd if=/home/testfile of=/dev/null bs=16k
>> 16384+0 records in
>> 16384+0 records out
>>
>> real    0m22.943s
>> user    0m0.016s
>> sys     0m0.629s
>> ####################
>>
>>
>> I've tried to set different rsize and wsize (4096, 8192, 16384, and 
>> 32768), and it doesn't seem to be doing any different.  I've checked the 
>> switch settings to make sure there weren't any inconsistencies and are 
>> set to 100xFD.
>>
>>
>>
>> My /etc/fstab looks like this:
>>
>> xxx.yyy.com:/vol/vol0/home          /home       nfs     
>> rw,hard,intr,rsize=32768,wsize=32768        0 0
>> xxx.yyy.com:/vol/vol0/spool-mail          /spool-mail       nfs     
>> rw,hard,intr,rsize=32768,wsize=32768        0 0
>> xxx.yyy.com:/vol/vol0/spool-xxx-mqueue          /spool-mqueue       
>> nfs     rw,hard,intr,rsize=32768,wsize=32768        0 0
>>
>>
>> I'm concerned because there will be a lot of activity on these servers, 
>> and I need this to be as fast as possible.
>>
>> Do I have my mountpoints defined properly?
>>
>> If I need to provide hardware descriptions of my machines, let me know 
>> and I will do a lspci.
>>
>> Thanks to everyone in advance.
>>     
>
> Three questions:
>      1. What kind of network are you using for your VMWare installation?
>         If you are using NAT, I'd suggest trying a bridged network
>         instead.
>      2. Are you using TCP or UDP? It is not clear from the above what
>         the default is on CentOS. I'd suggest explicitly selecting TCP.
>      3. What kind of iptables setup do you have?
>
> Trond
>
>
>
>
>
>   



Thanks for the response.

1) I am using Bridged Network for the VMWare installation.
2) I'm not sure if I am using TCP or UDP - how do I check?
3) I do not have any iptables set up - should I?

Thanks again for the response.  Let me know if I need to provide anymore 
information.

Patrick



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
