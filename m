From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 0/13] sunrpc: Compact the xprtsock code a bit
Date: Tue, 12 Oct 2010 11:51:25 +0400
Message-ID: <4CB4137D.2000709@parallels.com>
References: <4CA9CDA8.4010407@parallels.com> <20101011234711.GC16442@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46482 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756896Ab0JLHwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Oct 2010 03:52:04 -0400
In-Reply-To: <20101011234711.GC16442@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/12/2010 03:47 AM, J. Bruce Fields wrote:
> On Mon, Oct 04, 2010 at 04:50:48PM +0400, Pavel Emelyanov wrote:
>> Hi!
>>
>> This set removes some unused parts of code and merges together
>> routines that are related to the sockets creation.
>>
>> After all the changes the result is
>>
>>  net/sunrpc/xprtsock.c: 77 insertions(+), 206 deletions(-)
>>
>> from the code-lines point of view and
>>
>>   add/remove: 2/11 grow/shrink: 4/1 up/down: 879/-1626 (-747)
>>
>> from the bloat-o-meter's point of view.
> 
> I'm assuming Trond is taking these.  Let me know if that doesn't
> work....

When will these appear in your three then? The thing is my next patches
depend on this set.

> --b.
> 

