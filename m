Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35489 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbdAYITE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Jan 2017 03:19:04 -0500
Date: Wed, 25 Jan 2017 09:18:04 +0100
From: Christoph Hellwig <hch@lst.de>
To: Bruce Fields <bfields@fieldses.org>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@lst.de>, trondmy@primarydata.com,
        linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: [PATCH v2] nfsd: special case truncates some more
Message-ID: <20170125081804.GB14954@lst.de>
References: <d6fd33d2-6323-435c-b085-27a7180c4368@email.android.com> <20170124221533.GG20844@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170124221533.GG20844@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Btw, any rason this didn't go into your for-4.10 tree?  Due to the
owner/group changes being the most affected attrs I would classify
it as a security issue.
