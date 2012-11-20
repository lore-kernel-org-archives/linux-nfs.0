Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp107.biz.mail.gq1.yahoo.com ([98.137.12.182]:28802 "HELO
	smtp107.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752473Ab2KTVJ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2012 16:09:57 -0500
Message-ID: <50ABF1A5.2010406@schaufler-ca.com>
Date: Tue, 20 Nov 2012 13:09:57 -0800
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

I'm trying to get the user space tools built so that I can
do Smack testing. The instructions on selinuxproject.org
seen out of date with regard to the packages required to
build the NFS tools. I have failed to build on Fedora 17
and Ubuntu 12.04. Any pointers beyond what's on the wiki?

Thank you.


 --
This message was distributed to subscribers of the selinux mailing list.
If you no longer wish to subscribe, send mail to majordomo@tycho.nsa.gov with
the words "unsubscribe selinux" without quotes as the message.


