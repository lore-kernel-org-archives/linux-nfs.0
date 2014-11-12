Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dgate10.ts.fujitsu.com ([80.70.172.49]:39577 "EHLO
	dgate10.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151AbaKLT01 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 14:26:27 -0500
From: =?Windows-1252?Q?Str=F6sser=2C_Bodo?=
	<bodo.stroesser@ts.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>, "neilb@suse.de" <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "bfields@fieldses.org" <bfields@fieldses.org>
Date: Wed, 12 Nov 2014 20:26:24 +0100
Subject: RE: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
Message-ID: <8B06D1E6480A6747B23FEC34909D2B5EA81BA29CAF@ABGEX70E.FSC.NET>
References: <d6437a$6ag11f@dgate10u.abg.fsc.net> <5463AD87.20305@RedHat.com>
In-Reply-To: <5463AD87.20305@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you for your thorough work.

Bodo

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com]
> Sent: Wednesday, November 12, 2014 7:57 PM
> To: Strösser, Bodo; neilb@suse.de; linux-nfs@vger.kernel.org
> Cc: bfields@fieldses.org
> Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
> 
> 
> 
> On 11/05/2014 03:21 PM, bstroesser@ts.fujitsu.com wrote:
> > Hello,
> >
> > I'm sending a small set of 3 patches for a problem, that I have
> > reported a few weeks ago.
> > rpc.mountd can be blocked by a bad client, that sends lots of
> > RPC requests, but never reads the replies from the socket either
> > intentionally or e.g. caused by a wrong configured MTU.
> >
> > While looking for a possible solution, I found another weakness
> > in rpc.mountd if it is used "multithreaded" (-t nn).
> >
> > The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> > and HAVE_LIBTIRPC.
> > The third patch more a kind of suggestion how the main problem could
> > be fixed. I don't know whether we can set MAXREC without causing
> > new troubles. When this patch is used, a  further patch for libtirpc
> > also should be used. You can find it here:
> >     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409
> After applying all three patches, the DOS does stop... All three committed!
> Nice work! Thank you... very much!!
> 
> steved.
> 
> >
> > Best regards,
> > Bodo
> > N‹§²æìr¸›yúèšØb²X¬¶Ç§vØ^–
> )Þº{.nÇ+‰·¥Š{±û"žØ^n‡r¡ö¦zËëh™¨è­Ú&¢ø®G«éh®(­éšŽŠÝ¢j"ú¶m§ÿïêäz¹Þ–
> Šàþf£¢·hšˆ§~ˆmml==
> >
