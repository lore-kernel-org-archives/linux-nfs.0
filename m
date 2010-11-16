Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59548 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab0KPVm3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 16:42:29 -0500
Subject: Re: Strange rpc.svcgssd behavior
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101116205436.GA4595@merit.edu>
Date: Tue, 16 Nov 2010 16:42:09 -0500
Cc: Valentijn Sessink <valentyn@blub.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <44C0977F-DBD6-4F87-B3A5-B2B66C784312@oracle.com>
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com> <4CE2AA3B.6070302@openoffice.nl> <4CE2DF2D.9070603@blub.net> <20101116201753.GB4482@merit.edu> <577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com> <20101116205436.GA4595@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 16, 2010, at 3:54 PM, Jim Rees wrote:

> Chuck Lever wrote:
> 
>  Before we go too far down the NM path of no return, I was under the
>  impression that some applications require the host's name on the localhost
>  entries in /etc/hosts.  That's why NM puts it there.
> 
>  There's nothing invalid about having a hostname on the localhost entries
>  in /etc/hosts, is there?
> 
>  So I wonder if removing NM is really the solution here.
> 
> No, it's not.  I just like to complain about NM.
> 
> The original problem was that rpc.svcgssd couldn't figure out the correct
> kerberos realm.  The fix in this particular case, I think, is to set the
> realm explicitly in /etc/idmapd.conf.

It's having trouble determining the NFS server's hostname.  It needs to find the right nfs/your.host key in /etc/krb5.keytab.

I don't know if realm self-discovery is an issue too.

> But a more general problem is that if you don't set a realm in
> /etc/idmapd.conf, the fallback is to whatever is returned by gethostname().
> Shouldn't the fallback be to what is in krb5.conf?

> In general, I think it's a mistake to assume that a host's security realm is
> the same as its dns domain, especially given host mobility, the lack of
> security in dns, and the existence of other methods (krb5.conf) to determine
> the security realm.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




