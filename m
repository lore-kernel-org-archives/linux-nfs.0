Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:47626 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab3BOTdV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 14:33:21 -0500
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        Tom Horsley <horsley1953@gmail.com>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
Date: Fri, 15 Feb 2013 20:33:14 +0100
Message-ID: <6911210.gbkqvnQvg4@localhost>
In-Reply-To: <20130212205216.GE10267@fieldses.org>
References: <50F4D800.5040703@teksavvy.com> <50FC74E0.20305@teksavvy.com> <20130212205216.GE10267@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 12 of February 2013 15:52:17 J. Bruce Fields wrote:
> On Sun, Jan 20, 2013 at 05:51:12PM -0500, Mark Lord wrote:
> > Got it again, this time on a different system
> > running mostly the same software.
> 
> Mark, Paweł, Tom, could any of you confirm whether this helps?

with this patch i can confirm a 2 day uptime w/o any oopses.

