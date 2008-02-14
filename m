From: Wendy Cheng <wcheng@netapp.com>
Subject: Re: [PATCH 0/2] NLM failover unlock
Date: Thu, 14 Feb 2008 14:04:28 -0500
Message-ID: <47B490BC.2000309@netapp.com>
References: <4781B91D.8090509@redhat.com> <20080214183833.GA26936@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756289AbYBNTEl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2008 14:04:41 -0500
In-Reply-To: <20080214183833.GA26936-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bob Bell wrote:
> On Mon, Jan 07, 2008 at 12:31:09AM -0500, Wendy Cheng wrote:
>> This submission is part of the patch sets added to support NFS server 
>> failover where the specified export is moved from one physical server 
>> to another.
>
> Wendy,
>
> What's the current status of these patches?  I believe I have a 
> situation that could benefit from being able to release all NLM locks 
> on an exported filesystem.
>
I think Bruce has queued the unlock patch for 2.6.26 (Bruce ?) ..

-- Wendy
