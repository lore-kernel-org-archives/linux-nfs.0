From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Wed, 10 Dec 2008 10:04:45 -0500
Message-ID: <1228921485.2914.14.camel@heimdal.trondhjem.org>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com>
	 <4917C380.9040703@linux.vnet.ibm.com>
	 <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com>
	 <491AFE09.2010803@bull.net>
	 <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com>
	 <4921AF45.4070009@bull.net>
	 <AF604C91-2F1B-48A3-8E1D-84D5CBBB2856@oracle.com>
	 <493E6680.2050904@bull.net>
	 <9F0B9CDF-DDA7-4752-B08D-EC43A3D664E1@oracle.com>
	 <20081209210407.GE8596@fieldses.org>  <493FD6C0.7070906@bull.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Frank S Filz <ffilz@us.ibm.com>
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57188 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbYLJPE6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 10:04:58 -0500
In-Reply-To: <493FD6C0.7070906@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-12-10 at 15:48 +0100, Le Rouzic wrote:

>   Hi,
>   I joined at this mail two wireshark traces. One when it was working 
> (trace_2.6.27-rc3)
>   and the other one with the error(trace_2.6.28-rc2).
>   It looks to come because the operation NVERIFY which was returned 
> NFS_OK before
>   now returns NFS4ERR_SAME making AIX retrying the readdir with an 
> incremented cookie .

While there may be a server bug here, it definitely is wrong for the AIX
client to be sending a READDIR request with a cookie argument of '1'.
RFC3530 is adamant that

        For READDIR arguments, cookie values of 1 and 2 should not be
        used and for READDIR results cookie values of 0, 1, and 2 should
        not be returned.

That said, I'd love to understand why the server replied to the first
READDIR request with no entries, and yet with EOF not set. Is it perhaps
because the 'dircount' was too small, Bruce?

Cheers
  Trond

