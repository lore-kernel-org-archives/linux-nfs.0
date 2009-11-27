From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Fri, 27 Nov 2009 01:14:46 +0100
Message-ID: <64b4daae0911261614l471fb74fx79db2988f0c65738@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
	 <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
	 <1259248859.6715.50.camel@localhost>
	 <64b4daae0911261607m10d1ba3al8c067f85249c198f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:54412 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbZK0AOk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2009 19:14:40 -0500
Received: by fxm5 with SMTP id 5so1177755fxm.28
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2009 16:14:46 -0800 (PST)
In-Reply-To: <64b4daae0911261607m10d1ba3al8c067f85249c198f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 27, 2009 at 01:07, Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org> wr=
ote:
> RPC: =A0 =A0 =A0 worker connecting xprt cfa94400 to address: addr=3D1=
=2E2.3.151
> port=3D2049 proto=3Dtcp
> RPC: =A0 =A0 =A0 cfa94400 connect status 99 connected 0 sock state 7

errno 99 means EADDRNOTAVAIL.  In userspace this normally is solved by
using the REUSEADDR sockopt.  In xprtsock.c we try something like:

                /* We're probably in TIME_WAIT. Get rid of existing soc=
ket,
                 * and retry
                 */
                set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
                xprt_force_disconnect(xprt);

I'd guess that this needs to be fixed, or the REUSEADDR sockopt needs t=
o be set.
--=20
Sincerely,
                Stephen R. van den Berg.
