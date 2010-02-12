From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: return error if proto= option specified IPv6
 when IPv6 isn't supported (try #2)
Date: Fri, 12 Feb 2010 14:36:23 -0500
Message-ID: <4B75ADB7.9060201@RedHat.com>
References: <1265727888-4613-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755174Ab0BLTg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 14:36:28 -0500
In-Reply-To: <1265727888-4613-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/2010 10:04 AM, Jeff Layton wrote:
> Right now, there's nothing that expressly forbids someone from
> specifying proto=tcp6 for instance, even when nfs-utils it built without
> IPv6 support. This may not work well if (for instance) they are using
> NFSv3, since statd won't support IPv6. Explicitly return an error if
> someone specifies an IPv6 proto= or mountproto= option and IPv6 isn't
> supported.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed... 

steved.
