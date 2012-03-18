Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:55137 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab2CRKvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Mar 2012 06:51:41 -0400
Received: by wejx9 with SMTP id x9so5106113wej.19
        for <linux-nfs@vger.kernel.org>; Sun, 18 Mar 2012 03:51:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
From: Lev Solomonov <solo@tonian.com>
Date: Sun, 18 Mar 2012 12:51:19 +0200
Message-ID: <CAOdHTRB5tfXvdEprnUpfswdr7Afq-cOvsqj2VicLipKc2sOK9w@mail.gmail.com>
Subject: Re: About pNFS installation process.
To: Bruno Silva <bs@cin.ufpe.br>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 15, 2012 at 22:23, Bruno Silva <bs@cin.ufpe.br> wrote:
    <snip>
> 1      17.4kB  53.7GB  53.7GB  ext3         1     msftres
> I have tested with ext4 file system, create ext4 file system with
> 4K block size.
>
> # mkfs.ext4 -b 4096 /dev/sdb1
> -----------------------------------------------------------------

i suspect you might encounter some issues with ext4, once you get past
the initial setup problems.

> The steps 1, 2 and 3 i did to all machines (data servers, metadata
> server and client).

assuming iSCSI as the underlying storage model, generally speaking:
* blkmapd and blocklayoutdriver are client-specific (as jim mentioned).
* ctl daemon is MDS-specific.
* iSCSI target is DS-specific.
* both MDS and client will need iSCSI initiator.

you'll need to discover and login to the iSCSI target on the DS from
both the MDS and the client for proper pNFS operation.

security often gets in the way, mind the ACLs on the iSCSI targets and
firewall settings on all three (client/MDS/DS) and between them.

> I adopted the export option in metadata server exports file.
> /mnt *(rw,sync,fsid=0,insecure,no_subtree_check,no_root_squash,pnfs)
    <snip>
> If the data server and metadata server have been run on the same
> machine everything works normally.

see above. once you set everything up make sure you're actually running
in pNFS mode, i.e. that client sends/receives file data directly from
the DS over iSCSI, not as a fallback through MDS.

solo.
