Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.126.131]:64161 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbaFBTLN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 15:11:13 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Roger Willcocks <roger@filmlight.ltd.uk>,
        Nicolas Pitre <nicolas.pitre@linaro.org>, linux-arch@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>, lftan@altera.com,
        Christoph Hellwig <hch@infradead.org>, john.stultz@linaro.org,
        "H. Peter Anvin" <hpa@zytor.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, geert@linux-m68k.org,
        tglx@linutronix.de, xfs@oss.sgi.com, joseph@codesourcery.com
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
Date: Mon, 02 Jun 2014 21:10:47 +0200
Message-ID: <5585593.Xe5bNQZW47@wuerfel>
In-Reply-To: <C57EA6CA-236A-4C93-95F8-21F46A3622DA@oracle.com>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <1401735504.6065.227.camel@montana.filmlight.ltd.uk> <C57EA6CA-236A-4C93-95F8-21F46A3622DA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 02 June 2014 15:04:27 Chuck Lever wrote:
> On Jun 2, 2014, at 2:58 PM, Roger Willcocks <roger@filmlight.ltd.uk> wrote:
> 
> > 
> > On Mon, 2014-06-02 at 11:04 -0400, Chuck Lever wrote:
> > 
> >> NFSv2/3 timestamps are a pair of unsigned 32-bit values: one value for
> >> seconds since midnight GMT Jan 1, 1970, and one value for nanoseconds.
> >> (See the definition of nfstime3 in RFC 1813).
> >> 
> > 
> > nfstime3 could be extended by redefining the otherwise unused
> > nanoseconds bits{31,30} as seconds{33,32}, to give a (signed) 34-bit
> > seconds field and an unsigned 30-bit nanoseconds field.
> > 
> > This could represent 1970 +/- 272 years.
> > 
> > Servers could indicate they can understand the extended time format by
> > adding a new FSINFO capability - FSF3_CANSETTIME_EX.
> > 
> > Clients would use a new SET_TO_CLIENT_TIME_EX time_how enum when sending
> > timestamps so old servers would be protected from new clients.
> 
> You would have to get the IETF’s NFSv4 working group to sign off on
> this change. Otherwise, Linux would be the only NFSv3 implementation
> that supports the extension.
> 
> But I suspect the answer you’d get is “Use NFSv4.”

While I've never dealt with an NFS standardization, I'd assume this is
a workable answer. The NFSv2 and NFSv3 definition clearly defines a valid
range of times until 2106 using unsigned seconds, and that should really
give enough time to migrate to something better (not necessarily NFSv4).

	Arnd
