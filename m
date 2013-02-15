Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:38672 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab3BOTmN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 14:42:13 -0500
Date: Fri, 15 Feb 2013 14:42:08 -0500
From: Tom Horsley <horsley1953@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mark Lord <kernel@start.ca>, Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        =?utf-8?Q?Pawe=C5=82?= Sikora <pawel.sikora@agmk.net>,
        Jason Tibbitts <tibbs@math.uh.edu>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
Message-ID: <20130215144208.56de59f3@tomh>
In-Reply-To: <20130215192229.GC19923@fieldses.org>
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
	<20130215192229.GC19923@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Feb 2013 14:22:29 -0500
J. Bruce Fields wrote:

> Any more reports positive or negative welcome.

Well, I don't have the time or energy to try patches on my
system at work, but these seem to be concerned with terminating
an NFS connection. My aborts all happen at boot when it
is trying to do the mount to begin with.
