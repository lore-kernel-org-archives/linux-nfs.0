Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:41121 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750960Ab2KPE6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Nov 2012 23:58:13 -0500
Message-ID: <50A5C7E4.80902@davequigley.com>
Date: Thu, 15 Nov 2012 23:58:12 -0500
From: Dave Quigley <selinux@davequigley.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: Casey Schaufler <casey@schaufler-ca.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>, trond.myklebust@netapp.com,
        sds@tycho.nsa.gov, linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <50A116F0.5050404@davequigley.com> <20121112160959.GK30713@fieldses.org> <50A16269.4060601@RedHat.com> <50A1A4EE.7030507@davequigley.com> <50A24345.8080309@RedHat.com> <50A31EF5.1050801@davequigley.com> <20121114134535.GD23604@fieldses.org> <624cc90c1bf726d8ff1a1ea0ace5f50f@countercultured.net> <20121114135939.GE23604@fieldses.org> <80f36fef2a58eb538bce28daba3a862a@countercultured.net> <20121114142458.GF23604@fieldses.org> <4f9b24e3942b4a28cd9068d5bc0135fa@countercultured.net> <50A51195.9080004@schaufler-ca.com> <a843eae7d5fa2df4faa99bf5531dcecc@countercultured.net> <50A5B441.70206@schaufler-ca.com> <98ae8bfde2b1967c7db6db1f04ce73b1@countercultured.net>
In-Reply-To: <98ae8bfde2b1967c7db6db1f04ce73b1@countercultured.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> I'm not sure what the proposed hook would be for except to identify it
>> as concerned with nfs. Perhaps the hook could return the names of
>> attributes that it wants nfs to provide.
>>
>
> I'm not quite sure what you're proposing? I'm sure someone would find
> another use for this hook though. The inode_getsecctx hook we made for
> Labeled NFS was already merged because it was needed for providing
> "persistent" label support for sysfs (meaning that it persisted inode
> eviction from memory). The problem is that we have no real way to ask in
> the NFS code if this is an LSM that can be used with Labeled NFS. In the
> xattr code we have the new ismaclabel hook we add which allows us to
> verify the xattr used as belonging to a label based LSM however we need
> an xattr from userspace for that. The reason this is required is that
> the server will need to fill out its capability mask to indicate it
> supports security labeling. In addition the client also needs to know if
> its running a security label based LSM because it will need to mask out
> the label fattr bit from its getattr calls if it doesn't support it. We
> can override this in SELinux by giving it a context mount but if we
> don't then it will need to know whether or not to be pulling security
> labels back.
>


I think the point I'm trying to make is that we need to define the 
interface which if you implement it you are supported. For label 
import/export we have inode_{get,set,notify}secctx. For checking for 
xattr suitibility we have the new ismaclabel lsm call. Now the final 
thing we need to do is a call to determine if the lsm is suitable for 
Labeled NFS export meaning that it agrees to the semantics. Is 
inode{get,set,notify}_secctx and ismaclabel sufficient? I'm tempted to 
say we can make a call to inode_getsecctx and if it failes with 
EOPNOTSUPP we say we don't support it but then we need an initial file 
to call that on. This is why I'd rather have a LSM call that we can make 
that gives us a yes/no answer.

Dave

