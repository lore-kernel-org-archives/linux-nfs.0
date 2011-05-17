Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47779 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab1EQUOH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2011 16:14:07 -0400
Received: by iyb14 with SMTP id 14so717489iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2011 13:14:06 -0700 (PDT)
In-Reply-To: <348736D4-8B01-4BD9-BE05-82A8F64CEB8D@netapp.com>
References: <BANLkTi=juxkPqEXtSNubnOFHWT7FLzPdGA@mail.gmail.com>
	<348736D4-8B01-4BD9-BE05-82A8F64CEB8D@netapp.com>
Date: Tue, 17 May 2011 16:14:06 -0400
Message-ID: <BANLkTimBQqe=AnFrGq23z4jaMTUAcKbupQ@mail.gmail.com>
Subject: Re: linux client support for pnfs over ipv6
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Mike Groshans <groshans@umich.edu>,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry, I must be blind, I don't see any posts with ipv6 patches from you.

We are almost ready to submit ipv6 patches for the linux server side.

On Tue, May 17, 2011 at 3:34 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> Yes, posted a diff on saturday, but I'm doing a little cleanup (need to check CONFIG_IPV6) and reposting later today.
>
> -dros
>
> On May 17, 2011, at 3:28 PM, Olga Kornievskaia wrote:
>
>> Is there a plan to support ipv6 pnfs on the linux client side?
>>
>> kernel output on the client has:
>> kernel: decode_and_add_ds: Only ipv4 addresses supported
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
