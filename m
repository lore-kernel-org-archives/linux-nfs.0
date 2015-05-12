Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36530 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933084AbbELSi0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2015 14:38:26 -0400
Received: by obbkp3 with SMTP id kp3so12540273obb.3
        for <linux-nfs@vger.kernel.org>; Tue, 12 May 2015 11:38:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150511122701.GB5732@lst.de>
References: <20150507140814.GF27106@fieldses.org>
	<1431124677-13388-1-git-send-email-andreas.gruenbacher@gmail.com>
	<CAHpGcM+i1ZDJUV4oRVV3q9f2GSiDTYBfmRyzsQzRCeM1ck6EzA@mail.gmail.com>
	<20150511122701.GB5732@lst.de>
Date: Tue, 12 May 2015 20:38:25 +0200
Message-ID: <CAHpGcMJ+TSjG0U0c-g7uHZvBtz7XvDxk5WwN57rEgSQ9jvpFyg@mail.gmail.com>
Subject: Re: [PATCH v2] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-11 14:27 GMT+02:00 Christoph Hellwig <hch@lst.de>:
> Can you add this to xfstests?

Yes, that probably makes sense. I've sent two patches to the list.

Thanks,
Andreas
