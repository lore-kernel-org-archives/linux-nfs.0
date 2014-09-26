Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay04.ispgateway.de ([80.67.31.38]:44298 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881AbaIZVht convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 17:37:49 -0400
Received: from [91.47.192.41] (helo=zarafa)
	by smtprelay04.ispgateway.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <sb@plzk.de>)
	id 1XXdD0-0003Tn-Bn
	for linux-nfs@vger.kernel.org; Fri, 26 Sep 2014 23:37:46 +0200
Received: from srv1.localhost (localhost [IPv6:::1])
	by zarafa (Postfix) with ESMTP id A6619220064
	for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 23:37:45 +0200 (CEST)
Subject: AW: posix acl to nfs4 acl mapping - status?
From: =?utf-8?Q?Stefan_Bauer?= <sb@plzk.de>
To: =?utf-8?Q?linux-nfs=40vger=2Ekernel=2Eorg?=
	<linux-nfs@vger.kernel.org>
Date: Fri, 26 Sep 2014 23:37:45 +0200
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Message-Id: <zarafa.5425dca9.74f9.5487c582799de56d@srv1.localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----Ursprüngliche Nachricht-----
Von:	Frank Filz <ffilzlnx@mindspring.com>
> I believe the implementation follows this document. I do know that several 
> years ago, we had some significant ACL testing using AIX clients that exposed 
> many issues in the translation.
> 
> Unfortunately, the translation is always doomed to be imperfect, and is 
> probably not suitable for backup-purposes. Any POSIX ACL that includes a mask 
> will certainly be changed to lose that mask (with the CURRENT effect of the 
> mask being applied permanently).

Even though the implementation might not be complete and flags would get lost, i would assume to get at least a different error message than Operation not supported during copy.

I already found a solution for my backup-problem (saving acls in an additional file).

Thanks.

Stefan
