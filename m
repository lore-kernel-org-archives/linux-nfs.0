From: Alfred von Campe <alfred-sEvqz3X/0QJl57MIdRCFDg@public.gmane.org>
Subject: Re: Intermittent NFS problems with NetApp server
Date: Wed, 11 Mar 2009 23:03:15 -0400
Message-ID: <68D44966-682F-4476-8963-04C427EF8336@von-campe.com>
References: <96B48952-DA6E-457C-AFAF-B8A96A29CDF1@von-campe.com> <1236822196.21941.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp161.iad.emailsrvr.com ([207.97.245.161]:50541 "EHLO
	smtp161.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbZCLDNg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 23:13:36 -0400
In-Reply-To: <1236822196.21941.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 11, 2009, at 21:43, Trond Myklebust wrote:

> In TCP, the send and receive window sizes are values that are  
> negotiated
> dynamically by the sender and receiver. These values depends on all
> sorts of dynamic parameters that measure the current state of the
> network.
> IOW: I can't see how TCP window size could be the problem here: the
> server should be able to cope just fine with a small window size  
> (as all
> TCP streams are required to do).

OK, I was just trying to address the error message from the NetApp.

> How about amending your crontab to do something along the lines of
> [snip]

Excellent ideas.  However, this is running as a user other than root,
so I will have to adjust this slightly, but I know what to try now.
It might be a few days before I see this problem again, but I'll
report back once I have something to report.

Thanks,
Alfred

