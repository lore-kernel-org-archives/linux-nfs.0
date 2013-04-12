Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53786 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553Ab3DLVBC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Apr 2013 17:01:02 -0400
Date: Fri, 12 Apr 2013 17:01:01 -0400
To: nfsv4@ietf.org
Cc: linux-nfs@vger.kernel.org
Subject: unsupported mandatory server features
Message-ID: <20130412210100.GP7081@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm expecting to turn on basic 4.1 support by default on the Linux
server before supporting two mandatory 4.1 features, and looking for
advice on handling that without too much pain to future clients.  I
suspect I'm not the only server in this situation; anyone know what
others are doing?

The features are:

	- State protection (SSV and MACH_CRED): I'm currently returning
	  SERVERFAULT on EXCHANGE_ID's that request this, but this isn't
	  really what SERVERFAULT is for.

	  I'm inclined to switch to ENC_ALG_UNSUPP; that leaves future
	  clients unable to distinguish between servers lacking SSV
	  entirely from those lacking support for a particular
	  algorithm, but in practice I think they'd handle both in the
	  same way anyway.

	- GSS on the backchannel: currently CREATE_SESSION or
	  BACKCHANNEL_CTL will succeed but SEQUENCE will start returning
	  with the CB_DOWN flag set.  I would rather return an error
	  immediately than make the client guess what's going on in
	  recovery.

	  Could I get away with returning ENC_ALG_UNSUPP here too?  It's
	  not entirely logical, but it's also currently illegal for
	  these two operations so its use wouldn't be confused with some
	  other.

Of course my preference would be just to support these features, but
given resource limitations, the lack of interest, and the lack of any
implementation to test against, that doesn't look likely to happen in
the near future.

--b.
