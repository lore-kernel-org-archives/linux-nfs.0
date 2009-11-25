From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Wed, 25 Nov 2009 22:58:18 +0100
Message-ID: <64b4daae0911251358s230588ebn3351380d6bb6e417@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:51988 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935107AbZKYV6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2009 16:58:13 -0500
Received: by fxm5 with SMTP id 5so190361fxm.28
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2009 13:58:19 -0800 (PST)
In-Reply-To: <1259159512.3314.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2009 at 15:31, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2009-11-25 at 09:56 +0100, Stephen R. van den Berg wrote:
>> The kernel hangs at this point, the only way to get out of there is
>> using SysBreak.

> This just means that the RPC client is waiting for a reply from the NFS
> server.

Even if it is, I'd say that the kernel has no business "busywaiting"
for that response.  It should yield to other processes.  So even if
the response does get lost, the kernel shouldn't become locked.

> Does 'netstat -t' show that there is an active TCP connection to the
> server's nfs port?
> Does wireshark show that the client should have received a reply?

I'll do a packettrace and let you know.
-- 
Sincerely,
                Stephen R. van den Berg.
