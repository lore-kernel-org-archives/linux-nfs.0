Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22319 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760550Ab1F1Rtb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 13:49:31 -0400
Message-ID: <42653612-BD54-4049-B8F8-ACDFB6FE6DA3@oracle.com>
Date: Tue, 28 Jun 2011 10:49:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
To: Prem Karat <prem.karat@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
References: <20110628104138.GB6600@d6fc318.ibm.com>
 <FA506314-750E-4E20-B80C-B507D032D962@oracle.com>
 <20110628165954.GA13059@d6fc318.ibm.com>
In-Reply-To: <20110628165954.GA13059@d6fc318.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 28, 2011, at 12:59 PM, Prem Karat wrote:

> On 06/28/11 12:02pm, Chuck Lever wrote:
>> 
>> On Jun 28, 2011, at 6:41 AM, Prem Karat wrote:
>> 
>>> 
>>> Currently souce and destination parameters should be passed as first and 
>>> second paramter while using mount.nfs. This patch allows them to be passed 
>>> anywhere while mounting.
>>> 
>>> Current functionality is
>>> 	mount.nfs source destn -o <options>
>>> This patch will allow to do this
>>> 	mount.nfs -o <options> source destn
>>> 		or
>>> 	mount.nfs -o <options> source -o <options> destn
>> 
>> Yep, that's clear, but why is this desirable?  mount.nfs should be invoked only by the mount command.  It's not meant to be run by humans.
> Bare with me if my understanding is incorrect, however the man page does say that
> it can be used as a standalone command with limited functionality.

Yes, it can be used that way, but it rarely is, and that's by design.

> Also it makes sense to use it if a newbie wants to know the nfs specific
> options. The mount.nfs command shows a pointer to the correct man page for
> nfs specific options.

I don't understand.  Why would a "newbie" invoke mount.nfs?  Is there a new use case that requires the additional flexibility?

I don't have a specific objection here, but this seems like an arbitrary change.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




