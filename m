From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [grumble] connected UDP sockets [grumble] Solaris [grumble]
Date: Thu, 23 Oct 2008 15:47:06 +1100
Message-ID: <490001CA.8010801@melbourne.sgi.com>
References: <18687.63003.966163.267177@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:48986 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751318AbYJWEpR (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 00:45:17 -0400
In-Reply-To: <18687.63003.966163.267177-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
>
> Much as it pains me to say this, maybe we just need to treat UDP as
> legacy for all protocols (PORTMAP, MOUNT, NLM, NSM), not just NFS.
> None of these problems occur with TCP.  TCP does have a slightly
> higher overhead for simple transactions, but it is a cost that is
> unlikely to be noticeable in reality.
>
>
> Thoughts?
>
>   
I see only two reasons to keep any UDP support at all in either client
or server.

a) legacy compatibility, for toy/broken/antique clients/servers/firewalls

b) on the server, supporting broadcast RPC to/through the portmapper

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
Be like the squirrel.
I don't speak for SGI.

