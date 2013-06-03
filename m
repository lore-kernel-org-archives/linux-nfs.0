Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:20142 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755323Ab3FCCB7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jun 2013 22:01:59 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130603005219.20080.1927.stgit@notabene.brown>
Date: Sun, 2 Jun 2013 22:01:50 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:

> As you probably know, since 3.7 (I think) Linux NFS has explicitly
> asked for machine credentials for certain requests rather than asking
> for root credentials as is previously did.
> This causes a regression for people who don't have any machine
> credentials configured and use "gssd -n".
> 
> I gather this was discussed on the mailing list earlier this year but
> not resolved.

It's resolved in 3.10-rc.

The kernel will attempt to use krb5i for lease management operations.  If that fails because there is no keytab available, it falls back to using AUTH_SYS.


> I would like to re-awaken the issue and offer a resolution (which has
> been tested and found effective by a customer).
> 
> Hence these three patches.  The first two are minor issues that I
> stumbled over while trying to understand the problem and are not
> critical but probably should be fixed.
> 
> The third addresses the above mentioned issue.  It introduces a
> variable "machine_uses_root_credentials" which is similar to the
> current "root_uses_machine_credentials".  It also adds a "-N" flag to
> set this variable.
> 
> I'm not certain what the defaults should be.  For backward
> compatibility it would be best if '-n' set the this new variable as
> well as clearing the old one, but then I'm not sure what exactly -N
> should do.
> 
> Comments welcome.
> 
> Thanks,
> NeilBrown
> 
> 
> 
> ---
> 
> Neil Brown (3):
>      krb5_utils: remove redundant array size.
>      krb5_util: don't give up on machine credential if hostname not available.
>      gssd: add -N option to use root credentials as machine credentials.
> 
> 
> utils/gssd/gssd.c      |    9 ++++++---
> utils/gssd/gssd.h      |    1 +
> utils/gssd/gssd.man    |   13 ++++++++++++-
> utils/gssd/gssd_proc.c |   12 +++++++-----
> utils/gssd/krb5_util.c |   10 +++++++---
> 5 files changed, 33 insertions(+), 12 deletions(-)
> 
> -- 
> Signature
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




