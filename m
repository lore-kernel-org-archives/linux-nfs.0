From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems Migrating from NFSv3 to NFSv4
Date: Fri, 20 Nov 2009 13:15:38 -0500
Message-ID: <20091120181538.GA8841@fieldses.org>
References: <4B01A0B5.80501@informatik.uni-wuerzburg.de> <20091118211419.GA2650@fieldses.org> <4B054EF8.7000102@informatik.uni-wuerzburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Christopher Metter
	<christopher.metter-jNDFPZUTrfSeRcrpBB1ZFQkon6kHRKkiG9Ur7JDdleE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57919 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753868AbZKTSPC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 13:15:02 -0500
In-Reply-To: <4B054EF8.7000102-jNDFPZUTrfSeRcrpBB1ZFQkon6kHRKkiG9Ur7JDdleE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 19, 2009 at 02:58:16PM +0100, Christopher Metter wrote:
> J. Bruce Fields schrieb:
>> On Mon, Nov 16, 2009 at 07:57:57PM +0100, Christopher Metter wrote:
>>   
>>> Hi there folks!
>>>
>>> Im trying to migrate from NFSv3 to NFSv4. I've read diverse Articles 
>>> and  Howtos, but i cant find a solution to my problem.
>>>
>>> For better understanding: My NFSv4 Root is /srv/data/, a Folder that  
>>> existed before and has diverse Subfolders in it. These Folders are   
>>> really there and are not mounted by "mount --bind".
>>>
>>> The Servers IP: 192.168.0.10
>>> Client1: 192.168.0.1
>>> Client2: 192.168.0.2
>>>
>>> Setup with NFSv3:
>>> 2 Folders (scratch and software) were shared for 2 Clients. In 
>>> Scratch  both clients had full RW-access and on software only Client2 
>>> had rw,  Client1 had RO.
>>> Config:
>>> /srv/data/scratch-all    *(rw,async,no_root_squash,nohide,no_subtree_check)
>>> /srv/data/software      
>>> 10.0.12.4(ro,sync,no_root_squash,nohide,no_subtree_check)   
>>> 10.0.12.5(rw,sync,no_root_squash,nohide,no_subtree_check)
>>>
>>> My NFSv4 Config (from Server/etc/exports)
>>> |/srv/data/   
>>> 192.168.0.2(rw,sync,fsid=0,insecure,no_root_squash,no_subtree_check)  
>>> 192.168.0.1(rw,sync,fsid=0,insecure,no_root_squash,no_subtree_check)
>>> /srv/data/scratch *(rw,async,no_root_squash,no_subtree_check)
>>> /srv/data/software 
>>> 192.168.0.1(ro,sync,no_root_squash,no_subtree_check)   
>>> 192.168.0.2(rw,sync,no_root_squash,no_subtree_check)
>>> |
>>> After that i mounted from Client1 and Client2  the Sharefolders   
>>> directrly (e.g. software: mount -t nfs4 -o intr,hard,rw   
>>> 192.168.0.10:/software  /targetfolder), everything works perfect, 
>>> every  Client has its specific rights and so on.
>>>
>>> But if im mounting Servers Root (mount -t nfs4 -o intr,hard,rw   
>>> 192.168.0.10:/ /targetfolder)  from Client1 I do have complete RW 
>>> Access  to the full "Data" folder, even with RW for Software (which i 
>>> set for  RO).
>>>     
>>
>> Exports don't operate on "folders", only on filesystems: if you export
>> /srv/data/ read-write, and if /srv/data/software is on the same
>> filesystem as /srv/data, then /srv/data will also be exported, and also
>> writeable.
>>
>> --b
> Is there a workaround to this behavior? Or a trick to get an NFSv4 Setup  
> corresponding to the NFSv3 Setup?

If you add a trivial mountpoint there with:

	"mount --bind /srv/data/software /srv/data/software"

I think that will do the job.

Note this isn't really secure--this will prevent users on 192.168.0.1
from accidentally modifying software/, but won't do anything against
someone malicious with access to the network.

--b.
