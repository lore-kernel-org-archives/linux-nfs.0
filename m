Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54588 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab0JARLV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 13:11:21 -0400
Received: by bwz11 with SMTP id 11so2333575bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Oct 2010 10:11:19 -0700 (PDT)
In-Reply-To: <20101001170625.GA3113@merit.edu>
References: <20100930171325.GA5731@merit.edu>
	<4CA503C2.2090607@panasas.com>
	<20100930215220.GB7244@merit.edu>
	<AANLkTi=bRwN3uoszG0jTzVSPMSwP6VKn+rW470uWwAj1@mail.gmail.com>
	<4CA594B5.1090207@panasas.com>
	<AANLkTi=T6PY6MDzbyWikSYOi7HoMWAsEarw-3k=S1+Bu@mail.gmail.com>
	<20101001170625.GA3113@merit.edu>
Date: Fri, 1 Oct 2010 13:11:18 -0400
Message-ID: <AANLkTimvVPvOsCXJSrkA81CONG5EOfFb+2U=B8bFtBRV@mail.gmail.com>
Subject: Re: another block layout oops
From: Fred Isaman <iisaman@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 1, 2010 at 1:06 PM, Jim Rees <rees@umich.edu> wrote:
> Fred Isaman wrote:
>
>  Jim, does the recently submitted PATCH 5/7 fix this?
>
> I think benny's merged this, right?

Yep, its in pnfs-submit at least.

Fred

> I'll fetch the new pnfs-all-latest and
> test, if I can.  My 3GB fedora root partition filled up doing a yum update
> and now it looks unrecoverable.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
