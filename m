Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mouse.start.ca ([64.140.120.56]:35575 "EHLO mouse.start.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab3BYUpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Feb 2013 15:45:15 -0500
Message-ID: <512BCD53.8070904@start.ca>
Date: Mon, 25 Feb 2013 15:45:07 -0500
From: Mark Lord <kernel@start.ca>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Mark Lord <kernel@teksavvy.com>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <50F7F898.5050605@teksavvy.com> <20130117135333.GF6598@fieldses.org>
In-Reply-To: <20130117135333.GF6598@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-01-17 08:53 AM, J. Bruce Fields wrote:
> On Thu, Jan 17, 2013 at 08:11:52AM -0500, Mark Lord wrote:
>> On 13-01-14 11:17 AM, Mark Lord wrote:
>>>
>>> Here's the code with the BUG() at net/sunrpc/svc_xprt.c line 921:
>>>
>>> /*
>>>  * Remove a dead transport
>>>  */
>>> static void svc_delete_xprt(struct svc_xprt *xprt)
>>> {
>>>         struct svc_serv *serv = xprt->xpt_server;
>>>         struct svc_deferred_req *dr;
>>>
>>>         /* Only do this once */
>>>         if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
>>>                 BUG();
>>

Saw this again today on 3.7.9 -- dunno if your changes are in that kernel yet though.

