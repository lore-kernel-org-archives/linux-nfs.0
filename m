Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759Ab1F0Qgc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 12:36:32 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5RGaVJj004803
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jun 2011 12:36:31 -0400
Message-ID: <4E08B18E.20104@RedHat.com>
Date: Mon, 27 Jun 2011 12:36:30 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] mountd: don't automatically add subexports to kernel
 cache
References: <1308063492-30103-1-git-send-email-bfields@redhat.com> <1308063492-30103-5-git-send-email-bfields@redhat.com> <4E026D08.5070309@RedHat.com> <20110622223412.GB7395@pad.home.fieldses.org>
In-Reply-To: <20110622223412.GB7395@pad.home.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/22/2011 06:34 PM, J. Bruce Fields wrote:
> On Wed, Jun 22, 2011 at 06:30:32PM -0400, Steve Dickson wrote:
>> Hey Bruce,
>>
>> This patch breaks cross mounts... Here is my set up
>>
>> /home/fs1 two different file systems:
>>
>> Filesystem           1K-blocks      Used Available Use% Mounted on
>> /dev/mapper/VolGroup00-HomeDirs
>>                       15236080   9439036   5010612  66% /home
>> RedHat# df /home/fs1
>> Filesystem           1K-blocks      Used Available Use% Mounted on
>> /dev/mapper/VolGroup00-FS1
>>                       10321208    154468   9642452   2% /home/fs1
>>
>> The export is:
>>   /home *(rw,crossmnt,nohide,sec=sys:krb5:krb5i:krb5p)
>>
>> when I mount from a f15 client
>>     mount -v -o v3 redhat:/home/fs1/tmp/tophat /mnt/tmp
>> I get:
>>     mount.nfs: mount(2): Stale NFS file handle
>>
>> When I revert the patch, the mount works.
> 
> Oh, crap, I didn't check v3.  And, OK, it makes sense that v3 might need
> this.
> 
>> Unfortunately I'm going to be taking the next few days off
>> so I am not going be able to debug this... So I'm going to 
>> wait on the entire patch series until we can sort this out...
> 
> No problem.  But if you want to apply the rest of the series and drop
> just this one patch, that would be fine too.  (That's probably what will
> end up being the fix anyway.)
Ok... I just committed the first three patches of this series...

steved.
