Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7F7BC65C22
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 11:05:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 79CBF2082E
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 11:05:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79CBF2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727521AbeKBUME (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 16:12:04 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726319AbeKBUME (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 16:12:04 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1DF75308213B;
        Fri,  2 Nov 2018 11:05:19 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-122-158.rdu2.redhat.com [10.10.122.158])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id C433A18667;
        Fri,  2 Nov 2018 11:05:18 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Malahal Naineni" <malahal@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: "(deleted)" directories
Date:   Fri, 02 Nov 2018 07:05:18 -0400
Message-ID: <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
In-Reply-To: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 02 Nov 2018 11:05:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2 Nov 2018, at 1:26, Malahal Naineni wrote:

> Hi All, we are using NFS-Ganesha with Linux NFS clients. The client's
> shell reports the following. Based on lsof, the directory is marked
> deleted. "cd to ROOT and cd to the same home directory fixes the
> issue. The client behaves as though the directory is deleted and
> recreated! Our NFS-Ganesha server implementation uses multiple file
> handles that point to the same object. NFS spec says this should be
> fine, but Linux NFS seems to be broken in this regard. tcpdump does
> indicate file handle change (note that all file handles are permanent,
> meaning they are valid at the server any time) around this issue time.
>
> "shell-init: error retrieving current directory: getcwd: cannot access
> parent directories: No such file or directory"
> sh        112544            malahal  cwd       DIR               0,67
>      65536   45605209 /home/malahal (deleted)
> (10.120.154.42:/nfs/malahal-export/)
>
> Function nfs_prime_dcache() seems to invalidate the dcache entry if
> nfs_same_file() returns false. nfs_same_file() does seem to return
> false with the following change, if I read it correctly, if there is a
> file handle change. Can this be the source of my issue? It seems that
> the client should do this only if the file handle is NOT valid (e.g.
> if it gets ESTALE), right?
>
> The following commit seems to assume that the objects are different if
> they have different file handles!
> commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
> Author: Trond Myklebust <trond.myklebust@primarydata.com>
> Date:   Thu Sep 22 13:38:52 2016 -0400
>
>     NFS: Fix inode corruption in nfs_prime_dcache()

My understanding is that for NFSv3 we have to assume that distinct
filehandles are distinct objects, but maybe I'm wrong about this.

For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530 section 10.3.4
to determine if the differing filehandles are the same object, specifically
the fileid recommended attribute needs to be implemented.  Is Ganesha
returning the same fileid for both filehandles?

Ben
