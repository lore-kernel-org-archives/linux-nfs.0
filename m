Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:65424 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756396Ab1JCPNf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Oct 2011 11:13:35 -0400
Received: by yxl31 with SMTP id 31so3573984yxl.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 Oct 2011 08:13:35 -0700 (PDT)
Message-ID: <4E89D114.1020109@tonian.com>
Date: Mon, 03 Oct 2011 17:13:24 +0200
From: Benny Halevy <bhalevy@tonian.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
References: <20110919131415.GB32498@fieldses.org> <1316438143-1057-4-git-send-email-bfields@redhat.com> <4E89CA1C.4050107@tonian.com> <20111003145749.GB5524@pad.fieldses.org>
In-Reply-To: <20111003145749.GB5524@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-10-03 16:57, J. Bruce Fields wrote:
> On Mon, Oct 03, 2011 at 04:43:40PM +0200, Benny Halevy wrote:
>> Bruce, it seems with this patch, doing si_opaque.so_id = current_stateid
>> makes all stateid's unique, regardless of their type.
>> Is find_stateid_by_type still needed?
>>
>> And if the opaque part of the stateid isn't unique,
>> shouldn't find_stateid_by_type go over the hash bucket by itself
>> to look for other stateid's sharing the same opaque but having
>> the type it is looking for?
> 
> Stateid's have actually always been unique--they'd have to be, since
> e.g. READ doesn't come with any indication of which type of stateid
> you're being given.  All find_stateid_by_type() does is fail when it
> doesn't find something of the right type.
> 

So I'm still confused.  That's what I thought.
So in what cases find_stateid that find_stateid_by_type calls
will find a stateid structure with a non-matching sc_type?

Benny

> I did think at the time that find_stateid_by_type() was a confusing name
> for that reason, but couldn't come up with a better idea.  Maybe it
> should be find_stateid_of_type() or find_stateid_if_type()....
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
