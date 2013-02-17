Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57014 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab3BQPyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Feb 2013 10:54:24 -0500
Date: Sun, 17 Feb 2013 10:54:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
Cc: Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        Tom Horsley <horsley1953@gmail.com>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
Message-ID: <20130217155420.GB11441@fieldses.org>
References: <50F4D800.5040703@teksavvy.com>
 <50FC74E0.20305@teksavvy.com>
 <20130212205216.GE10267@fieldses.org>
 <6911210.gbkqvnQvg4@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6911210.gbkqvnQvg4@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 15, 2013 at 08:33:14PM +0100, Paweł Sikora wrote:
> On Tuesday 12 of February 2013 15:52:17 J. Bruce Fields wrote:
> > On Sun, Jan 20, 2013 at 05:51:12PM -0500, Mark Lord wrote:
> > > Got it again, this time on a different system
> > > running mostly the same software.
> > 
> > Mark, Paweł, Tom, could any of you confirm whether this helps?
> 
> with this patch i can confirm a 2 day uptime w/o any oopses.
> 

Thanks for the report.--b.
