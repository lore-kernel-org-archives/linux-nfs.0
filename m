Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab3GAHH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 03:07:26 -0400
Message-ID: <1372662428.2974.21.camel@cr0>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
From: Cong Wang <amwang@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Mon, 01 Jul 2013 15:07:08 +0800
In-Reply-To: <1372347477.2436.7.camel@bwh-desktop.uk.level5networks.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-5-git-send-email-amwang@redhat.com>
	 <1372347477.2436.7.camel@bwh-desktop.uk.level5networks.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-06-27 at 16:37 +0100, Ben Hutchings wrote:
> Most of the other functions work on IPv6 addresses without
> CONFIG_IPV6;
> why should this be different? 

Save few cycles for !CONFIG_IPV6? :-/


