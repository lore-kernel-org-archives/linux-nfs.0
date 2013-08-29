Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f41.google.com ([209.85.212.41]:48708 "EHLO
	mail-vb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab3H2J5q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Aug 2013 05:57:46 -0400
MIME-Version: 1.0
In-Reply-To: <521E318C.7040401@gmx.de>
References: <52075E01.7030506@gmx.de>
	<20130812143640.GF4596@quack.suse.cz>
	<20130813215313.GH17781@fieldses.org>
	<20130827180655.GE14809@fieldses.org>
	<521E318C.7040401@gmx.de>
Date: Thu, 29 Aug 2013 11:57:45 +0200
Message-ID: <CAFLxGvyK5+nB9TgW1uPho9KGwQrWQHx=wEpj+o-mZcN92bWAOg@mail.gmail.com>
Subject: Re: [uml-devel] Issues with a rather unusual configured NFS server
From: richard -rw- weinberger <richard.weinberger@gmail.com>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "user-mode-linux-devel@lists.sourceforge.net"
	<user-mode-linux-devel@lists.sourceforge.net>,
        Linux Kernel <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 28, 2013 at 7:21 PM, Toralf Förster <toralf.foerster@gmx.de> wrote:
> On 08/27/2013 08:06 PM, J. Bruce Fields wrote:
>> On Tue, Aug 13, 2013 at 05:53:14PM -0400, bfields wrote:
>>> On Mon, Aug 12, 2013 at 04:36:40PM +0200, Jan Kara wrote:
>>>> On Sun 11-08-13 11:48:49, Toralf Förster wrote:
>>>>> so that the server either crashes (if it is a user mode linux image) or at least its reboot functionality got broken
>>>>> - if the NFS server is hammered with scary NFS calls using a fuzzy tool running at a remote NFS client under a non-privileged user id.
>>>>>
>>>>> It can re reproduced, if
>>>>>    - the NFS share is an EXT3 or EXT4 directory
>>>>>    - and it is created at file located at tempfs and mounted via loop device
>>>>>    - and the NFS server is forced to umount the NFS share
>>>>>    - and the server forced to restart the NSF service afterwards
>>>>>    - and trinity is used
>>>>>
>>>>> I could find a scenario for an automated bisect. 2 times it brought this commit
>>>>> commit 68a3396178e6688ad7367202cdf0af8ed03c8727
>>>>> Author: J. Bruce Fields <bfields@redhat.com>
>>>>> Date:   Thu Mar 21 11:21:50 2013 -0400
>>>>>
>>>>>     nfsd4: shut down more of delegation earlier
>>>
>>> Thanks for the report.  I think I see the problem--after this commit
>>> nfs4_set_delegation() failures result in nfs4_put_delegation being
>>> called, but nfs4_put_delegation doesn't free the nfs4_file that has
>>> already been set by alloc_init_deleg().
>>>
>>> Let me think about how to fix that....
>>
>> Sorry for the slow response--can you check whether this fixes the
>> problem?
>>
> Yes.
>
> With the attached patch the problem can't be reproduced any longer with
> the prepared test case and current git kernels.

BTW: Is nobody else fuzz testing NFS?
Or are these bugs just more likely to hit on UML?
This is not the first NFS issue found by Toralf using UML and Trinity.

-- 
Thanks,
//richard
