Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:15047 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753844AbbIAOs3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 10:48:29 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: <linux-nfs@vger.kernel.org>, <etmsys@rit.edu>
Subject: Re: [PATCH] nfsd: deal with DELEGRETURN racing with CB_RECALL
References: <1441037201-78787-1-git-send-email-aweits@rit.edu>
	<20150901091842.7c40adf3@tlielax.poochiereds.net>
	<m2mvx6jlbj.fsf@discipline.rit.edu>
Date: Tue, 01 Sep 2015 10:48:27 -0400
In-Reply-To: <m2mvx6jlbj.fsf@discipline.rit.edu> (Andrew W. Elble's message of
	"Tue, 01 Sep 2015 09:55:28 -0400")
Message-ID: <m27foajiv8.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I should probably state what I'm currently chasing:

1.) Somehow, delegations wind up on the cl_revoked list at the server.
2.) The server continually asserts SEQ4_STATUS_RECALLABLE_STATE_REVOKED.
3.) The client for some reason doesn't have anything to give the server
    to satisfy it.

I speculate that this patch will assist in making this go away - I'm
just not 100% sure of all the conditions that result in making #1 possible.
(Enough recalls backed up on the callback slot on the same filehandle
stacking timeouts/retries and resultant path down errors to exceed lease
time?). Unfortunately this problem seems to always occur at ~1AM - and
obtaining a network capture of the problem in action has been elusive.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
