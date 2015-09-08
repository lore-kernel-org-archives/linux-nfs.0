Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:51021 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752571AbbIHB7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Sep 2015 21:59:02 -0400
Date: Tue, 8 Sep 2015 11:59:00 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, Doug Ledford <dledford@redhat.com>
Subject: Re: [GIT PULL] Please pull NFS client changes
Message-ID: <20150908115900.4182d55a@canb.auug.org.au>
In-Reply-To: <1441659544.3163.4.camel@primarydata.com>
References: <1441659544.3163.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

On Mon, 07 Sep 2015 16:59:04 -0400 Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
> The following changes since commit 74d33293e467df61de1b1d8b2fbe29e550dec33b:
> 
>   Linux 4.2-rc5 (2015-08-02 18:34:55 -0700)
> 
> are available in the git repository at:
> 
>   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.3-1
> 
> for you to fetch changes up to 5445b1fbd123420bffed5e629a420aa2a16bf849:
> 
>   NFSv4: Respect the server imposed limit on how many changes we may cache (2015-09-07 12:36:17 -0400)

This contains about 12 commits new since Sept 1 and the last 6 are only
appearing in linux-next today (though I did not do Friday and Monday's
linux-next).  Not judging, just noting.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
