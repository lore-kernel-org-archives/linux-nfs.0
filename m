Return-Path: linux-nfs-owner@vger.kernel.org
Received: from b.mx.filmlight.ltd.uk ([77.107.81.251]:10840 "HELO
	b.mx.filmlight.ltd.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932545AbaFCNJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 09:09:46 -0400
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
From: Roger Willcocks <roger@filmlight.ltd.uk>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Nicolas Pitre <nicolas.pitre@linaro.org>,
        linux-arch@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        LKML Kernel <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>, john.stultz@linaro.org,
        lftan@altera.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        geert@linux-m68k.org, tglx@linutronix.de, joseph@codesourcery.com
In-Reply-To: <20140602233212.GA2060@thunk.org>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
	 <8618458.1EVJCoVbkH@wuerfel>
	 <alpine.LFD.2.11.1406012121430.17310@knanqh.ubzr>
	 <4178301.j9kWdGCRLC@wuerfel>
	 <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
	 <20140602153124.GH30598@thunk.org> <538CB085.5000502@zytor.com>
	 <20140602222954.GA29690@thunk.org> <538CFB83.20703@zytor.com>
	 <20140602233212.GA2060@thunk.org>
Content-Type: text/plain
Date: Tue, 03 Jun 2014 14:09:43 +0100
Message-Id: <1401800983.6065.272.camel@montana.filmlight.ltd.uk>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2014-06-02 at 19:32 -0400, Theodore Ts'o wrote:

> Linux's time(2) can return (time_t) -1 and set errno to EFAULT, per
> the Posix specification:
> 
> SYSCALL_DEFINE1(time, time_t __user *, tloc)
> {
> 	time_t i = get_seconds();
> 
> 	if (tloc) {
> 		if (put_user(i,tloc))
> 			return -EFAULT;
> 	}
> 	force_successful_syscall_return();
> 	return i;
> }

get_seconds() returns an unsigned long so there's potential for overflow
here.

--
Roger



