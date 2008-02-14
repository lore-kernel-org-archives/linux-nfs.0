From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/2] NLM failover unlock
Date: Thu, 14 Feb 2008 13:38:39 -0500
Message-ID: <20080214183833.GA26936@newbie.thebellsplace.net>
References: <4781B91D.8090509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:40725 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756619AbYBNSjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 13:39:06 -0500
In-Reply-To: <4781B91D.8090509@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 07, 2008 at 12:31:09AM -0500, Wendy Cheng wrote:
>This submission is part of the patch sets added to support NFS server 
>failover where the specified export is moved from one physical server 
>to another.

Wendy,

What's the current status of these patches?  I believe I have 
a situation that could benefit from being able to release all NLM locks 
on an exported filesystem.

-- 
Bob Bell
