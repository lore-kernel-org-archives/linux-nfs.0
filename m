Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20569 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755122Ab1BNRUU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 12:20:20 -0500
Subject: Re: pNFS files server?
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <DE966DA98A4ABE438D726BDF1699CF61043FE56802@MX05A.corp.emc.com>
Date: Mon, 14 Feb 2011 12:20:19 -0500
Cc: <linux-nfs@vger.kernel.org>
Message-Id: <22B76C5D-2028-40A5-8AF2-CABEEB1C48EE@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com> <1297443279-19813-8-git-send-email-iisaman@netapp.com> <DE966DA98A4ABE438D726BDF1699CF61043FE56802@MX05A.corp.emc.com>
To: <Daniel.Muntz@emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The GFS2 pnfs files server code has not moved forward for a while as we have all spent our time on the pnfs files client.  The pnfsd-files branch of benny's tree git://linux-nfs.org/~bhalevy/linux-pnfs.git has the latest code.

-->Andy

On Feb 11, 2011, at 5:15 PM, <Daniel.Muntz@emc.com> wrote:

> Is anyone still working on a freely-available pNFS files server for Linux?  I've had a couple of inquiries recently about spNFS, and would like to be able to point people to recent work.  Last I knew, Andy's GFS2-based pnfs files server work was the POR for delivering a server.  Is that work still going on, and if so, is there usable code I can point to?
> 
>  Thanks,
>  Dan--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

