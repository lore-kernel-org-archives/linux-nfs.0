Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f171.google.com ([209.85.210.171]:58374 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932450Ab2LMOSJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:18:09 -0500
Received: by mail-ia0-f171.google.com with SMTP id k27so1976989iad.16
        for <linux-nfs@vger.kernel.org>; Thu, 13 Dec 2012 06:18:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121213133554.GO10897@ics.muni.cz>
References: <20121213133554.GO10897@ics.muni.cz>
Date: Thu, 13 Dec 2012 09:10:14 -0500
Message-ID: <CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
Subject: Re: local_lock mount option
From: Fred Isaman <faisaman4@gmail.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 8:35 AM, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
> Hi,
>
> is this option supported and should work?
>
> It seems that in SLES and RHEL kernel, it is ignored:
> mount nfs.server:/ /storage -t nfs4 -o sec=krb5,local_lock=all
>
> cat /proc/mounts  | grep storage
> nfs.server:/ /storage nfs4
> rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=krb5,clientaddr=xxx.xxx.xxx.xxx,minorversion=0,local_lock=none,addr=xxx.xxx.xxx.xxx 0 0
>
> and it seems, that it actually tries to lock through NFS.
>
> Has this been fixed in later kernels or this is broken at all?
>
> --

local_lock is a v2/v3 option.  It does not currently effect the behavior of v4.

Fred
