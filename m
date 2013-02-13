Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mouse.start.ca ([64.140.120.56]:56592 "EHLO mouse.start.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759703Ab3BMPXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 10:23:07 -0500
Message-ID: <511BAAAA.9040804@start.ca>
Date: Wed, 13 Feb 2013 10:00:58 -0500
From: Mark Lord <kernel@start.ca>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        =?UTF-8?B?UGF3ZcWCIFNpa29yYQ==?= <pawel.sikora@agmk.net>,
        Tom Horsley <horsley1953@gmail.com>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
References: <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org> <50F7FB7E.2020503@parallels.com> <50F88C14.7030903@teksavvy.com> <50F8DF7E.8080107@parallels.com> <50FC74E0.20305@teksavvy.com> <20130212205216.GE10267@fieldses.org>
In-Reply-To: <20130212205216.GE10267@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-02-12 03:52 PM, J. Bruce Fields wrote:
> On Sun, Jan 20, 2013 at 05:51:12PM -0500, Mark Lord wrote:
>> Got it again, this time on a different system
>> running mostly the same software.
> 
> Mark, Paweł, Tom, could any of you confirm whether this helps?
..

No, I cannot confirm one way or the other,
because I haven't noticed it again since the most recent
couple of occurrences I posted earlier here.

Cheers
