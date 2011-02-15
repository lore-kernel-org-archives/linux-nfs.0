Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63743 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab1BOOnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:43:51 -0500
Received: by iwn9 with SMTP id 9so227586iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 06:43:50 -0800 (PST)
In-Reply-To: <1297726920.23841.51.camel@heimdal.trondhjem.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	<1297711116-3139-11-git-send-email-andros@netapp.com>
	<1297726920.23841.51.camel@heimdal.trondhjem.org>
Date: Tue, 15 Feb 2011 09:43:50 -0500
Message-ID: <AANLkTikRMT=xxXp+7ky9kaYCOn2-y0obpJ7-gW96NkN5@mail.gmail.com>
Subject: Re: [PATCH 10/16] pnfs: wave 3: coelesce across layout stripes
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 14, 2011 at 6:42 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote:
>> From: Fred Isaman <iisaman@netapp.com>
>>
>> Add a pg_test layout driver hook which is used to avoid coelescing I/O across
>> layout stripes.
>
> Doesn't this belong before [PATCH 09/16] pnfs: wave 3: shift
> pnfs_update_layout locations?

The pg_test uses the pg_lseg declared in [PATCH 09/16] pnfs: wave 3:
shift pnfs_update_layout locations, which is why the patches are
ordered this way.


-->Andy

>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
