Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35686 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3HSOh4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2013 10:37:56 -0400
Date: Mon, 19 Aug 2013 07:37:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Cong Wang <amwang@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Steve French <sfrench@samba.org>,
        Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [Patch net-next v3 7/9] fs: use generic union inet_addr and
 helper functions
Message-ID: <20130819143752.GA12266@infradead.org>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
 <1376907278-26377-8-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1376907278-26377-8-git-send-email-amwang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> @@ -1900,17 +1901,9 @@ srcip_matches(struct sockaddr *srcaddr, struct sockaddr *rhs)
>  {

I think your new sockaddr_equal should be equivalent to to this
srcip_matches, that is it should warn about and return false for unknown
address families.

