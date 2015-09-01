Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:58311 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753917AbbIANz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 09:55:29 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: <linux-nfs@vger.kernel.org>, <etmsys@rit.edu>
Subject: Re: [PATCH] nfsd: deal with DELEGRETURN racing with CB_RECALL
References: <1441037201-78787-1-git-send-email-aweits@rit.edu>
	<20150901091842.7c40adf3@tlielax.poochiereds.net>
Date: Tue, 01 Sep 2015 09:55:28 -0400
In-Reply-To: <20150901091842.7c40adf3@tlielax.poochiereds.net> (Jeff Layton's
	message of "Tue, 1 Sep 2015 09:18:42 -0400")
Message-ID: <m2mvx6jlbj.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Yeah, there will always be some potential for a CB_RECALL/DELEGRETURN
> race since the former is driven by the server and the latter by the
> client.

I believe there are some client differences to account for as well. i.e. when
does the client "unhash" the delegation? Before the DELEGRETURN is sent,
or after the response comes back?

> What error are you usually getting back from the client when you see
> this happen? NFS4ERR_BAD_STATEID? If so, then maybe we should confine
> this check to that error case?

Usually EBADHANDLE. I actually had a version of this patch where it was
confined to those cases. My rationale in changing it was that continuing
to solicit the return of the delegation when we have it is pointless.

i.e. RFC5661 20.2.4:

"...The recall is not complete until the delegation is returned using a
 DELEGRETURN operation."

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
