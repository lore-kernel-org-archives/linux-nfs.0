Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60489 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab1CPPbb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 11:31:31 -0400
Date: Wed, 16 Mar 2011 11:31:29 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Judith Flo Gaya <jflo@imppc.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: problem with nfs latency during high IO
Message-ID: <20110316153129.GB12187@merit.edu>
References: <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com>
 <4D7FA11F.5020604@imppc.org>
 <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com>
 <4D7FDB14.6090908@imppc.org>
 <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com>
 <4D7FE0E8.5050701@imppc.org>
 <16BF52F0-4D1A-4B68-ADEE-DC70255A139C@oracle.com>
 <4D80A2DE.2030507@imppc.org>
 <E6EAC031-956D-42E7-AF01-72AD36474E8B@oracle.com>
 <20110316151827.GA12187@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110316151827.GA12187@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim Rees wrote:

  I think 5 is the minimum for dirty_ratio, although this doesn't seem to be
  documented anywhere.  If you want to set it lower, you have to use
  dirty_bytes instead of dirty_ratio.

Never mind, I just looked at the code and the 5% limit seems to have been
removed later.  Last time I looked at this code was 3 years ago.
