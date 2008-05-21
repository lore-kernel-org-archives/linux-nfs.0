From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Wed, 21 May 2008 10:15:00 +0200
Message-ID: <9e8c52a20805210115y53cc3b34jdb9a60128317120a@mail.gmail.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	 <20080519144806.GB7622@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:14963 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565AbYEUIPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 04:15:02 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1092033nfc.21
        for <linux-nfs@vger.kernel.org>; Wed, 21 May 2008 01:15:00 -0700 (PDT)
In-Reply-To: <20080519144806.GB7622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 19, 2008 at 4:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> You're doing the "ls" from the client, though, not the server, right?

Yes, from the client. I'll check what ls on the server does if it happens again.

> Out of curiosity--what's the filesystem on the server?  (I just wonder
> if this could be due to poor time resolution, so if e.g. switching from
> ext3 to xfs would work around the problem.)

Just checked, it's ext3.

-- 
Alex Borghgraef
