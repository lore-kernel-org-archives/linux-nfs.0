From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Thu, 26 Nov 2009 16:07:16 +0100
Message-ID: <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:51201 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760575AbZKZPHM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2009 10:07:12 -0500
Received: by fg-out-1718.google.com with SMTP id 19so441803fgg.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2009 07:07:17 -0800 (PST)
In-Reply-To: <1259247707.6715.46.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 26, 2009 at 16:01, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Thu, 2009-11-26 at 00:11 +0100, Stephen R. van den Berg wrote:
>> 1.2.3.167 is the Linux client kernel which locks up, 1.2.3.151 is th=
e
>> unfs server.
>> It looks like the client terminates the TCP connection. =A0The serve=
r
>> confirms it, the client then sends a final acknowledge. =A0At that p=
oint
>> the client kernel locks up in the infinite loop.

> OK. Have you tried running with RPCDBG_TRANS debugging enabled? I
> suspect you might see a flood of 'sendmsg returned unrecognized error=
'
> or 'connect returned unhandled error' messages if you do.

The pcap trace is not conclusive (enough)?
I can run with RPCDBG_TRANS enabled, if it is needed to further
pinpoint the problem.
--=20
Sincerely,
                Stephen R. van den Berg.
