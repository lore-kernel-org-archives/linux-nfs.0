Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:59125 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbZHZO3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 10:29:42 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>,
        Lans Carstensen <Lans.Carstensen@dreamworks.com>
Message-Id: <8695C01C-FB64-4499-A017-3DBBB55961E5@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4A94C12E.4050505@dreamworks.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 1/4] nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
Date: Wed, 26 Aug 2009 10:29:04 -0400
References: <4A94C12E.4050505@dreamworks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Acked-by: Chuck Lever <chuck.lever@oracle.com>

On Aug 26, 2009, at 12:59 AM, Lans Carstensen wrote:

> commit 1da314fc4e0548e30516e6140e98ad56d2150048
> Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
> Date:   Tue Aug 25 21:50:29 2009 -0700
>
>    Conforms Python path to the LSB 3.2+ standard of /usr/bin/python
> http://refspecs.freestandards.org/LSB_3.2.0/LSB-Languages/LSB-Languages/pylocation.html
>    Per SteveD this is also required for proper rpm dep resolution  
> during builds
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index 9626d42..ea02db4 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -1,4 +1,4 @@
> -#!/usr/bin/env python
> +#!/usr/bin/python
> # -*- python-mode -*-
> """Emulate iostat for NFS mount points using /proc/self/mountstats
> """
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



