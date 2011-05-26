Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63662 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757892Ab1EZS53 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 14:57:29 -0400
Received: by iyb14 with SMTP id 14so840732iyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2011 11:57:29 -0700 (PDT)
In-Reply-To: <CCEDE6F7-12A9-4308-A178-873FD972994C@oracle.com>
References: <7C481A0A0BBE9E4BA110F26D7A2BFFDC026E7C46@nodmx01.igglobal.com>
	<BANLkTikzuTGgHU=oUMTjmPhfsR_-nD5Ffw@mail.gmail.com>
	<BANLkTi=s4_A-WiG_a11pLgmeQ39qw=22Hg@mail.gmail.com>
	<CCEDE6F7-12A9-4308-A178-873FD972994C@oracle.com>
Date: Fri, 27 May 2011 00:27:28 +0530
Message-ID: <BANLkTi=_kAOipcotAH+vP-nHMebkrQqR7Q@mail.gmail.com>
Subject: Re: IPv6 support for NFSv2 server.
From: Upakul Barkakaty <upakul@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Chuck,

Thanks for writing in. I am using the command line option -o vers=2.

These 2 commands return different errors:

mount -o vers=2 <ipv6-address>:<path> --> mount.nfs: an incorrect
mount option was specified
mount <ipv6-address>:<path> --> mount.nfs: system call failed

RHEL6 uses NFSv4 by default so the second command is expected to use NFSv4.

Both the above commands execute successfully in case of ipv4 addresses.

-- 
Regards,
Upakul Barkakaty

On Fri, May 27, 2011 at 12:06 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On May 26, 2011, at 2:27 PM, Upakul Barkakaty wrote:
>
>> Hi all,
>>
>> I have been contemplating about using an appropriate server that would
>> support NFSv2 over IPv6.
>>
>> RHEL5 doesn’t support IPv6 over NFS by default. I tried installing a
>> few libraries and patches but it doesn’t seem to be working out yet
>> due to some missing dependencies.
>>
>> RHEL6 *seems* to support just the NFS client over IPv6. Further it
>> seems to support only NFSv4 as it generates an error if I force the
>> NFS version to 2 in the mount options[mount.nfs: an incorrect mount
>> option was specified].
>
> NFSv2 over IPv6 should work on Linux clients.  I don't think I ever explicitly tested it, though, so there could be bugs.
>
> How are you "forcing" it?
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
>
