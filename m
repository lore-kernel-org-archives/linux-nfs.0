From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RESTRICTED_STATD
Date: Wed, 27 Aug 2008 06:57:47 -0400
Message-ID: <48B5332B.2040800@RedHat.com>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50509 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524AbYH0LA2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2008 07:00:28 -0400
In-Reply-To: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi guys-
> 
> I was wondering if anyone ever builds nfs-utils with RESTRICTED_STATD
> undefined these days.  It seems totally insecure to do.  Is it still
> necessary to keep this?
> 
> It would be easier to understand, update, and test the logic in
> utils/statd/monitor.c (IPv6-wise) if we could remove the unused parts of
> this code.
> 
> I propose removing RESTRICTED_STATD, leaving in the secure version of
> the code permanently and removing the insecure parts that are left out
> when RESTRICTED_STATD is undefined.
> 
> Thoughts?
I seem to remember enabling RESTRICTED_STATD cause problems with
portmapper and kernel interactions which causes me to turn it off...
So if we do permanently turn on the code, let make sure lock recover
and such still work...

steved.
 
