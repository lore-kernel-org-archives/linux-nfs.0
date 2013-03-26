Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:45593 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965221Ab3CZPXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Mar 2013 11:23:19 -0400
Message-ID: <5151BD5F.30607@itwm.fraunhofer.de>
Date: Tue, 26 Mar 2013 16:23:11 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Anand Avati <anand.avati@gmail.com>
CC: "Theodore Ts'o" <tytso@mit.edu>, "J. Bruce Fields" <bfields@fieldses.org>,
        sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
References: <20130213151455.GB17431@thunk.org> <20130213151953.GJ14195@fieldses.org> <20130213153654.GC17431@thunk.org> <20130213162059.GL14195@fieldses.org> <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com> <20130213222052.GD5938@thunk.org> <20130213224141.GU14195@fieldses.org> <20130213224720.GE5938@thunk.org> <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com> <20130213230511.GW14195@fieldses.org> <20130213234430.GF5938@thunk.org> <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
In-Reply-To: <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for my late reply, I had been rather busy.

On 02/14/2013 01:05 AM, Anand Avati wrote:
> On Wed, Feb 13, 2013 at 3:44 PM, Theodore Ts'o <tytso@mit.edu> wrote:
>>
>> I suspect this would seriously screw over Gluster, though, and this
>> wouldn't be a solution for NFSv3, since NFS needs long-lived directory
>> cookies, and not the short-lived cookies which is all POSIX/SuSv3
>> guarantees.
>>
>
> Actually this would work just fine with Gluster. Except in the case of

Would it really work perfectly? What about a server reboot in the middle 
of a readdir of a client?

> gluster-NFS, the native client is only acting like a router/proxy of
> syscalls to the backend system. A directory opened by an application will
> have a matching directory fd opened on ext4, and readdir from an app will
> be translated into readdir on the matching fd on ext4. So the
> app-on-glusterfs and glusterfsd-on-ext4 are essentially "moving in tandem".
> As long as the offs^H^H^H^H cookies do not overflow in the transformation,
> Gluster would not have a problem.
>
> However Gluster-NFS (and NFS in general, too) will break, as we
> opendir/closedir potentially on every request.

We don't have reached a conclusion so far, do we? What about the ioctl 
approach, but a bit differently? Would it work to specify the allowed 
upper bits for ext4 (for example 16 additional bit) and the remaining 
part for gluster? One of the mails had the calculation formula:

final_d_off = (ext4_d_off * MAX_SERVERS) + server_idx

But what is the value of MAX_SERVERS?


Cheers,
Bernd


