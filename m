Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:37069 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752769Ab2KLW3u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 17:29:50 -0500
Message-ID: <50A176CE.8010509@schaufler-ca.com>
Date: Mon, 12 Nov 2012 14:23:10 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
In-Reply-To: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/11/2012 10:15 PM, David Quigley wrote:
> The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
> specification and it has been decided that a reposting of the Labeled NFS code
> for inclusion into mainline was a good idea. The patches have been rebased onto
> v3.7-rc2 and have been tested against the SELinux testsuite with the only
> failures being for features not supported by NFS.

It's going to take a few days (I'm traveling among other issues)
before I can have the Smack project comments ready. They are coming.

If you have pointers to test suites you found especially helpful
I could sure use them.

Thank you.

