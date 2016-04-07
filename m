Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59330 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757226AbcDGSQp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2016 14:16:45 -0400
Date: Thu, 7 Apr 2016 14:16:44 -0400
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question : Compress files to send with NFS4.1
Message-ID: <20160407181644.GC30676@fieldses.org>
References: <CAEUt8VJhRXn7WT8f52Wyy8B7gAPZREK1J7miCY7Rt6z__CC5uQ@mail.gmail.com>
 <CALXu0UfC3h2Rv4oQ9pSZLeMQJMqQu4zt2ywTBTMiWhmD9S6sfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0UfC3h2Rv4oQ9pSZLeMQJMqQu4zt2ywTBTMiWhmD9S6sfg@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 07, 2016 at 04:06:11PM +0200, Cedric Blancher wrote:
> On 7 April 2016 at 15:27, Martin Houry <martinhoury@gmail.com> wrote:
> > Is NFS4.1 capable to compress files before sending them on the network
> > and decompress them on the destination to speed up the file transfert?
> 
> You can get that with IP tunnel compression. Trouble is, NFS
> (v2/v3/v4; and younger protocol designers are even worse by telling
> you 'dunno care about high latency [ > 4 sec roundtrip ] any more'
> [yeah? wanna pester? old RFS and AFS did a better job...]) are highly
> sensitive to latency, and like ssh the high latency causes more
> trouble than its worth.

The only feature the protocol has that's a little bit like compression
is READ_PLUS (in 4.2), which can tell the client that a range of the
file is a hole instead of returning all the zeroes.  You could think of
that as a specialized kind of compression for sparse files.  Even there
we've been having some trouble ensuring there aren't performance
regressions.

--b.
