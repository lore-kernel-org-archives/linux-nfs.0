Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24090 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757835Ab1EWWbx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 18:31:53 -0400
Message-ID: <4DDAE041.2080707@panasas.com>
Date: Tue, 24 May 2011 01:31:29 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SQUASHME: Bugs in new global-device-cache code
References: <4DD99F9B.2040406@panasas.com> <1306108720-28762-1-git-send-email-bhalevy@panasas.com> <4DD9E805.2020106@panasas.com> <4DDA64C6.2080909@panasas.com> <4DDAC93A.2020209@panasas.com> <4DDAD8AC.8030206@panasas.com>
In-Reply-To: <4DDAD8AC.8030206@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/24/2011 12:59 AM, Boaz Harrosh wrote:
> 2. Something funny I'm still investigating. When I do
>    a small Io couple of  requests the devices get freed
>    at the end on the release of the layout. (Which is not
>    layout_returned ever)
>    But when I do very large IO and lots of concurrent requests
>    the devices do not get to be released at all, they stay in
>    cache. But am still investigating

OK That was a stupid print problem. The buffer was full and the prints
did not show.

It's fine, I guess I need to sleep ;-)

Boaz
