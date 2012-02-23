Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:53242 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753818Ab2BWBYh convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 20:24:37 -0500
Received: by lagu2 with SMTP id u2so807462lag.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2012 17:24:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120223010111.GA19432@fieldses.org>
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com>
	<20120223010111.GA19432@fieldses.org>
Date: Thu, 23 Feb 2012 01:24:35 +0000
Message-ID: <CAO9xhuZhtC8nWOhLjqG0iBRyvVN4ap7XqeD=hYHRR_29LBZpGA@mail.gmail.com>
Subject: Re: NFSv4 client restriction
From: Peter Horvath <peter.horvath77@googlemail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is a vmware RDM disk mounted /srv
It is the same filesystem.
Do you say this config would work if i use separate partition for the
separate directories?

On 23 February 2012 01:01, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Feb 22, 2012 at 07:24:12PM +0000, Peter Horvath wrote:
>> We are using Ubuntu LTS 10.04 servers and clients.
>> NFS version is the following:
>> nfs-common                     1.2.0-4ubuntu4.2
>> nfs-kernel-server               1.2.0-4ubuntu4.2
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
>
> Are project1, 2, 3 on the same filesystem as /srv and /srv/www?
>
> If so, this is expected; create a separate partition for /srv/www, or
> for each project1, 2, 3 directory, and you may find the problem is
> fixed.
>
> If that doesn't fix the problem, it may be a bug.  We've fixed a few
> bugs in that area lately, so it would be worth retrying with more recent
> kernel and nfs-utils.
>
> --b.
