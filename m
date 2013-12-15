Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f171.google.com ([209.85.215.171]:42089 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab3LOPua (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Dec 2013 10:50:30 -0500
Received: by mail-ea0-f171.google.com with SMTP id h10so1739536eak.16
        for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 07:50:29 -0800 (PST)
Message-ID: <52ADCFC2.7060504@gmail.com>
Date: Sun, 15 Dec 2013 17:50:26 +0200
From: Benny Halevy <bhalevy.lists@gmail.com>
MIME-Version: 1.0
To: bfields@redhat.com
CC: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 0/2] a couple fixes in nfsd4_release_lockowner
References: <52AADAF6.40700@primarydata.com>
In-Reply-To: <52AADAF6.40700@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

changes from v1:

[PATCH v2 1/2] nfsd4: break from inner lookup loop in nfsd4_release_lockowner on first match

- initialize lo_list
- in case locks our found delete all previous matches from temporary list

[PATCH 2/2] nfsd4: ignore nfsv4.1 lockowners in nfsd4_release_lockowner

- added comment

On 12/13/2013 12:01 PM, Benny Halevy wrote:
> Bruce, while working on the state mutex elimination stuff I saw these two issues
> in nfsd4_release_lockowner.  These patches are untested but I just wanted to quickly get
> your take on them.
>
> [PATCH 1/2] nfsd4: break from inner lookup loop in nfsd4_release_lockowner on first match
>
> looks like a potential list corruption risk.
>
> [PATCH 2/2] nfsd4: ignore nfsv4.1 lockowners in nfsd4_release_lockowner
>
> I'm not sure that 100% needed but since we keep both nfsv4.0 and v4.1 owners
> hashed on the same lists we don't want a v4.0 operation to accidentally
> touch v4.1 state.
>
> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

