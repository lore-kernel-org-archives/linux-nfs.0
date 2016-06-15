Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:37188 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751867AbcFOTgu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 15:36:50 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
	<20160615192116.GA3848@fieldses.org>
Date: Wed, 15 Jun 2016 15:36:48 -0400
In-Reply-To: <20160615192116.GA3848@fieldses.org> (J. Bruce Fields's message
	of "Wed, 15 Jun 2016 15:21:16 -0400")
Message-ID: <m2k2hqw8fj.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> I take it you've tested these and verified delegations aren't getting
> lost?

These patches have been running in our environment (based on 4.1.22)
for quite a bit of time now with no lost delegations.

> Are there client changes needed as well, or is the client already
> doing the right thing?

Change for client was taken as commit 99ade3c71b1e40e7174d6527709399a87f3d05e0

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
