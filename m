Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358AbbBYQRT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Feb 2015 11:17:19 -0500
Message-ID: <54EDECF2.5090000@RedHat.com>
Date: Wed, 25 Feb 2015 10:40:34 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: svilen dobrev <az@svilendobrev.com>, linux-nfs@vger.kernel.org
Subject: Re: rpc-statd won't start for user NFS mounts
References: <54D3704C.6010305@googlemail.com> <loom.20150219T110245-75@post.gmane.org>
In-Reply-To: <loom.20150219T110245-75@post.gmane.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/19/2015 05:09 AM, svilen dobrev wrote:
> Tobias Powalowski <tobias.powalowski@...> writes:
> 
>>
>> Hi,
>> https://bugs.archlinux.org/task/42491
>> This one I can reproduce, doing NFS3 user,noauto setting in fstab makes
>> it impossible to mount it as user.
>> - The systemd service nfs-client.target is loaded.
>> - rpcbind comes up by doing the mount
>> - rpc-statd is not coming up because of authentification error.
>> Failed to start rpc-statd.service: Interactive authentication required.
>> What is the correct way to solve this?
>>
>> Thanks for your answer.
>> greetings
>> tpowa
>  
> i stepped on this after upgrade today.. (and it's nfs4).
> i get these in journalctl -xe:
> .. rpc.statd[686]: Opening /var/run/rpc.statd.pid failed: Permission denied
> then i tried $ sudo touch /var/run/rpc.statd.pid
> and then mount suddenly works.
> 
> if that workaround gives any clue..
Is this an SELinux issue?

steved.
