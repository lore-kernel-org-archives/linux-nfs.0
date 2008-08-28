From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/3] Minor mountd.c cleanup
Date: Thu, 28 Aug 2008 11:36:32 -0400
Message-ID: <48B6C600.1010505@RedHat.com>
References: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu> <1218422830-5465-2-git-send-email-bfields@citi.umich.edu> <1218422830-5465-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Bruce Fields <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45790 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753572AbYH1Pii (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 11:38:38 -0400
In-Reply-To: <1218422830-5465-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> I find it more readable to have the normal (non-error) case unindented,
> and to keep conditionals relatively simple, as is the usual kernel
> style.  Fix some inconsistent indentation while we're there.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Committed...

steved.
