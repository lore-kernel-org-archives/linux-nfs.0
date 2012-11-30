Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46363 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848Ab2K3Qzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Nov 2012 11:55:49 -0500
Date: Fri, 30 Nov 2012 11:55:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: David Quigley <dpquigl@davequigley.com>,
        Casey Schaufler <casey@schaufler-ca.com>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
Message-ID: <20121130165544.GF614@fieldses.org>
References: <50B7FEFB.30109@schaufler-ca.com>
 <579e850139bd3d5a0c9155270d5d9fbe@countercultured.net>
 <50B810D2.2000401@schaufler-ca.com>
 <3ea3f70e0a5cdb99f1594019b7bd619d@countercultured.net>
 <20121130121437.GC614@fieldses.org>
 <607a8005d6c33a19c53b5ede29d81ef5@countercultured.net>
 <5170c3bd8900c36b372217af96e5e764@countercultured.net>
 <50B8B47F.5050206@tycho.nsa.gov>
 <c00cec058c2bd0cb7104a53ca680f6cb@countercultured.net>
 <50B8B9BF.7000802@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B8B9BF.7000802@tycho.nsa.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 30, 2012 at 08:50:55AM -0500, Stephen Smalley wrote:
> On the SELinux side, we don't require CAP_MAC_ADMIN to set the
> SELinux attribute on a file in the normal case, only when the
> SELinux attribute is not known to the security policy yet.  So
> granting CAP_MAC_ADMIN there means that a client will be able to set
> security contexts on files that are unknown to the server.  I guess
> that might even be desirable in some instances where client and
> server policy are different.

Note (as you probably know) this first pass at labeled NFS only lets us
label files, not rpc calls--if we want the server to know who's doing
something (beyond the information the rpc headers already carry), we'll
need to implement rpcsec_gss v3, and that's a project for another day.

I've been assuming that makes server-side enforcement less useful for
now.

--b.
