From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: disable IPv6 support in nfsd for now
Date: Mon, 14 Sep 2009 14:08:20 -0400
Message-ID: <4AAE8694.4050506@RedHat.com>
References: <1251204736-8343-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932322AbZINSIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 14:08:18 -0400
In-Reply-To: <1251204736-8343-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/25/2009 08:52 AM, Jeff Layton wrote:
> IPv6 support for nfsd was finished before some of the other daemons
> (mountd and statd in particular). That could be a problem in the future
> if someone were to boot a kernel that supports IPv6 serving with an
> older nfs-utils. For now, hardcode the IPv6 switch into the off position
> until the other daemons are functional.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
