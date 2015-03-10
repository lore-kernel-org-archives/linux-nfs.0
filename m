Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbbCJI0s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Mar 2015 04:26:48 -0400
Date: Tue, 10 Mar 2015 04:26:44 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Peng Yu <pengyu.ut@gmail.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: NFS hang after concurrent writes
In-Reply-To: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1503100423290.456@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 9 Mar 2015, Peng Yu wrote:

> Hi,
>
> I have a home directory from an ubuntu server shared to multiple other
> ubuntu servers as the home directory (the default login shell is bash
> on these servers) via NFS (see the following configuration in
> /etc/exports from the NFS server).
>
> /mnt/home 172.17.0.0/16(fsid=2,rw,insecure,no_subtree_check,sync,no_root_squash)
>
> autofs is used to mount the NFS on the client servers (see the
> following configuration).
>
> ~$ cat /etc/auto.master
> +auto.master
> /home   /etc/auto.home --timeout=90
> ~$ cat /etc/auto.home
> *  -fstype=nfs4,rw,intr,fsc    nsfserver:/mnt/home/&
>
> But I frequently end up with a situation when ~/.bash_history is not
> readable which blocks the logins to these client servers. I feel that
> this may be related with concurrent write to ~/.bash_history from
> these servers, which somehow screw up NFS.

Hi Peng, what do you have that supports your feeling that the problem is
conflicts on the ~/.bash_history file?  It's hard to help without more
information.

You should expect NFS home directories to work and work well - it is a very
common usage.

Ben
