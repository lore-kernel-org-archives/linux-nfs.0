Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:51377 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031828Ab2COTuH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 15:50:07 -0400
Date: Thu, 15 Mar 2012 15:49:55 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] nfsd: Warn when no servers are specified on the
 command line
Message-ID: <20120315194955.GA20262@umich.edu>
References: <1331832223-20737-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1331832223-20737-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  When the number of servers are not specified
  on the command, log a warning message that the
  default number of services will be started

  +	} else {
  +		xlog(L_WARNING, "No server number specified. '%d' nfsd will be started",
  +			count);

Sounds like you might not put this in, but if you do, I would word it, "No
server count specified."
