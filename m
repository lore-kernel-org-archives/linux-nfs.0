Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56266 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab1KHEdi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 23:33:38 -0500
Received: by ggnb2 with SMTP id b2so121024ggn.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Nov 2011 20:33:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1617B125-3EFF-42EB-8F1B-A1D57E6ADC12@oracle.com>
References: <CAO_0yfP8XRH0+Gdn43QSncUFFPPmwbsxx2ZFdPpFTjKAQeuyAw@mail.gmail.com>
 <1617B125-3EFF-42EB-8F1B-A1D57E6ADC12@oracle.com>
From: Hamo <hamo.by@gmail.com>
Date: Tue, 8 Nov 2011 12:33:17 +0800
Message-ID: <CAO_0yfPOmVdoBOgXOaBDO5QsJyzX+5-8+cnEhKgYUp7eOkqZ1g@mail.gmail.com>
Subject: Re: [PATCH] mount.nfs: ensure AF priority when mounting
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, jlayton@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 8, 2011 at 12:01 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Nov 7, 2011, at 10:14 PM, Hamo wrote:
>
>> On different architectures, getaddrinfo() may return different
>> orders of address families. This may confuse the users.
>> This patch fixes this problem by ensuring that we first try
>> through IPv6(if present), then through IPv4.
>> Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=750729
>
> By the way, this bug isn't public (I can't access it, anyway).  If RH can't make it public, perhaps a copy of the relevant parts of the bug can be created in bugzilla.linux-nfs.org?  Otherwise, it's hard to tell what you are trying to fix so we can do a thorough patch review.
>
> (Also, I'm not sure why you copied lkml and linux-fsdevel on this NFS-specific user space patch).
>

Hi Chuck,
added you in the CC list so that you can view this bug.
I miss-added those two mailing lists, thanks for pointing out this.

Thanks,
Yang
