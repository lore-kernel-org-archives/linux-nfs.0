Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56189 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAXXcy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 18:32:54 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Seth Forshee <seth.forshee@canonical.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <1481821992-77583-1-git-send-email-seth.forshee@canonical.com>
        <1481842899.11785.1.camel@primarydata.com>
        <20161216130609.GA124240@ubuntu-hedt>
        <20170110145504.GH52661@ubuntu-hedt> <87ziiyfntm.fsf@xmission.com>
        <20170124151745.GA114560@ubuntu-hedt> <87efzsdq5b.fsf@xmission.com>
Date: Wed, 25 Jan 2017 12:28:36 +1300
In-Reply-To: <87efzsdq5b.fsf@xmission.com> (Eric W. Biederman's message of
        "Wed, 25 Jan 2017 11:55:28 +1300")
Message-ID: <87inp4rqaj.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH] sunrpc: Use current_real_cred() when looking up rpc credentials
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


With respect to nfs and automounts.

Does NFS have different automount behavior based on the user
performing the automount?

If NFS does not have different automount behavior depending on the user
we just use the creds of the original mounter of NFS?

If NFS does have different automount behavior depending on the user
(ouch!) we need to go through the call path and see where it makes
sense to over ride things and where it does not.



Seth the fundamental problem with your patch was that you were patching
a location that is used for more just mounts.

I am strongly wishing that we could just change follow_automount from:


	old_cred = override_creds(&init_cred);
	mnt = path->dentry->d_op->d_automount(path);
	revert_creds(old_cred);

to:

	old_cred = override_creds(path->mnt->mnt_sb->s_cred);
	mnt = path->dentry->d_op->d_automount(path);
	revert_creds(old_cred);

And all will be well with nfs.  That does remain possible.

But looking at the code path you touched it seems to lookup the cred
based purely on the local uid, gid, and groups.  Which suggests to
me that even the original mounters creds may not be enough :(

At which point I am not certain of the solution.  But I fear that like
autofs NFS actually cares which user is transition the magic mountpoint,
and may return different data depending on who transitions the
mountpoint first.  Ick!  Nasty Nasty Ick!

Eric
