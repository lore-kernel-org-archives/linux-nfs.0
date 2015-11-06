Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:34267 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030447AbbKFBOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 20:14:09 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <jlayton@poochiereds.net>
Subject: Re: [PATCH RFCv2] nfsd: fix race with open / open upgrade stateids
References: <1446657225-72903-1-git-send-email-aweits@rit.edu>
	<20151105212108.GH9210@fieldses.org>
	<m2a8qsru1m.fsf@discipline.rit.edu>
	<20151105220346.GK9210@fieldses.org>
Date: Thu, 05 Nov 2015 20:14:09 -0500
In-Reply-To: <20151105220346.GK9210@fieldses.org> (J. Bruce Fields's message
	of "Thu, 5 Nov 2015 17:03:46 -0500")
Message-ID: <m2y4ecoroe.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> OK.  Just to make sure, I checked again, and I was indeed testing with
> your v2 (on top of some patches of my own which I'm fairly certain
> weren't the cause, but I'll double check that as well).

Definitely not you - somehow my local repo I built the email off of had a
different commit than the one our tests were built/running against. v3
on it's way.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
