Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48932 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755887Ab0KRXlf convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 18:41:35 -0500
In-Reply-To: <20101118233439.GB5004@quack.suse.cz>
References: <1290007619-5787-1-git-send-email-arnd@arndb.de> <20101118233439.GB5004@quack.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Nov 2010 15:40:56 -0800
Message-ID: <AANLkTin0Gm8Xqm-ARGmd4T+fCM4mMA0=PbDA6eSsYUOG@mail.gmail.com>
Subject: Re: [PATCH 0/7] BKL removal follow-up
To: Jan Kara <jack@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
        Nathan Laredo <laredo@gnu.org>, Greg Kroah-Hartman <gregkh@suse.de>,
        Dave Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Alessio Igor Bogani <alessioigorbogani@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 18, 2010 at 3:34 PM, Jan Kara <jack@suse.cz> wrote:
>
>  Just for info, UDF BKL removal patches seem to work fine but I want to
> give them some final SMP testing on Monday before pushing them to -next.
> I'm not sure how much people hurry with disabling the lock so if I should
> push them ASAP or whether the next merge window is fine...

I don't think I can reasonably do it in 37, we're late enough in the
-rc series. So UDF and really saying 'n' to BKL by default will have
to be for the next merge window.

I hate to do it, but I'd be too nervous about it any other way.

                   Linus
