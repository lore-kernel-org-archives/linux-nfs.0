Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63884 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab2HABw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2012 21:52:26 -0400
MIME-Version: 1.0
In-Reply-To: <20120727065630.0a3c5870@tlielax.poochiereds.net>
References: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
	<CAKYAXd99VMYSX=k9eadB6MZvjQjQrOngOjUicjo+c9LtHvpz9w@mail.gmail.com>
	<20120727065630.0a3c5870@tlielax.poochiereds.net>
Date: Wed, 1 Aug 2012 10:52:25 +0900
Message-ID: <CAKYAXd8Kbnp0paFt-FmaFiEu6KWX8jCyE7NZ-SHfEj4Ad5-ANA@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] vfs: add the ability to retry on ESTALE to
 several syscalls
From: Namjae Jeon <linkinjeon@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/7/27, Jeff Layton <jlayton@redhat.com>:
> On Fri, 27 Jul 2012 11:15:23 +0900
> Namjae Jeon <linkinjeon@gmail.com> wrote:
>
>> Hi Jeff.
>>
>> Which testcase(or test method) do I use to know improved point from
>> ESTALE error ?
>> I want to know before & after using testcase with this patch-set.
>>
>
> It's a bit labor intensive, I'm afraid...
>
> Attached is a cleaned-up copy of the test program that Peter wrote to
> test his original patchset. The basic idea is to run this on both the
> client and server at the same time so they race against each other. He
> was able to run it overnight when testing with his patchset.
>
> With this patchset, that doesn't work since we're only retrying the
> lookup and call once. So, what I've been doing is modifying the program
> so that it just runs one test at a time, and sniffing traffic to see
> whether the lookups and calls are retried after an ESTALE return from
> the server.
Sorry for late response.
I will check this patch with testcase you shared.
Thanks Jeff.

>
> --
> Jeff Layton <jlayton@redhat.com>
>
