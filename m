Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34785 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbH1WGY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2015 18:06:24 -0400
MIME-Version: 1.0
In-Reply-To: <20150828214917.GC23326@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
	<1438689218-6921-11-git-send-email-agruenba@redhat.com>
	<20150828214917.GC23326@fieldses.org>
Date: Sat, 29 Aug 2015 00:06:22 +0200
Message-ID: <CAHpGcMJT0kQyrvCkur0csCmRn-LwUOJcRWqAfLaqCpNd2b8UXA@mail.gmail.com>
Subject: Re: [RFC v6 10/40] richacl: Permission check algorithm
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        LSM List <linux-security-module@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-08-28 23:49 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Tue, Aug 04, 2015 at 01:53:08PM +0200, Andreas Gruenbacher wrote:
>> +             /*
>> +              * We don't care which class the process is in when the acl is
>> +              * not masked.
>> +              */
>> +             in_owner_or_group_class = 1;
>
> So why bother setting it at all, then?  Oh, I see, it lets you break out
> of the loop below earlier.  OK.

Comment changed to:

                /*
                 * When the acl is not masked, there is no need to determine if
                 * the process is in the group class and we can earlier break
                 * out of the loop below.
                 */

> Patch makes sense to me, ACK.

Thanks,
Andreas
