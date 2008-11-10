From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Mon, 10 Nov 2008 09:40:43 +0000
Message-ID: <1226310043868@dmwebmail.dmwebmail.chezphil.org>
References: <3EC9A304-36A0-465C-B82A-E3011CC8AD20@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
Cc: "Steve Dickson" <SteveD@redhat.com>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:1893 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754245AbYKJJks (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 04:40:48 -0500
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1KzTGI-0000LE-8l
	for linux-nfs@vger.kernel.org; Mon, 10 Nov 2008 09:40:46 +0000
In-Reply-To: <3EC9A304-36A0-465C-B82A-E3011CC8AD20@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> My preferred solution would involve working around the sync(2) call  
> instead (ie fixing sm-notify so we don't need it, or somehow doing it  
> in the background so it doesn't hold up the boot-up process).

Doing it in the background doesn't really help, as it's the huge blob 
of disk writes that it generates that's the problem as much as the 
elapsed time.  Boot time is more likely to be I/O bound than CPU bound.

BTW, I have written an article about my efforts to speed up booting 
which will should appear at debian-administration.org later today.


Cheers,  Phil.



