Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759979Ab3DBSDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:03:35 -0400
Message-ID: <515B1D7A.6030906@RedHat.com>
Date: Tue, 02 Apr 2013 14:03:38 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Alex Dubov <oakad@yahoo.com>
CC: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: Re: Allow building nfs-utils directly against GSSAPI
References: <1364317202.2660.132.camel@willson.li.ssimo.org> <loom.20130327T154155-192@post.gmane.org>
In-Reply-To: <loom.20130327T154155-192@post.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CC-ing Simo since he is not on this mailing list...


On 27/03/13 10:43, Alex Dubov wrote:
> Simo Sorce <simo@...> writes:
> 
>>
>> Libgssglue is not really useful anymore, it is a sort of middleman that
>> wraps the actual GSSAPI that is already pluggable/extensible via shared
>> modules.
>>
>> In particular libgssglue interferes with the workings of gss-proxy in my
>> case.
>>
>> The attached patch makes building against libgssglue optional and
>> defaults to not build against libgssglue and instead builds directly
>> against the native GSSAPI.
>>
> 
> I have tried your patch with my Heimdal setup and it would not build properly
> with it.
> 
> I can augment my patch to make use of your changes. Would you be willing to
> consider it?
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
