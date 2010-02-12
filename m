From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: make nfs_{nfs,mount}_proto set errno on error
Date: Fri, 12 Feb 2010 14:36:02 -0500
Message-ID: <4B75ADA2.2010204@RedHat.com>
References: <1265727888-4613-1-git-send-email-jlayton@redhat.com> <1265727888-4613-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905Ab0BLTgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 14:36:08 -0500
In-Reply-To: <1265727888-4613-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/2010 10:04 AM, Jeff Layton wrote:
> Have nfs_nfs_proto and nfs_mount_proto set errno to EPROTONOSUPPORT on
> error. This helps default_value to display sane warning messages.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed... 
