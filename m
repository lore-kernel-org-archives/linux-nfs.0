Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55323 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932959Ab0HXW7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Aug 2010 18:59:04 -0400
Date: Tue, 24 Aug 2010 18:58:57 -0400
To: Harry Edmon <harry@uw.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
Message-ID: <20100824225857.GA7283@fieldses.org>
References: <4C7407D2.1040304@uw.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C7407D2.1040304@uw.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 24, 2010 at 10:56:34AM -0700, Harry Edmon wrote:
> I am having a problem getting odd ESTALE (Stale NFS file handle)
> errors.   The server and client are both amd64 architecture.   I am
> runnning a simple csh script on the client with the following:
> 
> if (! -e /home/disk/data/gempak/upperair/latest ) then
>    mkdir /home/disk/data/gempak/upperair/latest
> endif
> 
> The script randomly comes back with:
> 
>  mkdir: cannot create directory
> `/home/disk/data/gempak/model/latest': File exists

Why is it "model" here and "upperair" in the above?

> 
> When I do an strace I am seeing the following when it fails:
> 
> 20745 stat("/home/disk/data/gempak/model/latest", 0x7fff56ed9580) = -1 ESTALE (Stale NFS file handle)
> 
> ...
> 
> 20751 mkdir("/home/disk/data/gempak/model/latest", 0777) = -1 EEXIST (File exists)

Could you give a more complete description of the code that's running?
(For example: how is "latest" being removed, and how do you know that
"latest" isn't created after checking whether it exists but before the
mkdir?)

--b.

> 
> The kernel version of the client does not matter (I have tried
> 2.6.34.5 and 2.6.35.3).   But the server kernel does matter.   It
> occurs with 2.6.35 and 2.6.35.3.   It does not with 2.6.34.5.
> 
> The ESTALE only occurs with "stat" and "lstat" in the scripts I have tried.  Attached is my configuration file from the server.  The mount on the client is:
> 
> imist2:/home/data on /home/disk/data type nfs (rw,noatime,intr,proto=tcp,addr=192.168.1.12)
> 
> 
> Any ideas?
