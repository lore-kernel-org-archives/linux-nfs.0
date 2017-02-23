Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36048 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdBWOzi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 09:55:38 -0500
Received: by mail-it0-f65.google.com with SMTP id w185so280788ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 06:55:37 -0800 (PST)
Subject: Re: [PATCH 2/6] NFSv4: fix getacl ERANGE for some ACL buffer sizes
To: "J. Bruce Fields" <bfields@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-3-git-send-email-bfields@redhat.com>
 <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
 <20170222223656.GG24122@parsley.fieldses.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <6606b2d5-719f-9e27-6f95-eec8cebfb1a8@gmail.com>
Date: Thu, 23 Feb 2017 09:55:35 -0500
MIME-Version: 1.0
In-Reply-To: <20170222223656.GG24122@parsley.fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/22/2017 05:36 PM, J. Bruce Fields wrote:
> On Tue, Feb 21, 2017 at 07:46:58PM +0000, Weston Andros Adamson wrote:
>>
>>> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>>
>>> From: Weston Andros Adamson <dros@netapp.com>
>>>
>>> We're not taking into account that the space needed for the (variable
>>> length) attr bitmap, with the result that we'd sometimes get a spurious
>>> ERANGE when the ACL data got close to the end of a page.
>>>
>>> Just add in an extra page to make sure.
>>>
>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>
>> Thanks, you can add:
>>
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> 
> Thanks.
> 
> Anna, could we get this one in now?
> 
> The rest of it still needs some work to account for the problem Andreas
> notes (where we can return a length successfully even though we'll never
> accept an ACL of that length).  But this one is an easy fix for a real
> bug.
> 
> Let me know if you need it resent.

I don't mind taking just the one patch.  Have you made any changes to it since this posting?  If not, then I can take it from the email.

Thanks,
Anna

> 
> --b.
> 
