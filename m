From: Bas van der Vlies <basv@sara.nl>
Subject: Re: NFSD crashes with oops
Date: Wed, 08 Mar 2006 16:23:16 +0100
Message-ID: <440EF6E4.4080109@sara.nl>
References: <5F4E2391-4553-4A5A-8A92-1033CE717267@sara.nl>	 <440EE57B.2090804@sara.nl> <1141830321.8214.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FH0Vn-0003ql-NL
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 07:23:39 -0800
Received: from surfboard.ka.sara.nl ([145.100.6.3])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FH0Vi-0001sR-AS
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 07:23:36 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
In-Reply-To: <1141830321.8214.21.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> On Wed, 2006-03-08 at 15:08 +0100, Bas van der Vlies wrote:
>> Bas van der Vlies wrote:
>>> At our side we have an 4 node GFS cluster. The nodes act as an 
>>> NFS-server to +/- 640 nodes.
>>>
>> Just upgraded to 2.6.16-rc5 and still nfsd crashes. With more debug 
>> output. So some code is fixed in this release. Nfsd crashes instead
>> of 128 we now have 127, nfsd still runing now.
>>
>> == Crash Output ==
>> Unable to handle kernel NULL pointer dereference at virtual address 00000038
>>   printing eip:
>> f89a4be3
>> *pde = 37809001
>> *pte = 00000000
>> Oops: 0000 [#1]
>> SMP
>> Modules linked in: lock_dlm dlm cman dm_round_robin dm_multipath sg 
>> ide_floppy ide_cd cdrom qla2xxx siimage piix e1000 gfs lock_harness dm_mod
>> CPU:    0
>> EIP:    0060:[<f89a4be3>]    Tainted: GF     VLI
>> EFLAGS: 00010246   (2.6.16-rc5-sara3 #1)
>> EIP is at gfs_create+0x6f/0x153 [gfs]
> 
> This is Oopsing in the GFS code, not nfsd.
> 
Thanks for the info. Just for my knowledge. The nfsd crashes because 
there is an error in the gfs_create code?

The problem is that gfs-filesystems are still accesible and if we are
lucky we have on thread less else the load on the gfs-fileserver is sky 
high and it does not respond to the nfs-requests anymore. So all nfsd 
processes are locked.

Regards


-- 
--
********************************************************************
*                                                                  *
*  Bas van der Vlies                     e-mail: basv@sara.nl      *
*  SARA - Academic Computing Services    phone:  +31 20 592 8012   *
*  Kruislaan 415                         fax:    +31 20 6683167    *
*  1098 SJ Amsterdam                                               *
*                                                                  *
********************************************************************


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
