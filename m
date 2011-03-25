Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58744 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab1CYN01 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 09:26:27 -0400
Subject: Re: [bisect] kernel 2.6.38 regression with root nfs mounting
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTin4-+Mc7d0a-XnZvPKL-C_Cf+Kmnm1Bmh1XZZu4@mail.gmail.com>
Date: Fri, 25 Mar 2011 09:26:17 -0400
Cc: Trond.Myklebust@netapp.com, broonie@opensource.wolfsonmicro.com,
        bdowning@lavos.net, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Message-Id: <4AD2FFC1-E777-4C29-8718-4E1717EFCD86@oracle.com>
References: <AANLkTimjmdi8sFTTjSPerOVgHQ+pjjwwMvCUX3AJ16At@mail.gmail.com> <43F07477-9075-444D-9BBB-368650538EA8@oracle.com> <AANLkTinHUQkBvcvh9APVutOqcKOug6CA066kS_O4p4Tq@mail.gmail.com> <DC2B75F8-382A-4AFB-9286-4A55EAF7609A@oracle.com> <AANLkTikWyUbtHbbnSh8NBeP3mT4jDOu5Pbtfw=TwKrwE@mail.gmail.com> <977C528D-4540-4EB2-92F9-6DAF357D8C81@oracle.com> <AANLkTik0UgB+k2i=E5t9XcF50SoSr_iXaFYrhctDx0FJ@mail.gmail.com> <8F19F0FE-0800-4C45-B857-1C682CF6A30D@oracle.com> <AANLkTin4-+Mc7d0a-XnZvPKL-C_Cf+Kmnm1Bmh1XZZu4@mail.gmail.com>
To: Belisko Marek <marek.belisko@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 25, 2011, at 3:24 AM, Belisko Marek wrote:

> On Wed, Mar 23, 2011 at 3:54 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Mar 23, 2011, at 10:30 AM, Belisko Marek wrote:
>> 
>> The server is advertising NFS over UDP.  Why can't a client access your server via UDP?  What happens if you perform a normal post-boot mount of this file system via UDP?
> Strange (rootfs mounted from SD card and try to mount nfs always fail)
> 
> mount -t nfs -o udp 10.146.1.21:/home/open-nandra/rootfs /mnt
> svc: failed to register lockdv1 RPC service (errno 111).
> lockd_up: makesock failed, error=-111
> mount: mounting 10.146.1.21:/home/open-nandra/rootfs on /mnt failed:
> Connection refused
> # mount -t nfs -o tcp 10.146.1.21:/home/open-nandra/rootfs /mnt
> svc: failed to register lockdv1 RPC service (errno 111).
> mount: mounting 10.146.1.21:/home/open-nandra/rootfs on /mnt failed:
> Connection refused

The client system isn't running a portmapper that its NFS client (specifically lockd) can talk to.  That "connection refused" is due to an incorrect client configuration.  A simple workaround might be to specify the "nolock" mount option for this test.

> 
>> 
>>>>>    100227    2   udp   2049
>>>>>    100227    3   udp   2049
>>>>>    100005    1   udp  58278  mountd
>>>>>    100005    1   tcp  37178  mountd
>>>>>    100005    2   udp  58278  mountd
>>>>>    100005    2   tcp  37178  mountd
>>>>>    100005    3   udp  58278  mountd
>>>>>    100005    3   tcp  37178  mountd
>>>> 
>>>> Can you boot if you specify either the "tcp" or "proto=tcp" NFSROOT mount options?
>>> When add proto=tcp to bootargs it boot fine
>>> (....nfsroot=10.146.1.21:/home/open-nandra/rootfs,proto=tcp....).
>>>> Perhaps a network trace would be probative.  Capture on the server with "tcpdump -s0 -w /tmp/foo ip 10.146.1.199" (untested, but I think you get the idea) while the client is attempting to boot, and post.
>>> Log is attached in attachment (too big 4.8M). Correct form is: tcpdump
>>> -s0 -w /tmp/foo host 10.146.1.199
>> 
>> Received.  I should have been clear: Please capture a non-working client boot attempt.  To reduce the size of the attachment, strip the TFTP packets before sending, and please gzip the file.
> tcpdump log from wrong attemp in attachment.

According to the trace, the mount succeeds, and NFS requests are working.  However, the server's replies to READ requests are not being seen by the client.  Something on the client host or in the network is dropping them.  I see successful 16KB reads, but 32KB reads do not work.  Check your client for packet filtering (either intentional filtering, or accidental filtering due to configuration issues).

I'll revisit the mount option defaults for NFSROOT again.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




