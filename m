From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] Support for Numeric Representations of UIDs and
 GIDs.
Date: Wed, 18 Aug 2010 14:20:53 -0400
Message-ID: <20100818182053.GB13050@fieldses.org>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60031 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352Ab0HRSW5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 14:22:57 -0400
In-Reply-To: <1282073925-18707-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 17, 2010 at 03:38:43PM -0400, Steve Dickson wrote:
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

Why did you decide to impose that restriction?

--b.
