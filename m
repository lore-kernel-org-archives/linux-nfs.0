From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Fri, 27 Nov 2009 01:07:46 +0100
Message-ID: <64b4daae0911261607m10d1ba3al8c067f85249c198f@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
	 <1259247707.6715.46.camel@localhost>
	 <64b4daae0911260707i4064f608w4f7169441640567@mail.gmail.com>
	 <1259248859.6715.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:52079 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbZK0AHl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2009 19:07:41 -0500
Received: by fxm5 with SMTP id 5so1174898fxm.28
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2009 16:07:46 -0800 (PST)
In-Reply-To: <1259248859.6715.50.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 26, 2009 at 16:20, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
>> I can run with RPCDBG_TRANS enabled, if it is needed to further
>> pinpoint the problem.

I don't think I understand how to enable RPCDBG_TRANS exactly.
Anyway, I activated the dprintks in xprtsock.c with the following
(endless) result:

RPC:       cfa94400 connect status 99 connected 0 sock state 7
RPC:       xs_tcp_send_request(32896) = -32
RPC:       xs_tcp_state_change client cfa94400...
RPC:       state 7 conn 0 dead 0 zapped 1
RPC:       xs_connect delayed xprt cfa94400 for 0 seconds
RPC:       worker connecting xprt cfa94400 to address: addr=1.2.3.151
port=2049 proto=tcp
RPC:       cfa94400 connect status 99 connected 0 sock state 7
RPC:       xs_tcp_send_request(32896) = -32
RPC:       xs_tcp_state_change client cfa94400...
RPC:       state 7 conn 0 dead 0 zapped 1
RPC:       xs_connect delayed xprt cfa94400 for 0 seconds
RPC:       worker connecting xprt cfa94400 to address: addr=1.2.3.151
port=2049 proto=tcp
RPC:       cfa94400 connect status 99 connected 0 sock state 7
RPC:       xs_tcp_send_request(32896) = -32
RPC:       xs_tcp_state_change client cfa94400...
RPC:       state 7 conn 0 dead 0 zapped 1
RPC:       xs_connect delayed xprt cfa94400 for 0 seconds
RPC:       worker connecting xprt cfa94400 to address: addr=1.2.3.151
port=2049 proto=tcp

Does this tell you more?
-- 
Sincerely,
                Stephen R. van den Berg.
