From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Sat, 28 Nov 2009 01:20:07 +0100
Message-ID: <64b4daae0911271620k46a99666td81528fc863e69f0@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
	 <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
	 <1259248859.6715.50.camel@localhost>
	 <64b4daae0911261607m10d1ba3al8c067f85249c198f@mail.gmail.com>
	 <64b4daae0911261614l471fb74fx79db2988f0c65738@mail.gmail.com>
	 <1259357036.3486.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:56453 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753446AbZK1AUC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Nov 2009 19:20:02 -0500
Received: by fxm5 with SMTP id 5so2004243fxm.28
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2009 16:20:07 -0800 (PST)
In-Reply-To: <1259357036.3486.38.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 27, 2009 at 22:23, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-11-27 at 01:14 +0100, Stephen R. van den Berg wrote:
>> On Fri, Nov 27, 2009 at 01:07, Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org>=
 wrote:
> Does the following patch fix matters?

> =A0 =A0 =A0 =A0if (!xprt_lock_write(xprt, task))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> +
> + =A0 =A0 =A0 if (test_and_clear_bit(XPRT_CLOSE_WAIT, &xprt->state))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xprt->ops->close(xprt);
> +
> =A0 =A0 =A0 =A0if (xprt_connected(xprt))

Sorry.  No go.  I got the following trace, I'm not sure if this is
relevant, because it is difficult to determine if the logging
corresponds to the experienced problem.

RPC: 14194 xprt_connect_status: retrying
RPC: 14194 xprt_prepare_transmit
RPC: 14194 xprt_transmit(112)
RPC:       disconnected transport cfa82400
RPC: 14194 xprt_connect xprt cfa82400 is not connected
RPC: 14194 xprt_connect_status: retrying
RPC: 14194 xprt_prepare_transmit
RPC: 14194 xprt_transmit(112)
RPC:       disconnected transport cfa82400
RPC: 14194 xprt_connect xprt cfa82400 is not connected
RPC: 14194 xprt_connect_status: retrying
RPC: 14194 xprt_prepare_transmit
RPC: 14194 xprt_transmit(112)
RPC:       disconnected transport cfa82400
RPC: 14194 xprt_connect xprt cfa82400 is not connected
RPC: 14194 xprt_connect_status: retrying
RPC: 14194 xprt_prepare_transmit
RPC: 14194 xprt_transmit(112)
RPC:       disconnected transport cfa82400
RPC: 14194 xprt_connect xprt cfa82400 is not connected
RPC: 14194 xprt_connect_status: retrying
RPC: 14194 xprt_prepare_transmit
RPC: 14194 xprt_transmit(112)
--=20
Sincerely,
                Stephen R. van den Berg.
