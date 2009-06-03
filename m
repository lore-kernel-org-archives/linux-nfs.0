From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 08/10] nfs-utils: add IPv6 support to nfssvc_setfds
Date: Wed, 03 Jun 2009 16:20:22 -0400
Message-ID: <4A26DB06.30500@RedHat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com> <1244058763-10352-9-git-send-email-jlayton@redhat.com> <4D598E93-E9CE-4AA7-8289-169FD85EF05B@oracle.com> <4A26DA3B.3090404@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34823 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbZFCUX2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 16:23:28 -0400
In-Reply-To: <4A26DA3B.3090404-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Steve Dickson wrote:
>>> +            xlog(L_ERROR, "unable to set IPV6_V6ONLY: "
>>> +                "errno %d (%s)\n", errno, strerror(errno));
>> I'm still looking at the other patches, but I notice you could use %m
>> here too.
> I kinda like having both... the errno *and* the error string...
> 
Ah... I see your point... sometimes '%m' is used and sometimes 
strerror() is used... I'll clean that up... and switch 
everything to strerror().... 

steved.
