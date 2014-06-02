Return-Path: linux-nfs-owner@vger.kernel.org
Received: from imap.thunk.org ([74.207.234.97]:46687 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbaFBXch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 19:32:37 -0400
Date: Mon, 2 Jun 2014 19:32:12 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Arnd Bergmann <arnd@arndb.de>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Dave Chinner <david@fromorbit.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org,
        Christoph Hellwig <hch@infradead.org>, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs@oss.sgi.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
Message-ID: <20140602233212.GA2060@thunk.org>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <8618458.1EVJCoVbkH@wuerfel>
 <alpine.LFD.2.11.1406012121430.17310@knanqh.ubzr>
 <4178301.j9kWdGCRLC@wuerfel>
 <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
 <20140602153124.GH30598@thunk.org>
 <538CB085.5000502@zytor.com>
 <20140602222954.GA29690@thunk.org>
 <538CFB83.20703@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <538CFB83.20703@zytor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 02, 2014 at 03:32:35PM -0700, H. Peter Anvin wrote:
> On 06/02/2014 03:29 PM, Theodore Ts'o wrote:
> > 
> > And since we are already returning (time_t) -1 in some cases, we might
> > as well try to make things a bit more formal.
> > 
> 
> Are we?  I am not aware of *Linux* actually using that.

Linux's time(2) can return (time_t) -1 and set errno to EFAULT, per
the Posix specification:

SYSCALL_DEFINE1(time, time_t __user *, tloc)
{
	time_t i = get_seconds();

	if (tloc) {
		if (put_user(i,tloc))
			return -EFAULT;
	}
	force_successful_syscall_return();
	return i;
}

Cheers,

						- Ted
