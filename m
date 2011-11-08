Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43099 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab1KHEvm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 23:51:42 -0500
Received: by ywf7 with SMTP id 7so133401ywf.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Nov 2011 20:51:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4A9C7673-1CC1-4B8E-AF18-4DA39A14BCB7@oracle.com>
References: <CAO_0yfP8XRH0+Gdn43QSncUFFPPmwbsxx2ZFdPpFTjKAQeuyAw@mail.gmail.com>
 <4A9C7673-1CC1-4B8E-AF18-4DA39A14BCB7@oracle.com>
From: Hamo <hamo.by@gmail.com>
Date: Tue, 8 Nov 2011 12:51:21 +0800
Message-ID: <CAO_0yfM4ozPUCw0qvxrA3Z18cJaq9WiEZgWNhrf8wLee8baT8g@mail.gmail.com>
Subject: Re: [PATCH] mount.nfs: ensure AF priority when mounting
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, jlayton@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 8, 2011 at 11:57 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Nov 7, 2011, at 10:14 PM, Hamo wrote:
>
>> On different architectures, getaddrinfo() may return different
>> orders of address families. This may confuse the users.
>
> Isn't this controlled by /etc/gai.conf ?  I'm not sure we want mount.nfs to override that.
>

After digging into this file, I found the order can be controlled by
this file, but without it, the order is not predictable.
Should we first try IPv6 then IPv4? This sounds reasonable.
So now, I am also not sure should we override this. Waiting for the
opinions from others.
