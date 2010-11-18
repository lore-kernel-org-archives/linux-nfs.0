Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34185 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757777Ab0KRXeo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 18:34:44 -0500
Date: Fri, 19 Nov 2010 00:34:39 +0100
From: Jan Kara <jack@suse.cz>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Nathan Laredo <laredo@gnu.org>,
        Greg Kroah-Hartman <gregkh@suse.de>, Dave Airlie <airlied@linux.ie>,
        dri-devel@lists.freedesktop.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Alessio Igor Bogani <alessioigorbogani@gmail.com>,
        Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/7] BKL removal follow-up
Message-ID: <20101118233439.GB5004@quack.suse.cz>
References: <1290007619-5787-1-git-send-email-arnd@arndb.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290007619-5787-1-git-send-email-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hi,

On Wed 17-11-10 16:26:52, Arnd Bergmann wrote:
> It seems the v4l and udf code has been worked out now and patches
> to kill the BKL there are finally making it upstream.
> 
> As promised, here are the patches I did since the kernel summit
> to turn off the BKL by default. Given that -rc2 is out now, I don't
> know how much of these you still want for 2.6.37, so just pick
> the ones you like and I'll send a pull request for the rest
> once the 2.6.38 merge window opens.
  Just for info, UDF BKL removal patches seem to work fine but I want to
give them some final SMP testing on Monday before pushing them to -next.
I'm not sure how much people hurry with disabling the lock so if I should
push them ASAP or whether the next merge window is fine...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
