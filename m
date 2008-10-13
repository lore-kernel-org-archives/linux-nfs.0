From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [git-KezNCC8cqm5ZN1qrTdtDg5Vzexx5G7lz@public.gmane.org: all 5e2e7721... NFS: fix
	nfs_parse_ip_address() corner case results]
Date: Mon, 13 Oct 2008 15:54:32 -0400
Message-ID: <1223927672.15530.5.camel@localhost>
References: <20081013191507.GA31876@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17869 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbYJMTzN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2008 15:55:13 -0400
In-Reply-To: <20081013191507.GA31876@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-10-13 at 15:15 -0400, J. Bruce Fields wrote:
> I'm seeing cthon failures on your linux-mm branch again, this time
> intermittent--and maybe only on v4?  I haven't tried to look any closer
> yet.
> 
> --b.

I don't appear to be able to reproduce that. Do you have a tcpdump?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
