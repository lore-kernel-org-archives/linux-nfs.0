From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] set +x on t0001-statd-basic-mon-unmon.sh
Date: Thu, 15 Apr 2010 08:52:26 -0400
Message-ID: <4BC70C0A.60408@RedHat.com>
References: <1271022685-27800-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042Ab0DOMwr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 08:52:47 -0400
In-Reply-To: <1271022685-27800-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/11/2010 05:51 PM, Mike Frysinger wrote:
> The test framework tries to exec this script, but it fails because it
> lacks the +x bit.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
committed...

steved.
