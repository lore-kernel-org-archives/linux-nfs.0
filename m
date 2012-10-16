Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:16744 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab2JPAgv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 20:36:51 -0400
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net> <20121015222455.GB30649@fieldses.org>
In-Reply-To: <20121015222455.GB30649@fieldses.org>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <80D40623-BC32-4711-8005-A4975CF69A39@oracle.com>
Cc: "steved@redhat.com" <steved@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/8] Junctions should inherit parent's export options
Date: Mon, 15 Oct 2012 20:36:44 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Sent from my iPad

On Oct 15, 2012, at 6:24 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Oct 11, 2012 at 11:10:39AM -0400, Chuck Lever wrote:
>> Following suggestions by Steve and Bruce, I've at long last
>> implemented a mechanism by which junctions inherit the export
>> options of their parent exports.
> 
> Thanks!
> 
>> While I was there, I took the opportunity to clean up the junction
>> resolution logic.
> 
> Are bad mullets really specifically a 90's thing?  I thought they were
> sort of timeless.

I could have referenced MacGyver, but I never watched the show.

> Anyway, that aside, looks reasonable to me.  ACK.

Thanks for the review.

Steve, I think you can take these now, if you are happy with them.

> (I still can't get used to ACK.  Whenever I see it I wonder what the
> writer's so startled about.  ACK!)
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
