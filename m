Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp10.mail.sp.isp-net.nl ([217.149.192.65]:48534 "EHLO
	smtp10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab2FCPAm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jun 2012 11:00:42 -0400
Message-ID: <4FCB7C11.7070300@xmsnet.nl>
Date: Sun, 03 Jun 2012 17:00:33 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: Re: nfsroot client will not start firefox or thunderbird from 3.4.0
 nfsserver
References: <4FC3F9F6.7010107@xmsnet.nl> <4FC913FC.2020401@xmsnet.nl>
In-Reply-To: <4FC913FC.2020401@xmsnet.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2012 09:11 PM, Hans de Bruin wrote:
> On 05/29/2012 12:19 AM, Hans de Bruin wrote:
>> I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into
>> some trouble. My laptop, a nfsroot client, will not run firefox and
>> thunderbird anymore. When I start these programs from an xterm, the
>> cursor goes to the next line and waits indefinitely.
>>
>> I do not know if there is any order is lsof's output. A lsof | grep
>> firefox or thunderbird shows ......./.parentlock as the last line.
>>
>> It does not matter whether the client is running a 3.4.0 or a 3.3.0
>> kernel, or if the server is running on top of xen or not.
>>
>> There is some noise in the servers dmesg:
>>
>> [ 241.256684] INFO: task kworker/u:2:801 blocked for more than 120
>> seconds.
>> [ 241.256691] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>
> ...
>
> On a almost identical testsystem firefox en thunderbird segfault after
> upgrading to 3.4.0. I would have been nice if it would behave exaclty
> like my home server. I bisected the segfault to:
>
> commit 0fc9d1040313047edf6a39fd4d7c7defdca97c62
> Author: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Date: Wed Mar 28 14:42:54 2012 -0700
>
> radix-tree: use iterators in find_get_pages* functions
>
>
> When I revert that on top of 3.4.0 the segfaults are gone but both
> firefox en thunderbird go in the lets wait indefinitely mode like the
> homeserver.
>
> I am going to make a bit-wise copy from from my homeserver to my
> testserver and try again.
>

The bit-wise copy also segfaults firefox and thunderbird at the same 
commit.

-- 
Hans
