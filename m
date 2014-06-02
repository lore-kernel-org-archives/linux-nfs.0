Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:45866 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbaFBTFg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 15:05:36 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1401735504.6065.227.camel@montana.filmlight.ltd.uk>
Date: Mon, 2 Jun 2014 15:04:27 -0400
Cc: Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>,
        linux-arch@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>, lftan@altera.com,
        Christoph Hellwig <hch@infradead.org>, john.stultz@linaro.org,
        "H. Peter Anvin" <hpa@zytor.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, geert@linux-m68k.org,
        tglx@linutronix.de, xfs@oss.sgi.com, joseph@codesourcery.com
Message-Id: <C57EA6CA-236A-4C93-95F8-21F46A3622DA@oracle.com>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <8618458.1EVJCoVbkH@wuerfel> <alpine.LFD.2.11.1406012121430.17310@knanqh.ubzr> <4178301.j9kWdGCRLC@wuerfel> <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com> <1401735504.6065.227.camel@montana.filmlight.ltd.uk>
To: Roger Willcocks <roger@filmlight.ltd.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2014, at 2:58 PM, Roger Willcocks <roger@filmlight.ltd.uk> wrote:

> 
> On Mon, 2014-06-02 at 11:04 -0400, Chuck Lever wrote:
> 
>> NFSv2/3 timestamps are a pair of unsigned 32-bit values: one value for
>> seconds since midnight GMT Jan 1, 1970, and one value for nanoseconds.
>> (See the definition of nfstime3 in RFC 1813).
>> 
> 
> nfstime3 could be extended by redefining the otherwise unused
> nanoseconds bits{31,30} as seconds{33,32}, to give a (signed) 34-bit
> seconds field and an unsigned 30-bit nanoseconds field.
> 
> This could represent 1970 +/- 272 years.
> 
> Servers could indicate they can understand the extended time format by
> adding a new FSINFO capability - FSF3_CANSETTIME_EX.
> 
> Clients would use a new SET_TO_CLIENT_TIME_EX time_how enum when sending
> timestamps so old servers would be protected from new clients.

You would have to get the IETF’s NFSv4 working group to sign off on
this change. Otherwise, Linux would be the only NFSv3 implementation
that supports the extension.

But I suspect the answer you’d get is “Use NFSv4.”

> Old clients don't need to be protected from new servers because the
> on-the-wire bit pattern for dates between 1970 and 2106 stays the same,
> so they're no worse off than they were before.
> 
> Arguably the new server ought to clamp out-of-range timestamps before
> sending them to old clients but that would need per-client state (and
> nfs3 is stateless.)

There’s no reliable way in NFSv3 for clients and servers to identify
the software running on the peer.

Practically speaking, you should assume that the NFSv3 protocol is never
going to change.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



