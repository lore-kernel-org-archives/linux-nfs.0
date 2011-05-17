From: Weston Andros Adamson <dros@netapp.com>
Subject: Re: linux client support for pnfs over ipv6
Date: Tue, 17 May 2011 16:21:52 -0400
Message-ID: <BD2C7B9F-FA9D-4504-8A11-BD15544AC284@netapp.com>
References: <BANLkTi=juxkPqEXtSNubnOFHWT7FLzPdGA@mail.gmail.com> <348736D4-8B01-4BD9-BE05-82A8F64CEB8D@netapp.com> <BANLkTimBQqe=AnFrGq23z4jaMTUAcKbupQ@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	Mike Groshans <groshans@umich.edu>,
	peter honeyman <honey@citi.umich.edu>
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59165 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab1EQUWI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2011 16:22:08 -0400
In-Reply-To: <BANLkTimBQqe=AnFrGq23z4jaMTUAcKbupQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Odd!  I'll forward it to you.

-dros

On May 17, 2011, at 4:14 PM, Olga Kornievskaia wrote:

> Sorry, I must be blind, I don't see any posts with ipv6 patches from you.
> 
> We are almost ready to submit ipv6 patches for the linux server side.
> 
> On Tue, May 17, 2011 at 3:34 PM, Weston Andros Adamson <dros@netapp.com> wrote:
>> Yes, posted a diff on saturday, but I'm doing a little cleanup (need to check CONFIG_IPV6) and reposting later today.
>> 
>> -dros
>> 
>> On May 17, 2011, at 3:28 PM, Olga Kornievskaia wrote:
>> 
>>> Is there a plan to support ipv6 pnfs on the linux client side?
>>> 
>>> kernel output on the client has:
>>> kernel: decode_and_add_ds: Only ipv4 addresses supported
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 

