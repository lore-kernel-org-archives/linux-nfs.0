Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:44915 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409Ab0KPUyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 15:54:38 -0500
Date: Tue, 16 Nov 2010 15:54:36 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Valentijn Sessink <valentyn@blub.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
Message-ID: <20101116205436.GA4595@merit.edu>
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>
 <4CE2AA3B.6070302@openoffice.nl>
 <4CE2DF2D.9070603@blub.net>
 <20101116201753.GB4482@merit.edu>
 <577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  Before we go too far down the NM path of no return, I was under the
  impression that some applications require the host's name on the localhost
  entries in /etc/hosts.  That's why NM puts it there.
  
  There's nothing invalid about having a hostname on the localhost entries
  in /etc/hosts, is there?
  
  So I wonder if removing NM is really the solution here.

No, it's not.  I just like to complain about NM.

The original problem was that rpc.svcgssd couldn't figure out the correct
kerberos realm.  The fix in this particular case, I think, is to set the
realm explicitly in /etc/idmapd.conf.

But a more general problem is that if you don't set a realm in
/etc/idmapd.conf, the fallback is to whatever is returned by gethostname().
Shouldn't the fallback be to what is in krb5.conf?

In general, I think it's a mistake to assume that a host's security realm is
the same as its dns domain, especially given host mobility, the lack of
security in dns, and the existence of other methods (krb5.conf) to determine
the security realm.
