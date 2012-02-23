Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43522 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab2BWKZR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 05:25:17 -0500
Received: by daed14 with SMTP id d14so1119975dae.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2012 02:25:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F45E63B.9090608@steve-ss.com>
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com>
	<20120223010111.GA19432@fieldses.org>
	<4F45E63B.9090608@steve-ss.com>
Date: Thu, 23 Feb 2012 10:25:16 +0000
Message-ID: <CAO9xhuatmaohbX05N6o6-GskW3Bot8aV2KvFT++DxeDAc9p=sQ@mail.gmail.com>
Subject: Re: NFSv4 client restriction
From: Peter Horvath <peter.horvath77@googlemail.com>
To: steve <steve@steve-ss.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On ubuntu 10.04 with the repository installs of the packages:
mount.nfs4 10.66.3.101:/srv/www/test /srv -v
mount.nfs4: timeout set for Thu Feb 23 10:24:10 2012
mount.nfs4: text-based options: 'clientaddr=10.66.3.102,addr=10.66.3.101'
mount.nfs4: mount(2): No such file or directory
mount.nfs4: mounting 10.66.3.101:/srv/www/test failed, reason given by server:
  No such file or directory

mount.nfs 10.66.3.101:/srv/www/test /srv -v
mount.nfs: timeout set for Thu Feb 23 10:24:32 2012
mount.nfs: text-based options: 'addr=10.66.3.101'
10.66.3.101:/srv/www/test on /srv type nfs

Which means i can mount with nfsv3 but i am not able to mount with
nfsv4 without fsid=0
I will try bruce idea with different partitions as shared directories.

Peter

On 23 February 2012 07:09, steve <steve@steve-ss.com> wrote:
> On 02/23/2012 02:01 AM, J. Bruce Fields wrote:
>>
>> On Wed, Feb 22, 2012 at 07:24:12PM +0000, Peter Horvath wrote:
>>>
>>> We are using Ubuntu LTS 10.04 servers and clients.
>>> NFS version is the following:
>>> nfs-common                     1.2.0-4ubuntu4.2
>>> nfs-kernel-server               1.2.0-4ubuntu4.2
>>>
>>> My exports looks like this:
>>>
>>> /srv 10.66.3.0/24(fsid=0,ro,no_subtree_check,sync)
>>> /srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
>>> /srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
>>> /srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)
>>>
>>> My problem is that in this case clients have only read-only access. If
>>> i set the pseudofilesystem root to RW it is working but in that case
>>> all the clients would be able to mount the root and access other
>>> projects too.
>>> How can i achieve the same results as it was in NFSv3 with this config.
>>>
>>> /srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
>>> /srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
>>> /srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)
>>
>> Are project1, 2, 3 on the same filesystem as /srv and /srv/www?
>>
>> If so, this is expected; create a separate partition for /srv/www, or
>> for each project1, 2, 3 directory, and you may find the problem is
>> fixed.
>>
>> If that doesn't fix the problem, it may be a bug.  We've fixed a few
>> bugs in that area lately, so it would be worth retrying with more recent
>> kernel and nfs-utils.
>>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> It is not recommended to use the pseudoroot fsid=0 stuff for Linux.
>
> See the nfs wiki: 'The linux implementation allows you to designate a real
> filesystem as the pseudofilesystem, identifying that export with the fsid=0
> option; we no longer recommend this. Instead, on any recent linux
> distribution, just list exports in /etc/exports exactly as you would for
> NFSv2 or NFSv3.'
>
> HTH
> Steve
>
