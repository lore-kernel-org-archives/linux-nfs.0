Return-Path: linux-nfs-owner@vger.kernel.org
Received: from odin2.bull.net ([129.184.85.11]:57012 "EHLO odin2.bull.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab2IFIQI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 04:16:08 -0400
Message-ID: <50485C19.4030502@bull.net>
Date: Thu, 06 Sep 2012 10:17:29 +0200
From: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <trond.myklebust@netapp.com>
Subject: Re: NFSv3 caching vs NFSv4
References: <50474858.1020801@bull.net> <4FA345DA4F4AE44899BD2B03EEEC2FA908F8612E@SACEXCMBX04-PRD.hq.netapp.com> <20120905172158.GA9002@fieldses.org>
In-Reply-To: <20120905172158.GA9002@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, so this is a delegation bug. I think you're rigth Bruce, I cannot 
see the bug if I just modify the file with vi.

I'll try your delegation patch ASAP.

Thanks,

Diego

On Wed 05 Sep 2012 07:21:58 PM CEST, J. Bruce Fields wrote:
> On Wed, Sep 05, 2012 at 02:49:18PM +0000, Myklebust, Trond wrote:
>> On Wed, 2012-09-05 at 14:40 +0200, Diego Moreno wrote:
>>> Hello everyone,
>>>
>>> Performing some attribute caching tests I think I found some
>>> inconsistencies between nfsv3 and nfsv4. Running a kernel based on
>>> rhel6.3 (2.6.32-279.el6.x86_64) I found nfsv4 doesn't manage a file
>>> modified on the server side (even with the noac mount option) while
>>> nfsv3 does.
>>>
>>> My test will be modifying a file every second on the server mount point:
>>>
>>> [root@nfs ~]#  FILE=/tmp/nfs_server/myfile ;  while true ; do sleep 1 ;
>>> sed -i 's/text1/text2/g' $FILE ; cat $FILE ; sleep 1; sed -i
>>> 's/text2/text1/g' $FILE ; cat $FILE ; done
>>> text2
>>> text1
>>> text2
>>> text1
>>> text2
>>> (and so on...)
>>>
>>> Meanwhile, the client (which BTW is the same machine) will read the file
>>> every second :
>>>
>>> With NFSv4:
>>>
>>> [root@nfs ~]# mount -o noac,vers=4 nfs:/tmp/nfs_server/ /tmp/nfs_client/
>>> [root@nfs ~]# for i in 1 2 3 4 5 ; do cat /tmp/nfs_client/myfile; sleep
>>> 1 ; done
>>> text2
>>> text1
>>> text1
>>> text1
>>> text1
>>>
>>> With NFSv3:
>>> [root@nfs ~]# mount -o noac,vers=3 nfs:/tmp/nfs_server/ /tmp/nfs_client/
>>> [root@nfs ~]# for i in 1 2 3 4 5 ; do cat /tmp/nfs_client/myfile; sleep
>>> 1 ; done
>>> text1
>>> text2
>>> text1
>>> text2
>>> text1
>>>
>>> I can see in the tcpdump traces how the new change attribute and the
>>> FATTR4_TIME_MODIFY attributes are well received but it's as if the nfs
>>> client were ignoring these changes. I've been searching in the NFS list
>>> but I didn't find anything similar. Is this a bug or just a normal
>>> behavior? Sorry if it has been already pointed out.
>>
>> ]If you can reproduce the same issues on the upstream kernel, then it is
>> on topic for this list, otherwise it is a question for Red Hat.
>
> I believe sed -i is actually doing a rename not a file modification.  So
> the problem is likely another symptom of the bug that delegations aren't
> revoked on rename/link/unlink.  Hoping to post the latest draft of
> patches to fix that later today.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


