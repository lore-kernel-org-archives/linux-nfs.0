Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50901 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab3GRO5o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 10:57:44 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so3285314pbc.15
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jul 2013 07:57:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374098384.17005.10.camel@leira.trondhjem.org>
References: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com>
	<A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com>
	<CAHsu+b9vWUyCGHSs==Na=VntwvYp65=rva7+y9aQDXquxX4t-A@mail.gmail.com>
	<1374098384.17005.10.camel@leira.trondhjem.org>
Date: Thu, 18 Jul 2013 16:57:43 +0200
Message-ID: <CAHsu+b_K-KL0gE4YaOYSCjAz3tKvVNeiGxQWsQ6ObY0Udp_Nyw@mail.gmail.com>
Subject: Re: Error writing to nfs4 with 3.11-rc1
From: Andre Heider <a.heider@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 17, 2013 at 11:59 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2013-07-17 at 21:35 +0200, Andre Heider wrote:
>> On Wed, Jul 17, 2013 at 9:10 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> >
>> > On Jul 17, 2013, at 2:55 PM, Andre Heider <a.heider@gmail.com> wrote:
>> >
>> >> Hi,
>> >>
>> >> I'm having problems using 3.11-rc1 as nfs4 client (with a FreeBSD 9.1
>> >> server) using sec=sys.
>> >>
>> >> With the same server+client setup, just booting different kernels:
>> >> 3.9.10 works without issues
>> >> 3.10.1 works too, but introduced "RPC: AUTH_GSS upcall timed out." in
>> >> dmesg (iirc I don't need gss with sec=sys)
>> >
>> > Not a requirement, but running gssd should make that message go away.  The client is attempting to use krb5i to manage its lease on the server, and falling back to AUTH_UNIX when it sees gssd is not running.
>> >
>> >> 3.11-rc1 reading from the server still works, writing fails
>> >>
>> >> Even a simple touch on the share fails with:
>> >> touch: cannot touch ‘/mnt/andre/test’: Input/output error
>> >
>> > A network capture is a reasonable place to start.
>> >
>> >   # tcpdump -s0 -w /tmp/raw
>> >
>> > Then try your touch test again.  Stop the tcpdump.  You can post a compressed version of the raw dump here if it's short.
>>
>> Attached two dumps, one from 3.10 (works) and one from 3.11 (doesn't work).
>
> The FreeBSD server is returning NFS4ERR_ATTRNOTSUPP to the OPEN, despite
> the fact that we're requesting the same attributes in both cases. I'll
> bet it is the fact that we send a bitmap of 3 words instead of 2.
>
> This is a problem: the Linux client clearly has the spec on its side,
> and the FreeBSD server is wrong to reject a 3 word bitmap, as long as
> we're not requesting any actual attributes that it doesn't support.
> According to the spec, we could send a bitmap of any length we like.
>
> On the other hand, we have a situation where something used to work, and
> now doesn't. Please check out the 2 patches I just sent out, and see if
> they help.

With these 2 patches, nfsv4 connectivity to a FreeBSD server is working again.

Thanks for the quick patches,
Andre
