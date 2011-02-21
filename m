Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60635 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab1BUJaT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 04:30:19 -0500
Received: by iwn8 with SMTP id 8so1689532iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Feb 2011 01:30:18 -0800 (PST)
In-Reply-To: <AANLkTinZ61OZObYMeuisJ-H2+o3PgFM1K+kExyUMaTNL@mail.gmail.com>
References: <AANLkTikGAHBEKxeQqVegtW3VmZcJScMPkzGOyWfvD9h7@mail.gmail.com>
	<AANLkTinZ61OZObYMeuisJ-H2+o3PgFM1K+kExyUMaTNL@mail.gmail.com>
Date: Mon, 21 Feb 2011 11:30:18 +0200
Message-ID: <AANLkTikyuyc0K2qXZf9ce5Y0ApMCsjsysEfg==gAxJJV@mail.gmail.com>
Subject: Re: 2.6.32, NFSv4, "Stale NFS file handle" problem
From: Nick Patavalis <npat@efault.net>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Mon, Feb 21, 2011 at 11:09 AM, Nick Patavalis <npat@efault.net> wrote:
>
> On Mon, Feb 21, 2011 at 2:54 AM, Nick Patavalis <npat@efault.net> wrote:
>>
>> I don't know if this is an NFS bug, but seems a lot like it... My
>> server-host exports a few NTFS filesystems (read-only exports) using
>> NFSv4. Two client-hosts mount these file-systems.
>>
>> Client A runs 2.6.31, and client B 2.6.32. Client A works fine. Client
>> B, while it initially mounts everything ok, and for some time
>> everything works ok (or so it seems), after a while it starts
>> returning "Stale NFS file hande" errors for random files and
>> directories. Client A NEVER returns stale errors, EVEN after a server
>> reboot.
>>
>
> Some additional information.
>
> After the problem appears (i.e. after "client B" starts returning
> "stale file handle" errors), an "ls" on a file (directory) for
> which the file-handle is stale, with "sunrpc.nfs_debug = 1023"
> shows:
>

I also tried:

- Exporting /mnt (the NFSv4 preudo-root) without the "crossmount"
  option (and having the clients mount the subordinate file-systems)

- Exporting /mnt with "crossmount" and having the client B (the
  "problematic" one, running kernel 2.6.32) mount "server:/" instead
  of the subordinate filesystems.

- Making client B mount with options: "ro,soft,proto=tcp"
  (i.e. without the "nocto,actimeo=300")

No observable change in behavior. Client A (the one with kernel
2.6.31) works perfectly. Client B (the one with kernel 2.6.32) mounts
ok but, at some point in time, it starts returning "stale file handle"
errors (as described in the previous message).

At this point I start to run out of things to try! Any suggestions
would be greately appreciated.

Thanks again
/npat
