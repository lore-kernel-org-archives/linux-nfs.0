Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457Ab3GAHMN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 03:12:13 -0400
Message-ID: <1372662717.2974.23.camel@cr0>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
From: Cong Wang <amwang@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Mon, 01 Jul 2013 15:11:57 +0800
In-Reply-To: <1372347413.2436.6.camel@bwh-desktop.uk.level5networks.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-5-git-send-email-amwang@redhat.com>
	 <1372347413.2436.6.camel@bwh-desktop.uk.level5networks.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-06-27 at 16:36 +0100, Ben Hutchings wrote:
> On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
> [...]
> > -/**
> > - * rpc_cmp_addr - compare the address portion of two sockaddrs.
> > - * @sap1: first sockaddr
> > - * @sap2: second sockaddr
> > - *
> > - * Just compares the family and address portion. Ignores port, but
> > - * compares the scope if it's a link-local address.
> 
> You're removing the scope comparison.

Actually I added the following code in patch 5/5:

+               if (!ipv6_addr_equal(&a->sin6.sin6_addr,
&b->sin6.sin6_addr))
+                       return false;
+               else if
(__ipv6_addr_needs_scope_id(__ipv6_addr_type(&a->sin6.sin6_addr)))
+                       return a->sin6.sin6_scope_id ==
b->sin6.sin6_scope_id;


but I should move it to this patch, otherwise it is hard for review.

Thanks!

