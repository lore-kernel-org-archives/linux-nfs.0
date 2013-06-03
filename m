Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35994 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253Ab3FCBAt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Jun 2013 21:00:49 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Mon, 03 Jun 2013 11:00:21 +1000
Subject: [PATCH 0/3] Various gssd fixes including machine-credential issue.
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Message-ID: <20130603005219.20080.1927.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As you probably know, since 3.7 (I think) Linux NFS has explicitly
asked for machine credentials for certain requests rather than asking
for root credentials as is previously did.
This causes a regression for people who don't have any machine
credentials configured and use "gssd -n".

I gather this was discussed on the mailing list earlier this year but
not resolved.

I would like to re-awaken the issue and offer a resolution (which has
been tested and found effective by a customer).

Hence these three patches.  The first two are minor issues that I
stumbled over while trying to understand the problem and are not
critical but probably should be fixed.

The third addresses the above mentioned issue.  It introduces a
variable "machine_uses_root_credentials" which is similar to the
current "root_uses_machine_credentials".  It also adds a "-N" flag to
set this variable.

I'm not certain what the defaults should be.  For backward
compatibility it would be best if '-n' set the this new variable as
well as clearing the old one, but then I'm not sure what exactly -N
should do.

Comments welcome.

Thanks,
NeilBrown



---

Neil Brown (3):
      krb5_utils: remove redundant array size.
      krb5_util: don't give up on machine credential if hostname not available.
      gssd: add -N option to use root credentials as machine credentials.


 utils/gssd/gssd.c      |    9 ++++++---
 utils/gssd/gssd.h      |    1 +
 utils/gssd/gssd.man    |   13 ++++++++++++-
 utils/gssd/gssd_proc.c |   12 +++++++-----
 utils/gssd/krb5_util.c |   10 +++++++---
 5 files changed, 33 insertions(+), 12 deletions(-)

-- 
Signature

