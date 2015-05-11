Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:40197 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbbEKM1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2015 08:27:03 -0400
Date: Mon, 11 May 2015 14:27:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas =?iso-8859-1?Q?Gr=FCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH v2] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
Message-ID: <20150511122701.GB5732@lst.de>
References: <20150507140814.GF27106@fieldses.org> <1431124677-13388-1-git-send-email-andreas.gruenbacher@gmail.com> <CAHpGcM+i1ZDJUV4oRVV3q9f2GSiDTYBfmRyzsQzRCeM1ck6EzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHpGcM+i1ZDJUV4oRVV3q9f2GSiDTYBfmRyzsQzRCeM1ck6EzA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can you add this to xfstests?  As it should fail for all filesystems
except for NFSv2 on which xfstests would fail horrible I think it can
become a generic test.
