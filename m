Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:35861 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab1ITX3W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 19:29:22 -0400
Date: Wed, 21 Sep 2011 09:29:16 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201109202329.p8KNTGUW016967@bari.maths.usyd.edu.au>
To: Trond.Myklebust@netapp.com
Subject: Re: Please support NSF squashing multiple groups
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1316559903.15093.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Trond,

> ... what you are proposing is a potential security problem.

Yes, definitely: if ever such options were implemented, then potential
users should evaluate whether using them (or not using them) introduced
a security vulnerability. That said...

NFS security traditionally depended on UIDs and GIDs being "in sync"
between the server and the clients. My proposal simply would enforce
all GIDs to be "in sync" with the UID, as per server view; most often
that would be a no-op (except for accesses by setuid or setgid apps).

Seems that kerberos has no concept of groups but only of "principals"
which are somewhat like UIDs. My proposal would bring NFSv3 in line
with the NFSv4+krb model of "only the UID matters".

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
