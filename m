Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3FZTUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:20:43 -0400
Message-ID: <51CB3F08.9050005@RedHat.com>
Date: Wed, 26 Jun 2013 15:20:40 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Christopher T Vogan <cvogan@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com> <1371568176.3868.5.camel@leira.trondhjem.org> <OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 18/06/13 15:59, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Christopher T Vogan [mailto:cvogan@us.ibm.com]
>> Sent: Tuesday, June 18, 2013 3:56 PM
>> To: Myklebust, Trond
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: NFSERR_STALE on umount with 3.10.0.RC5 kernel
>>
>> The NFS server uses UMNT as a signal to remove the client from its mount
>> table. Also at this time the Server cleans up other information about the now
>> disconnected client.  Why would the client attempt to access the NFS server
>> once it has stated its going to unmount?  I do not see the point of the
>> GETATTR request after UMNT call.
> 
> As I said, the umount.nfs utility is doing the umount system call after UMNT, so the 
> client does a lookup of the umount path at that time.
> 
> IOW: This has nothing to do with the kernel. If you feel it is a bug, then please ask 
> SteveD to file a fix against nfs-utils.
> 
I just took a look at the umount code and it appears the UMNT call and 
umount() system call are being done in the correct order... 

The UMNT call is done in nfs_umount23() which is follow by either
mnt_context_do_umount() (if using the libmount code) or del_mtab()
which make the umount() system call....

Would it be possible to post a bzip2 binary network trace file so I can
poke around... something similar:
    tshark -w /tmp/data.pcap host <server>
    bzip2 /tmp/data.pcap

steved.
