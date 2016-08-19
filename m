Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38773 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754146AbcHSVDv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 17:03:51 -0400
Received: by mail-wm0-f44.google.com with SMTP id o80so58134778wme.1
        for <linux-nfs@vger.kernel.org>; Fri, 19 Aug 2016 14:03:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdURgo0UB6961bZXkb-HV5P3wDT8hgHy=TcPRhA10GT2iw@mail.gmail.com>
References: <CAMuHMdU+j50GFT=DUWsx_dz1VJJ5zY2EVJi4cX4ZhVVLRMyjCA@mail.gmail.com>
 <CAGXu5jJ0OCR995Xu41SQvw2YQX-JUO5BhVyOuy0=wJ3Su07puw@mail.gmail.com> <CAMuHMdURgo0UB6961bZXkb-HV5P3wDT8hgHy=TcPRhA10GT2iw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 19 Aug 2016 14:03:02 -0700
Message-ID: <CAGXu5jKhm4tLS=hmXk1FQfTM+7YCR-O886yEeNziLE_9ECHokw@mail.gmail.com>
Subject: Re: usercopy: kernel memory exposure attempt detected
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux MM <linux-mm@kvack.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Rik van Riel <riel@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 17, 2016 at 8:14 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Hi Kees,
>
> On Wed, Aug 17, 2016 at 4:52 PM, Kees Cook <keescook@chromium.org> wrote:
>> On Wed, Aug 17, 2016 at 5:13 AM, Geert Uytterhoeven
>> <geert@linux-m68k.org> wrote:
>>> Saw this when using NFS root on r8a7791/koelsch, using a tree based on
>>> renesas-drivers-2016-08-16-v4.8-rc2:
>>>
>>> usercopy: kernel memory exposure attempt detected from c01ff000
>>> (<kernel text>) (4096 bytes)
>>
>> Hmmm, the kernel text exposure on ARM usually means the hardened
>> usercopy patchset was applied to an ARM tree without the _etext patch:
>> http://git.kernel.org/linus/14c4a533e0996f95a0a64dfd0b6252d788cebc74
>>
>> If you _do_ have this patch already (and based on the comment below, I
>> suspect you do: usually the missing _etext makes the system entirely
>> unbootable), then we need to dig further.
>
> Yes, I do have that patch.
>
>>> Despite the BUG(), the system continues working.
>>
>> I assume exim4 got killed, though?
>
> Possibly. I don't really use email on the development boards.
> Just a debootstrapped Debian NFS root.
>
>> If you can figure out what bytes are present at c01ff000, that may
>> give us a clue.
>
> I've added a print_hex_dump(), so we'll find out when it happens again...

Any news on this? If you still have it, I'd love to see the .config
and kernel image. I've still not been able to reproduce this.

-Kees

-- 
Kees Cook
Nexus Security
