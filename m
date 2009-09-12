From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH RFC 02/13] sunrpc: ntoh -> be*_to_cpu
Date: Sat, 12 Sep 2009 15:00:01 +0100
Message-ID: <20090912140001.GD5858@ZenIV.linux.org.uk>
References: <4A82DC7B.3090600@panasas.com> <1250090508-9572-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60570 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713AbZILPQV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Sep 2009 11:16:21 -0400
In-Reply-To: <1250090508-9572-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 12, 2009 at 06:21:48PM +0300, Benny Halevy wrote:
> ntohl is already defined as be32_to_cpu.
> be64_to_cpu has architecture specific optimized implementations.

>  static inline __be32 *
>  xdr_decode_hyper(__be32 *p, __u64 *valp)
>  {
> -	*valp  = ((__u64) ntohl(*p++)) << 32;
> -	*valp |= ntohl(*p++);
> -	return p;
> +	*valp = be64_to_cpup((__be64 *)p);
> +	return p + 2;
>  }

Erm...  Who has promised you that p will be 64bit-aligned?
