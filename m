From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/5] Support IPv6 in libexport.a
Date: Tue, 31 Aug 2010 19:41:51 -0400
Message-ID: <4C7D933F.8040601@RedHat.com>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net> <4C7D5B63.9060907@RedHat.com> <2F44C575-10D5-4B34-B4D1-038F318E9867@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969Ab0HaXlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 19:41:55 -0400
In-Reply-To: <2F44C575-10D5-4B34-B4D1-038F318E9867@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/31/2010 04:36 PM, Chuck Lever wrote:
> 
> On Aug 31, 2010, at 3:43 PM, Steve Dickson wrote:
> 
>>
>>
>> On 08/24/2010 12:35 PM, Chuck Lever wrote:
>>> Hi Steve-
>>>
>>> This patch set should encapsulate IPv6-related changes needed in
>>> support/export/client.c .  It updates logic that parses presentation
>>> addresses and netmasks, and logic that compares socket addresses.
>>>
>>> ---
>>>
>>> Chuck Lever (5):
>>>      libexport.a: IPv6 support in client_check()
>>>      libexport.a: IPv6 support for client_init_subnet()
>>>      libexport.a: Prepare init_subnetwork() for IPv6 support
>>>      libexport.a: Use host helper to parse address in client_init()
>>>      libexport.a: Prepare to recognize IPv6 addresses in client_gettype()
>>>
>>>
>>> support/export/client.c |  208 +++++++++++++++++++++++++++++++++++------------
>>> 1 files changed, 153 insertions(+), 55 deletions(-)
>>>
>> All 5 Committed...
> 
> Thanks.  Can you push these to your repo on linux-nfs.org?
Sorry about that.... I thought I did but it appears I used
the --dry-run flag... these commits are there now...

steved.

