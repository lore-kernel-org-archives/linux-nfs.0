From: Yudong Gao <stgyd@umich.edu>
Subject: Re: config delegation lease time
Date: Mon, 26 Jul 2010 10:36:03 -0700
Message-ID: <AANLkTincaDK0nbGV6aroNo00+Di3mzKYf=5rd2mLbTqB@mail.gmail.com>
References: <AANLkTikMa7FzBewHyZ=7Pxrf=EmKU3jb8y9hrO+QhfWd@mail.gmail.com>
	<1279935504.5268.23.camel@heimdal.trondhjem.org> <AANLkTikb+8LuFFDrSW5AE+ZKYuR_tP94wKb5UoJHiwro@mail.gmail.com>
	<1280165225.2869.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54106 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab0GZRgZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 13:36:25 -0400
Received: by vws3 with SMTP id 3so2619863vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jul 2010 10:36:24 -0700 (PDT)
In-Reply-To: <1280165225.2869.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see. I will look into the source code.

Thanks again!

best,

Yudong

On Mon, Jul 26, 2010 at 10:27 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> That would be the source code. I'm not aware of any other documentati=
on
> for these particular options.
>
> Cheers
> =A0Trond
>
> On Mon, 2010-07-26 at 10:14 -0700, Yudong Gao wrote:
>> I see. Thanks a lot for the pointer, Trond!
>>
>> Is there a through document about all the available configurations?
>>
>> Thanks!
>>
>> best,
>>
>> Yudong
>>
>> On Fri, Jul 23, 2010 at 6:38 PM, Trond Myklebust
>> <trond.myklebust@fys.uio.no> wrote:
>> > On Fri, 2010-07-23 at 17:29 -0700, Yudong Gao wrote:
>> >> Hi,
>> >>
>> >> I am trying to change the delegation lease time in NFS4.1, but I =
can
>> >> not find any documentation talking about this.
>> >>
>> >> Do I need to change the source code directly to change the lease =
time?
>> >
>> > Change the contents of /proc/fs/nfsd/nfsv4leasetime on the server.
>> >
>> > Trond
>> >
>> >
>
>
>
>
