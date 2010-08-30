Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35132 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876Ab0H3RJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 13:09:46 -0400
Date: Mon, 30 Aug 2010 13:09:24 -0400
To: Peng Yu <pengyu.ut@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 30 time speed difference between using NFS and without using
 NFS
Message-ID: <20100830170923.GA17103@fieldses.org>
References: <AANLkTimog6uTdsxzFeA0YY+HK6gtcwEGXaFDJs+Aorm0@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimog6uTdsxzFeA0YY+HK6gtcwEGXaFDJs+Aorm0@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 27, 2010 at 06:08:25PM -0500, Peng Yu wrote:
> Hi,
> 
> I use the following command to search for some directory.
> 
> find -L some_dir -type d -name some_name
> 
> If I'm on the machine that has some_dir locally, the run time is
> real	0m0.199s
> user	0m0.048s
> sys	0m0.140s
> 
> If I'm on another machine that sees the same directory by NFS (NFS3).
> the run time is
> real	0m6.509s
> user	0m0.090s
> sys	0m1.380s
> 
> There are 30 time speed difference. Is this normal? Is there any NFS
> parameter that I should tune to make the latter faster?

How many directories are there in some_dir?  What's the round trip time
(e.g. as reported by ping) to the server?  If you repeate the find
immediately, is it faster?

This can indeed by much slower if it requires revalidating the cached
attributes of each file.

--b.
