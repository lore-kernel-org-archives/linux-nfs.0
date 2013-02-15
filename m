Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755Ab3BOTWe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 14:22:34 -0500
Date: Fri, 15 Feb 2013 14:22:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@start.ca>
Cc: Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>,
        Tom Horsley <horsley1953@gmail.com>,
        Jason Tibbitts <tibbs@math.uh.edu>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
Message-ID: <20130215192229.GC19923@fieldses.org>
References: <50F63882.8000607@parallels.com>
 <50F72F03.5070806@teksavvy.com>
 <50F786AF.4070107@parallels.com>
 <20130117130335.GD6598@fieldses.org>
 <50F7FB7E.2020503@parallels.com>
 <50F88C14.7030903@teksavvy.com>
 <50F8DF7E.8080107@parallels.com>
 <50FC74E0.20305@teksavvy.com>
 <20130212205216.GE10267@fieldses.org>
 <511BAAAA.9040804@start.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <511BAAAA.9040804@start.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 10:00:58AM -0500, Mark Lord wrote:
> On 13-02-12 03:52 PM, J. Bruce Fields wrote:
> > On Sun, Jan 20, 2013 at 05:51:12PM -0500, Mark Lord wrote:
> >> Got it again, this time on a different system
> >> running mostly the same software.
> > 
> > Mark, Paweł, Tom, could any of you confirm whether this helps?
> ..
> 
> No, I cannot confirm one way or the other,
> because I haven't noticed it again since the most recent
> couple of occurrences I posted earlier here.

OK, I do have at least one report of someone who saw the bug before
running for a day without seeing it:

	https://bugzilla.redhat.com/show_bug.cgi?id=910457

Any more reports positive or negative welcome.

This looks like it should solve the problem, so for now I intend to
commit the following.

--b.
