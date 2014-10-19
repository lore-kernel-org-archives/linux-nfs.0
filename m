Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:44745 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbaJSUDB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Oct 2014 16:03:01 -0400
Received: by mail-ie0-f176.google.com with SMTP id rp18so3558145iec.35
        for <linux-nfs@vger.kernel.org>; Sun, 19 Oct 2014 13:03:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5442E2A4.9030006@gmx.de>
References: <5442E2A4.9030006@gmx.de>
Date: Sun, 19 Oct 2014 23:03:00 +0300
Message-ID: <CAABAsM4ETHB6obPVa4Zf8T7Vb--t6--Q2tS5ibOurA1BN3as=g@mail.gmail.com>
Subject: Re: fuzz testing gave today : "kernel: NFS: nfs4_reclaim_open_state:
 unhandled error -13"
From: Trond Myklebust <trondmy@gmail.com>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 19, 2014 at 12:59 AM, Toralf Förster <toralf.foerster@gmx.de> wrote:
> happens within a 32 bit user mode linux guest running latest git tree v3.17-9981-g929254d
> It occurred few times about half an hour after the test case was started.
>
> Well, it is very early in the current release cycle, so just asking, if this is already known / worth to investigate ?

Errno 13 is EACCES. Might the test case involve changing the mode
bits/acls on an open file, then putting the client in situation where
an expired lease causes it to attempt open state recovery?

Cheers
  Trond
