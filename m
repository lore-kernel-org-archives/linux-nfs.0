Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:35054 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758428Ab1FWPqf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 11:46:35 -0400
Subject: Re: [PATCH 00/11] NFS: Support binding to source address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E035BED.3040105@candelatech.com>
Date: Thu, 23 Jun 2011 09:46:23 -0600
Cc: linux-nfs@vger.kernel.org
Message-Id: <C4E3B7E9-47D7-4A93-B88F-0021D0450ACC@oracle.com>
References: <1308778611-9370-1-git-send-email-greearb@candelatech.com> <F37E8424-9A40-4C4F-A2F6-431FDA831E0D@oracle.com> <4E035BED.3040105@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Ben-

On Jun 23, 2011, at 9:29 AM, Ben Greear wrote:

> On 06/23/2011 07:59 AM, Chuck Lever wrote:
>> 
>> On Jun 22, 2011, at 3:36 PM, greearb@candelatech.com wrote:
>> 
>>> From: Ben Greear<greearb@candelatech.com>
>>> 
>>> This lets one specify the source IP address for
>>> sockets, allowing users to leverage routing rules
>>> on multi-homed systems.
>> 
>> Do you need changes to send NLM requests from the right source address?
> 
> Not for my testing so far...but maybe I'm not utilizing whatever NLM
> does.  What sort of things would require/use it?

File locking.  NLM support should be a requirement for a complete implementation of srcaddr=, IMO.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



