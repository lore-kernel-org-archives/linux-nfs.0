From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Use xlog() for statd/sm-notify syslogging
Date: Tue, 24 Nov 2009 09:17:33 -0500
Message-ID: <4B0BEAFD.1040701@RedHat.com>
References: <20091123215833.26806.28348.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932966AbZKXORb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 09:17:31 -0500
In-Reply-To: <20091123215833.26806.28348.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/23/2009 05:00 PM, Chuck Lever wrote:
> Steve -
> 
> As requested, here are the two patches that convert statd and
> sm-notify to use the nfs-utils' xlog() facility, replacing local
> variants.
> 
> ---
Committed and thanks for breaking them up!

Question, How did you differentiate between D_CALL and D_GENERAL?

I'm thinking about rolling both those types into a new xlog_debug()
function... since that what those types seem to be... 

steved.
