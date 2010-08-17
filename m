From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] Support for Numeric Representations of UIDs and GIDs.
Date: Tue, 17 Aug 2010 14:51:58 -0500
Message-ID: <4C6AE85E.4000305@excfb.com>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao101.cox.net ([68.230.240.7]:43360 "EHLO
	eastrmmtao101.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab0HQTw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 15:52:28 -0400
In-Reply-To: <1282073925-18707-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> In recent NFS v2/v3 to v4 transitions, one of the sticking 
> points have been that fact v4 uses strings in the format
> of "user@domain" instead of 32bit integers for uids and 
> gids.
>
> When the string can not be mapped, its mapped to the 'nobody'
> user which is not optimal for things like backup servers and
> such where the ids will not be know by both sides.
>
> So this patch series enables the server to send out numeric 
> string of uids and gids that do not have the '@domain' part.
> The series also adds functionality to the client that parse these
> type of strings and will use the numeric representation
> of the ids iff the id exists on the client, which is 
> sightly different that Solaris. Solaris dose not have that
> "id must exist" restriction.
>   

No, Solaris does have that restriction.


> Steve Dickson (2):
>   Teach clients to map numeric strings into valid uids and gids.
>   Add server support to use of numeric strings for uid and gids.
>
>  utils/idmapd/idmapd.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 51 insertions(+), 1 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

