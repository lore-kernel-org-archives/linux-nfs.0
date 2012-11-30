Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:37054 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933372Ab2K3Q7O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 11:59:14 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Fri, 30 Nov 2012 11:59:12 -0500
From: David Quigley <dpquigl@davequigley.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Casey Schaufler <casey@schaufler-ca.com>, <trond.myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, <selinux@tycho.nsa.gov>,
        <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <20121130165544.GF614@fieldses.org>
References: <50B7FEFB.30109@schaufler-ca.com>
 <579e850139bd3d5a0c9155270d5d9fbe@countercultured.net>
 <50B810D2.2000401@schaufler-ca.com>
 <3ea3f70e0a5cdb99f1594019b7bd619d@countercultured.net>
 <20121130121437.GC614@fieldses.org>
 <607a8005d6c33a19c53b5ede29d81ef5@countercultured.net>
 <5170c3bd8900c36b372217af96e5e764@countercultured.net>
 <50B8B47F.5050206@tycho.nsa.gov>
 <c00cec058c2bd0cb7104a53ca680f6cb@countercultured.net>
 <50B8B9BF.7000802@tycho.nsa.gov> <20121130165544.GF614@fieldses.org>
Message-ID: <dd7dc9e3fcd4fe2ddc3a0678c6377c4b@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2012 11:55, J. Bruce Fields wrote:
> On Fri, Nov 30, 2012 at 08:50:55AM -0500, Stephen Smalley wrote:
>> On the SELinux side, we don't require CAP_MAC_ADMIN to set the
>> SELinux attribute on a file in the normal case, only when the
>> SELinux attribute is not known to the security policy yet.  So
>> granting CAP_MAC_ADMIN there means that a client will be able to set
>> security contexts on files that are unknown to the server.  I guess
>> that might even be desirable in some instances where client and
>> server policy are different.
>
> Note (as you probably know) this first pass at labeled NFS only lets 
> us
> label files, not rpc calls--if we want the server to know who's doing
> something (beyond the information the rpc headers already carry), 
> we'll
> need to implement rpcsec_gss v3, and that's a project for another 
> day.
>
> I've been assuming that makes server-side enforcement less useful for
> now.
>
> --b.

Ideally what will happen is that when we get RPCSECGSSv3 in we'll set 
the security context in the same place that we set uid and gid for the 
process in the auth code. Until then you're right server side 
enforcement really isn't possible because we have whatever context the 
kernel gives to the thread being our security context. In the SELinux 
case this is the all powerful kernel_t in the smack case its the floor 
context.

Dave
