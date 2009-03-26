From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2.4] CAP_FS_MASK: add CAP_LINUX_IMMUTABLE and CAP_MKNOD
Date: Thu, 26 Mar 2009 06:29:58 +0100
Message-ID: <20090326052958.GC13146@1wt.eu>
References: <20090325173954.GA19299@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mtk.manpages@gmail.com, Stephen Smalley <sds-FVV4AS6k8l2W8mdqIt43Ew@public.gmane.org>,
	Andrew Morgan <morgan@kernel.org>,
	linux-security-module@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Igor Zhbanov <izh1979@gmail.com>, stable@kernel.org,
	linux-api@vger.kernel.org, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-api-owner@vger.kernel.org>
In-Reply-To: <20090325173954.GA19299@us.ibm.com>
Sender: linux-api-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Wed, Mar 25, 2009 at 12:39:54PM -0500, Serge E. Hallyn wrote:
> When POSIX capabilities were introduced during the 2.1 Linux
> cycle, the fs mask, which represents the capabilities which having
> fsuid==0 is supposed to grant, did not include CAP_MKNOD and
> CAP_LINUX_IMMUTABLE.  However, before capabilities the privilege
> to call these did in fact depend upon fsuid==0.
> 
> This patch introduces those capabilities into the fsmask,
> restoring the old behavior.
> 
> See the thread starting at http://lkml.org/lkml/2009/3/11/157 for
> reference.

Thanks to Igor and you for fixing this. The impact did not appear
obvious to me at first, to be honnest! I'm queuing the patch for
next release.

BTW, I've noticed your other patch for 2.2.26, but it's not worth
wasting time on it, as 2.2 has remained unmaintained for years now
and people are really discouraged from using it as many holes have
never been fixed there.

Cheers,
Willy

