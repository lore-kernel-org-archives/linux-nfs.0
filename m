Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:36452 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932791AbcFOUOA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 16:14:00 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, tibbs@math.uh.edu
Subject: Re: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
	<20160615192116.GA3848@fieldses.org>
	<20160615192415.GB3848@fieldses.org>
Date: Wed, 15 Jun 2016 16:13:58 -0400
In-Reply-To: <20160615192415.GB3848@fieldses.org> (J. Bruce Fields's message
	of "Wed, 15 Jun 2016 15:24:15 -0400")
Message-ID: <m2d1niw6pl.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> (Also: remind me what they symptoms ("lost delegation problems")
> actually were from the point of view of users?  Does the client end up
> resending failing DELEGRETURNS and failing to make progress?)

Client endlessly loops in state recovery with no path to recovery.
I'm guessing Jason is seeing some of this as well.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
