From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Unexplained NFS mount hangs
Date: Mon, 13 Apr 2009 12:38:33 -0400
Message-ID: <77670947-2C2B-47B9-9D2D-6EA959376D6D@oracle.com>
References: <20090413092406.304d04fb@dstickney2> <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com> <1239639537.13583.41.camel@poledra.romunt.nl>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Daniel Stickney <dstickney-qmHQv/uhAgPQT0dZR+AlfA@public.gmane.org>, linux-nfs@vger.kernel.org
To: Rudy-unrZvr96G99ZxllGnIAdI14fjVReZ9Cy2LY78lusg7I@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:51702 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbZDMQj1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 12:39:27 -0400
In-Reply-To: <1239639537.13583.41.camel-K4PxneKOXN833zHHb4ZaM2ZHpeb/A1Y/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 13, 2009, at 12:18 PM, Rudy Zijlstra wrote:
> Op maandag 13-04-2009 om 12:12 uur [tijdzone -0400], schreef Chuck
> Lever:
>> On Apr 13, 2009, at 11:24 AM, Daniel Stickney wrote:
>>> Hi all,
>>>
>>> I am investigating some NFS mount hangs that we have started to see
>>> over the past month on some of our servers. The behavior is that the
>>> client mount hangs and needs to be manually unmounted (forcefully
>>> with 'umount -f') and remounted to make it work. There are about 85
>>> clients mounting a partition over NFS. About 50 of the clients are
>>> running Fedora Core 3 with kernel 2.6.11-1.27_FC3smp. Not one of
>>> these 50 has ever had this mount hang. The other 35 are CentOS 5.2
>>> with kernel 2.6.27 which was compiled from source. The mount hangs
>>> are inconsistent and so far I don't know how to trigger them on
>>> demand. The timing of the hangs as noted by the timestamp in /var/
>>> log/messages varies. Not all of the 35 CentOS clients have their
>>> mounts hang at the same time, and the NFS server continues operating
>>> apparently normally for all other clients. Normally maybe 5 clients
>>> have a mount hang per week, on different days, mostly different
>>> times. Now and then we might see a cluster of a few clien
>>> ts have their mounts hang at the same exact time, but this is not
>>> consistent. In /var/log/messages we see
>>>
>>> Apr 12 02:04:12 worker120 kernel: nfs: server broker101 not
>>> responding, still trying
>>
>> Are these NFS/UDP or NFS/TCP mounts?
>>
>> If you use a different kernel (say, 2.6.26) on the CentOS systems, do
>> the hangs go away?
>>
>
> Hi Chuck,
>
> In my case NFS/TCP.
>
> I have tried most 2.6.2x kernels, it may take a week or longer for  
> them
> to hang, but hang they do :(
>
> have been fighting with this one since at least 2.6.24, and probably
> 2.6.22
>
> The reader that was hanging last week, is running 2.6.26

If you run "netstat --ip" on a client that has a hanging NFS mount  
point, what does it show?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
