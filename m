From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] gssd: on krb5 upcall, have gssd send a more granular
 error code
Date: Tue, 12 Jan 2010 07:36:37 -0500
Message-ID: <4B4C6CD5.9070703@RedHat.com>
References: <1262875355-4522-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292Ab0ALMgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2010 07:36:40 -0500
In-Reply-To: <1262875355-4522-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/07/2010 09:42 AM, Jeff Layton wrote:
> Currently if a krb5 context expires, GSSAPI authenticated RPC calls
> start returning error (-EACCES in particular). This is bad when someone has
> a long running job that's doing filesystem ops on a krb5 authenticated NFS
> mount and just happens to forget to redo a 'kinit' in time.
> 
> The existing gssd always does a downcall with a '-1' error code if there
> are problems, and the kernel always ignores this error code. Begin to
> fix this by having gssd distinguish between someone that has no
> credcache at all, and someone who has an expired one. In the case where
> there is an existing credcache, have gssd downcall with an error code of
> -EKEYEXPIRED. If there's not a credcache, then downcall with an error of
> -EACCES.
> 
> We can then have the kernel use this error code to handle these
> situations differently.
> 
Committed...

steved.
