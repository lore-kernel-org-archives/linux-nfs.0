From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: Re: EBADCOOKIE problem?
Date: Fri, 11 Jan 2008 20:17:48 -0500
Message-ID: <20080112011746.GA8148@newbie.thebellsplace.net>
References: <20080111045951.GA20079@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:44494 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbYALBRu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2008 20:17:50 -0500
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id m0C1JbB9023234
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2008 20:19:37 -0500
In-Reply-To: <20080111045951.GA20079-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 10, 2008 at 11:59:51PM -0500, Bob Bell wrote:
>In testing, we're seeing a problem where an ls of a directory over NFSv3 
>reports "File not found" for one of the sub-directories.  With some 
>tracing turned on, I can see that there is an -EBADCOOKIE error returned 
>from find_dirent().  The error is persistent; it doesn't go away with 
>time.  I do have one report that says that by adding another file to the 
>directory, the error went away.
>...

My apologies, apparently EBADCOOKIE has nothing to do with this.  The 
problem is the caching model and ext3's full-second timestamp 
granularity.  I've already discussed the issue with Trond.

-- Bob
