Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45502 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab1CCO3a convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Mar 2011 09:29:30 -0500
Received: by fxm17 with SMTP id 17so1138710fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 03 Mar 2011 06:29:29 -0800 (PST)
In-Reply-To: <20110303062621.GG7724@fieldses.org>
References: <1299113502-17179-1-git-send-email-kwc@citi.umich.edu>
	<20110303062621.GG7724@fieldses.org>
Date: Thu, 3 Mar 2011 09:28:18 -0500
Message-ID: <AANLkTikhZV1ybQ0F4Yt9SQLvt8xRyuGZA0fBNPyu3sb-@mail.gmail.com>
Subject: Re: [PATCH 0/2] Give svcgssd access to kernel's supported enctypes
From: Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 3, 2011 at 1:26 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Mar 02, 2011 at 07:51:40PM -0500, Kevin Coffman wrote:
>> Make the kernel's supported enctypes available to user-land
>> (svcgssd) via a new proc file.  The client side already gets
>> this information in the upcall to gssd, we need to make it
>> available to svcgssd.
>
> They look good to me; I'll queue them up for 2.6.39 if nobody else sees
> a problem.
>
> Do you have the nfs-utils bits ready as well?
>
> --b.

I do, but I wanted to try and add something to detect whether the
Kerberos code has been updated to honor the request to limit the
encryption types (in the accept_sec_context path), and give a helpful
warning message.  However, that may turn out to be more work than it
is worth.  I will be sending patches soon.

K.C.
