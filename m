Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308Ab0HRTJ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 15:09:57 -0400
Message-ID: <4C6C3000.5010003@RedHat.com>
Date: Wed, 18 Aug 2010 15:09:52 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Support for Numeric Representations of UIDs and GIDs.
References: <1282073925-18707-1-git-send-email-steved@redhat.com> <20100818182053.GB13050@fieldses.org>
In-Reply-To: <20100818182053.GB13050@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/18/2010 02:20 PM, J. Bruce Fields wrote:
> On Tue, Aug 17, 2010 at 03:38:43PM -0400, Steve Dickson wrote:
>> In recent NFS v2/v3 to v4 transitions, one of the sticking 
>> points have been that fact v4 uses strings in the format
>> of "user@domain" instead of 32bit integers for uids and 
>> gids.
>>
>> When the string can not be mapped, its mapped to the 'nobody'
>> user which is not optimal for things like backup servers and
>> such where the ids will not be know by both sides.
>>
>> So this patch series enables the server to send out numeric 
>> string of uids and gids that do not have the '@domain' part.
>> The series also adds functionality to the client that parse these
>> type of strings and will use the numeric representation
>> of the ids iff the id exists on the client, which is 
>> sightly different that Solaris. Solaris dose not have that
>> "id must exist" restriction.
> 
> Why did you decide to impose that restriction?
I just thought it made sense, from a security standpoint to make sure the 
ids were at least valid on the client... if they are not valid the id 
becomes 'nobody' which how it works today... but is different than how 
OpenSolaris does it... they just use whatever the server tells to... 

steved.

