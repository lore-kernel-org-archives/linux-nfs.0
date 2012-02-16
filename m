Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40052 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980Ab2BPDbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 22:31:37 -0500
Message-ID: <4F3C7884.5050802@panasas.com>
Date: Wed, 15 Feb 2012 19:31:16 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: pynfs: cleanup and turn off some tests by default
References: <1329345920-16608-1-git-send-email-bfields@redhat.com> <4F3C4D91.20300@panasas.com> <20120216012805.GE19298@pad.fieldses.org>
In-Reply-To: <20120216012805.GE19298@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/15/2012 05:28 PM, J. Bruce Fields wrote:
> On Wed, Feb 15, 2012 at 04:28:01PM -0800, Boaz Harrosh wrote:
>> On 02/15/2012 02:45 PM, J. Bruce Fields wrote:
>>> I've committed the following to my pynfs repo.
>>>
>>> Fix a couple minor problems found while working on a bug, then turn off
>>> utf8 and pnfs tests by default (both can still be requested by adding
>>> "utf8" or "pnfs", respectively, on the commandline), and remove one
>>> incorrect test.
>>>
>>> I'd like to get to the point where the pynfs tests all pass against a
>>> reasonable server.  That means fixing the server where necessary, of
>>> course, but also not complaining about unimplemented optional features
>>> or about stuff we don't plan to fix.
>>>
>>
>> Can't we "auto detect" the pnfs option. Request a pnfs access if failed
>> proceed to the next set of tests, if successful continue to test "pnfs"
> 
> Good idea!  I think you'd still want "pnfs" and "nopnfs" options: "pnfs"
> for "I expect this server to support pnfs, and if it doesn't report that
> as a bug!", and "nopnfs" for: "this server claims to support  pnfs but
> please just don't even bother telling me how buggy it is, I already
> know".
> 

Sounds good

> But just turning it off by default was a minute's worth of
> search-and-replace for me, and I don't have the time for more right now.
> So that's a project looking for a volunteer.
> 

NP, thanks for the fixes so far. We'll probably add pynfs testing to our
Ganesha testing rig. When we do we'll look into it. That is if no one
bits us to it, (Hopefully ;-) )

> --b.

Thanks
Boaz
