Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57786 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756258Ab1LGPP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 10:15:58 -0500
Date: Wed, 7 Dec 2011 10:15:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATCH] nfsd41: handle current stateid in open and close
Message-ID: <20111207151557.GA20079@fieldses.org>
References: <1323207847-19118-1-git-send-email-tigran.mkrtchyan@desy.de>
 <20111206230823.GH12640@fieldses.org>
 <4EDF677C.7030209@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EDF677C.7030209@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2011 at 03:17:48PM +0200, Benny Halevy wrote:
> I believe we need to initialize the current_stateid for the compound
> with the invalid stateid:
> (the "other" value is zero and the "seqid" field is
>    NFS4_UINT32_MAX, see Section 8.2.3)

Sounds like a good idea.
