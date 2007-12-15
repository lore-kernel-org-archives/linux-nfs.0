From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 34/38] svc: Add transport hdr size for defer/revisit
Date: Sat, 15 Dec 2007 12:16:00 -0600
Message-ID: <C3897600.22993%tom@opengridcomputing.com>
References: <20071214233717.GM23121@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: NeilBrown <neilb@suse.de>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:12609 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017AbXLOSQR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2007 13:16:17 -0500
In-Reply-To: <20071214233717.GM23121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/14/07 5:37 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 11, 2007 at 05:33:09PM -0600, Tom Tucker wrote:
>> 
>> Some transports have a header in front of the RPC header. The current
>> defer/revisit processing considers only the iov_len and arg_len to
>> determine how much to back up when saving the original request
>> to revisit. Add a field to the rqstp structure to save the size
>> of the transport header so svc_defer can correctly compute
>> the start of a request.
> 
> I know I asked before, and can't remember what happened: has this been
> tested with krb5p?  (I know nobody cares much whether krb5p/rdma works,
> I just want to make sure krb5p/rdma doesn't oops, and that
> krb5p/{tcp,udp} are unchanged.)

I haven't tested this combination. I definitely don't have a kerberos setup,
but I guess I need to sooner or later...

> 
> I'll try it eventually if you don't....
> 
> --b.


