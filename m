Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44963 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622AbbFRSBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2015 14:01:42 -0400
Date: Thu, 18 Jun 2015 14:01:41 -0400
To: Dennis Jacobfeuerborn <dennisml@conversis.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS server startup hangs for 60 seconds
Message-ID: <20150618180141.GA21212@fieldses.org>
References: <5582B009.9090901@conversis.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5582B009.9090901@conversis.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2015 at 01:48:25PM +0200, Dennis Jacobfeuerborn wrote:
> Hi,
> when I start nfs-server.service on a CentOS 7 system it takes 60 seconds
> until the nfsd finally is up.

How exactly are you testing that?  (What are you using to decide when
nfsd is up?)

--b.

> Looking at the process list I see a
> process 'systemd-tty-ask-password-agent' running which goes away after
> the 60 seconds the startup requires soI suspect something in the startup
> process is trying to get a password.
> 
> Does anyone have an idea what the reason could be for this and how I can
> get rid of this delay?
> 
> Regards,
>   Dennis
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
