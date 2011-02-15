Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53297 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab1BOOoZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:44:25 -0500
Received: by iwn9 with SMTP id 9so228188iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 06:44:24 -0800 (PST)
In-Reply-To: <1297723160.23841.30.camel@heimdal.trondhjem.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	<1297723160.23841.30.camel@heimdal.trondhjem.org>
Date: Tue, 15 Feb 2011 09:44:24 -0500
Message-ID: <AANLkTimaSjeNdyBvmdLcT-rG8Y4xLatRV9uGahXFBfks@mail.gmail.com>
Subject: Re: [PATCH 0/16] pnfs wave 3 submission
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 14, 2011 at 5:39 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote:
>> These patches implement wave 3 of the pNFS submission, which encompasses file
>> layout data server connection, READ I/O, and recovery through the MDS.
>>
>> They apply on top of Fred's recent 3 patch 'lock inversion' series
>> commits 2d767077 .. 2cc09edd in Trond's nfs-for-next tree.
>>
>> They are based upon Benny's current pnfs-submit-wave3 branch re-arranged
>> into a more choerent series of patches and rebased upon Trond's nfs-for-next.
>>
>> -->Andy
>>
>> 0001-NFS-remove-unnecessary-CONFIG_NFS_V4-from-nfs_read_d.patch
>> 0002-NFS-put_layout_hdr-can-remove-nfsi-layout.patch
>> 0003-NFS-move-nfs_client-initialization-into-nfs_get_clie.patch
>> 0004-pnfs-wave-3-send-zero-stateid-seqid-on-v4.1-i-o.patch
>> 0005-pnfs-wave-3-new-flag-for-state-renewal-check.patch
>> 0006-pnfs-wave-3-new-flag-for-lease-time-check.patch
>> 0007-pnfs-wave-3-add-MDS-mount-DS-only-check.patch
>> 0008-pnfs-wave-3-lseg-refcounting.patch
>> 0009-pnfs-wave-3-shift-pnfs_update_layout-locations.patch
>> 0010-pnfs-wave-3-coelesce-across-layout-stripes.patch
>> 0011-pnfs-wave-3-generic-read.patch
>> 0012-pnfs-wave-3-data-server-connection.patch
>> 0013-pnfs-wave-3-filelayout-read.patch
>> 0014-pnfs-wave-3-filelayout-read.patch
>> 0015-pnfs-wave-3-filelayout-async-error-handler.patch
>> 0016-pnfs-wave-3-turn-off-pNFS-on-ds-connection-failure.patch
>>
>
> Hi Andy,
>
> Can we please get rid of the 'wave 3:' in the subject of all these
> patches? It is a slang that is only meaningful to the people who
> regularly follow the Linux pNFS conference calls.

Sure - makes sense.

-->Andy
>
> If you do want to label the patches, then please encode the label as
> something like
>
> [PATCH pNFS wave3] NFSv4.1: xxxxxxxxxxxx
>
> so that 'git am' strips out the [PNFS WAVE 3] bit, and just leaves the
> patch short description.
>
> You can do this using the --subject-prefix="PATCH pNFS wave3" argument
> to 'git format-patch'.
> Alternatively, if you are using 'stg mail' then you can achieve the same
> effect with --version="pNFS wave3".
>
> Cheers
>  Trond
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
