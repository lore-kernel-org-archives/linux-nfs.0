From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH nfs-utils] Ensure statd gets started if required when
 non-root user mounts an NFS filesystem.
Date: Mon, 01 Dec 2008 14:28:19 -0500
Message-ID: <49343AD3.3010206@RedHat.com>
References: <18729.61495.911485.826997@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42132 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYLATaa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Dec 2008 14:30:30 -0500
In-Reply-To: <18729.61495.911485.826997-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> openSUSE-11.1 betas rely in mount.nfs to start statd when required.
> This helped me discover that it doesn't work when a non-root user is
> mounting a filesystem as the setuid status gets lots.
> This patch fixes it.
Committed... 

steved.
