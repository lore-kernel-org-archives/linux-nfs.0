Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:47531 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab2KFMLP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Nov 2012 07:11:15 -0500
Message-ID: <5098FE5F.7030709@parallels.com>
Date: Tue, 6 Nov 2012 16:11:11 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before connecting
 local transports
References: <20121008105437.18668.99905.stgit@localhost.localdomain> <20121009193506.GA19680@fieldses.org> <5098E31A.5080801@parallels.com> <20121106120642.GA6718@fieldses.org>
In-Reply-To: <20121106120642.GA6718@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

06.11.2012 16:06, J. Bruce Fields пишет:
> On Tue, Nov 06, 2012 at 02:14:50PM +0400, Stanislav Kinsbursky wrote:
>> 09.10.2012 23:35, J. Bruce Fields пишет:
>>> Cc'ing Eric since I seem to recall he suggested doing it this way?
>>>
>>> Seems OK to me, but maybe that swap_root should be in common code?  (Or
>>> maybe we could use set_fs_root()?)
>>>
>>
>> This patch is not good since, as Eric mentioned, all kernel threads
>> share same fs struct.
>> We can swap whole fs struct. Or we can unshare fs struct
>> (unshare_fs_struct() is exported) and swap root in this case.
>> But this approach is to close to set_fs_root() logic, which is not
>> exported and seems there are some valid reasons for it.
>
> What are those reasons?
>

I don't know them.
Trond told, that Al doesn't like the idea of set_fs_root() exporting.

> Googling found one previous thread:
>
> 	http://thread.gmane.org/gmane.linux.kernel/1259986/focus=47687
>
> There Trond requests an ACK from Al or Cristoph for the export, but I
> don't see either an ACK or any objection.
>

Cristoph told me on LSF something line "No ... way", when I asked him about 
set_fs_root() exporting.
But I had no opportunity to ask why.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
