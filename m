Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailin.vu.nl ([130.37.164.19]:8469 "EHLO mailin.vu.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752871Ab3FEOKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 10:10:36 -0400
Message-ID: <51AF459A.1040609@vu.nl>
Date: Wed, 5 Jun 2013 16:05:14 +0200
From: "E.G. Keizer" <E.G.Keizer@vu.nl>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First I would like to wholeheartedly support Neil Brown's comment. We at the
Vrije Universiteit in Amsterdam (NL) also have the situation where the Kerberos
administrator does not hand out machine credentials. A lot of Linux users from
the Faculty of Sciences depend on the functionality that lets them access
the NFS file servers with only their user credentials.

Secondly I would like to make a remark on basing client id's on the system's kerberos principal's name.
That same faculty, in the times it had its own IT department, used an identical keytab for
all Linux workstations, using the principal names "[nfs|root|host]/workstation@FEW.VU.NL".
I understand this would lead to severe problems when the client id (co_ownerid) is based
solely in the systems root principal name.

It seems to me that the issues about the client id look like a bag of worms. I've seen that the
newest standard `requires' integrity protection for client id exchanges. I doubt
that that will help when the source code of the NFS client is known and
the client id is guessable. The wisest thing might be to offer different options
and let the administrators pick the one they like best?

Regards,

Ed Keizer
IT department
Vrije Universiteit
Amsterdam
NL
