Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:32992 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751979Ab2KMDQJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 22:16:09 -0500
Message-ID: <50A1BB75.2000303@davequigley.com>
Date: Mon, 12 Nov 2012 22:16:05 -0500
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Casey Schaufler <casey@schaufler-ca.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <50A176CE.8010509@schaufler-ca.com>
In-Reply-To: <50A176CE.8010509@schaufler-ca.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2012 5:23 PM, Casey Schaufler wrote:
> On 11/11/2012 10:15 PM, David Quigley wrote:
>> The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
>> specification and it has been decided that a reposting of the Labeled NFS code
>> for inclusion into mainline was a good idea. The patches have been rebased onto
>> v3.7-rc2 and have been tested against the SELinux testsuite with the only
>> failures being for features not supported by NFS.
>
> It's going to take a few days (I'm traveling among other issues)
> before I can have the Smack project comments ready. They are coming.
>
> If you have pointers to test suites you found especially helpful
> I could sure use them.
>
> Thank you.
>

The only testsuite I have is the SELinux one. Unfortunately you're on 
your own for a smack testsuite.
