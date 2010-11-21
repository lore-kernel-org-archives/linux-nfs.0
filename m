Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46489 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754645Ab0KURxw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Nov 2010 12:53:52 -0500
In-Reply-To: <4CE928DD.2010309@gmail.com>
References: <1290007619-5787-1-git-send-email-arnd@arndb.de>
 <20101118233439.GB5004@quack.suse.cz> <AANLkTin0Gm8Xqm-ARGmd4T+fCM4mMA0=PbDA6eSsYUOG@mail.gmail.com>
 <4CE928DD.2010309@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 21 Nov 2010 09:45:12 -0800
Message-ID: <AANLkTi=qvOHwgsbaCO6_Eu2Uik7MP5=C64+WW8R-RR8B@mail.gmail.com>
Subject: Re: [PATCH 0/7] BKL removal follow-up
To: Boaz Harrosh <openosd@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>,
        linux-kernel@vger.kernel.org, Nathan Laredo <laredo@gnu.org>,
        Greg Kroah-Hartman <gregkh@suse.de>, Dave Airlie <airlied@linux.ie>,
        dri-devel@lists.freedesktop.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Alessio Igor Bogani <alessioigorbogani@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 21, 2010 at 6:12 AM, Boaz Harrosh <openosd@gmail.com> wrote:
> On 11/19/2010 01:40 AM, Linus Torvalds wrote:
>>
>> I don't think I can reasonably do it in 37, we're late enough in the
>> -rc series. So UDF and really saying 'n' to BKL by default will have
>> to be for the next merge window.
>
> Could it not default to "n" but be SELECTed by the like of UDF. Or
> that too big of a Kconfig change for 37-rcX? I understand it does
> not really buy us anything for distro's with allmodconfig style,
> but it should help with defconfig on all the other ARCH's.

Yes, I'd be ok with UDF doing a "select BKL" along with a "default n"
for BKL itself.

I think UDF currently is the only sane reason to have BKL enabled any
more, and yes, it would probably make it easier to configure things.

Tested patch?

                       Linus
