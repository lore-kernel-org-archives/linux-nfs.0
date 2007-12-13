From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 09/38] svc: Add a transport function that checks for
	write space
Date: Thu, 13 Dec 2007 16:33:22 -0500
Message-ID: <20071213213322.GE29496@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233212.15718.69282.stgit@dell3.ogc.int> <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51388 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933437AbXLMVd3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 16:33:29 -0500
In-Reply-To: <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 12, 2007 at 01:10:17PM -0500, Chuck Lever wrote:
> On Dec 11, 2007, at 6:32 PM, Tom Tucker wrote:
>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
>> +	wspace = sk_stream_wspace(svsk->sk_sk);
>> +
>> +	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
>> +		return 0;
>> +	if (required * 2 > wspace)
>> +		return 0;
>
> Since "required" is an int, this test can behave differently than the one 
> it replaces.

If sk_reserved can approach half of 2^31, for example, then surely we
have bigger problems?

--b.
