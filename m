Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.17.24]:55760 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbaFBSwv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 14:52:51 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Chinner <david@fromorbit.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org,
        Christoph Hellwig <hch@infradead.org>, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs@oss.sgi.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
Date: Mon, 02 Jun 2014 20:52:43 +0200
Message-ID: <5109660.teHoOW5tSd@wuerfel>
In-Reply-To: <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <4178301.j9kWdGCRLC@wuerfel> <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 02 June 2014 11:04:23 Chuck Lever wrote:
> I’m wondering what should be done about NFS. A solution for NFS should
> match any scheme that is considered for local file systems, IMO.
> 
> NFSv2/3 timestamps are a pair of unsigned 32-bit values: one value for
> seconds since midnight GMT Jan 1, 1970, and one value for nanoseconds.
> (See the definition of nfstime3 in RFC 1813).
> 
> NFSv4 uses a signed 64-bit value where zero represents midnight UTC
> on January 1, 1970, and an unsigned 32-bit value for nanoseconds. (See
> the definition of nfstime4 in RFC 5661).
> 
> The NFSv4 protocol is probably not problematic, and NFSv3 should be out
> of the picture by 2038. But if changes are planned for dealing _now_
> with timestamp issues, compatibility with NFSv3 is a consideration.
> 
> It is already the case that, via NFSv3, the Linux NFS client transmits
> timestamps earlier than 1970 as large positive numbers. Try this with
> xfstests generic/258.

If I read the code correctly, a pre-1970 timestamp will be sent as
a large unsigned integer, but received as a post-2038 timestamp on
64-bit kernels, both in the nfs client and server code.

This behavior is clearly wrong, but it's the same bug that we have
in lots of other file systems, and it makes sense to have the
same fix everywhere, at lease the cases where we know what interpretation
we actually want. NFS has the luxury of having an actual specification
saying that the value is unsigned. For most of the legacy file systems,
we can only make a guess at how other OSs would interpret the same
numbers.

	Arnd
