Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:34424 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab2BWHKE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 02:10:04 -0500
Message-ID: <4F45E63B.9090608@steve-ss.com>
Date: Thu, 23 Feb 2012 08:09:47 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Peter Horvath <peter.horvath77@googlemail.com>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 client restriction
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com> <20120223010111.GA19432@fieldses.org>
In-Reply-To: <20120223010111.GA19432@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/23/2012 02:01 AM, J. Bruce Fields wrote:
> On Wed, Feb 22, 2012 at 07:24:12PM +0000, Peter Horvath wrote:
>> We are using Ubuntu LTS 10.04 servers and clients.
>> NFS version is the following:
>> nfs-common                     1.2.0-4ubuntu4.2
>> nfs-kernel-server               1.2.0-4ubuntu4.2
>>
>> My exports looks like this:
>>
>> /srv 10.66.3.0/24(fsid=0,ro,no_subtree_check,sync)
>> /srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
>> /srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
>> /srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)
>>
>> My problem is that in this case clients have only read-only access. If
>> i set the pseudofilesystem root to RW it is working but in that case
>> all the clients would be able to mount the root and access other
>> projects too.
>> How can i achieve the same results as it was in NFSv3 with this config.
>>
>> /srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
>> /srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
>> /srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)
> Are project1, 2, 3 on the same filesystem as /srv and /srv/www?
>
> If so, this is expected; create a separate partition for /srv/www, or
> for each project1, 2, 3 directory, and you may find the problem is
> fixed.
>
> If that doesn't fix the problem, it may be a bug.  We've fixed a few
> bugs in that area lately, so it would be worth retrying with more recent
> kernel and nfs-utils.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

It is not recommended to use the pseudoroot fsid=0 stuff for Linux.

See the nfs wiki: 'The linux implementation allows you to designate a 
real filesystem as the pseudofilesystem, identifying that export with 
the fsid=0 option; we no longer recommend this. Instead, on any recent 
linux distribution, just list exports in /etc/exports exactly as you 
would for NFSv2 or NFSv3.'

HTH
Steve

