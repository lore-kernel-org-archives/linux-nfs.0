Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41912 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdAYAAy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 19:00:54 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "seth.forshee\@canonical.com" <seth.forshee@canonical.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <1481821992-77583-1-git-send-email-seth.forshee@canonical.com>
        <1481842899.11785.1.camel@primarydata.com>
        <20161216130609.GA124240@ubuntu-hedt>
        <20170110145504.GH52661@ubuntu-hedt> <87ziiyfntm.fsf@xmission.com>
        <20170124151745.GA114560@ubuntu-hedt> <87efzsdq5b.fsf@xmission.com>
        <87inp4rqaj.fsf@xmission.com>
        <1485301593.36478.2.camel@primarydata.com>
Date: Wed, 25 Jan 2017 12:56:31 +1300
In-Reply-To: <1485301593.36478.2.camel@primarydata.com> (Trond Myklebust's
        message of "Tue, 24 Jan 2017 23:46:35 +0000")
Message-ID: <87y3y0ko5s.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Subject: Re: [PATCH] sunrpc: Use current_real_cred() when looking up rpc credentials
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trondmy@primarydata.com> writes:

> On Wed, 2017-01-25 at 12:28 +1300, Eric W. Biederman wrote:
>> With respect to nfs and automounts.
>> 
>> Does NFS have different automount behavior based on the user
>> performing the automount?
>> 
>> If NFS does not have different automount behavior depending on the
>> user
>> we just use the creds of the original mounter of NFS?
>> 
>> If NFS does have different automount behavior depending on the user
>> (ouch!) we need to go through the call path and see where it makes
>> sense to over ride things and where it does not.
>
> The reason why the NFS client creates a mountpoint is because on
> entering a directory, it detects that there is either a similar
> mountpoint on the server, or there is a referral (which acts sort of
> like a symlink, except it points to a path on one or more different NFS
> servers).
> Without that mountpoint, most things would work, but the user would end
> up seeing nasty non-posix features like duplicate inode numbers.
>
> We do not want to use any creds other than user creds here, because as
> far as the security model is concerned, the process is just crossing
> into an existing directory.

But sget needs different creds.

Because the user who authorizes the mounting of the filesystem is
different than the user who is crossing into the new filesystem.

The local system now cares about that distinction even if the nfs server
does not.

>> Seth the fundamental problem with your patch was that you were
>> patching
>> a location that is used for more just mounts.
>> 
>> I am strongly wishing that we could just change follow_automount
>> from:
>> 
>> 
>> 	old_cred = override_creds(&init_cred);
>> 	mnt = path->dentry->d_op->d_automount(path);
>> 	revert_creds(old_cred);
>> 
>> to:
>> 
>> 	old_cred = override_creds(path->mnt->mnt_sb->s_cred);
>> 	mnt = path->dentry->d_op->d_automount(path);
>> 	revert_creds(old_cred);
>> 
>> And all will be well with nfs.  That does remain possible.
>
> No. That would break permissions checking. See above.

Then we need to look much harder at the permission checking
model of d_automount because we need to permission check against
both sets of creds.

>> But looking at the code path you touched it seems to lookup the cred
>> based purely on the local uid, gid, and groups.  Which suggests to
>> me that even the original mounters creds may not be enough :(
>> 
>> At which point I am not certain of the solution.  But I fear that
>> like
>> autofs NFS actually cares which user is transition the magic
>> mountpoint,
>> and may return different data depending on who transitions the
>> mountpoint first.  Ick!  Nasty Nasty Ick!
>> 
>
> The security model is the same as that of an ordinary directory. The
> only difference is that we create a new superblock. Why is that "Ick"?

The Ick is if the superblock that is created depends on the user
crossing the mountpoint.

AKA Do we get a different mountpoint if user A triggers the automount
vs user B triggering the automount?

If the problem is just root squash and not letting root trigger the
automount it is much less ick.  Weird but not ick.

Eric

