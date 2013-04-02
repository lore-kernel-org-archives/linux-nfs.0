Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761551Ab3DBTQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 15:16:09 -0400
Message-ID: <515B2E7D.1050005@RedHat.com>
Date: Tue, 02 Apr 2013 15:16:13 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Alex Dubov <oakad@yahoo.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Allow building nfs-utils directly against GSSAPI
References: <1364317202.2660.132.camel@willson.li.ssimo.org> <loom.20130327T154155-192@post.gmane.org>
In-Reply-To: <loom.20130327T154155-192@post.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



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
I when ahead and took Simo's patches but I would like to continue to work
with on get your Heimdal build working again... What exactly broke?

steved.

