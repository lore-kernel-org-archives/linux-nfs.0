Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45615 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbbBKSMi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 13:12:38 -0500
Received: by pdjz10 with SMTP id z10so5855095pdj.12
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 10:12:38 -0800 (PST)
Date: Wed, 11 Feb 2015 10:12:31 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150211181231.GA80012@kitty.kitty>
References: <20150202161557.GF22301@fieldses.org>
 <20150211123757.GA10532@infradead.org>
 <20150211141257.GA25696@fieldses.org>
 <20150211141619.GA24299@infradead.org>
 <20150211145413.GC25696@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211145413.GC25696@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 09:54:13AM -0500, J. Bruce Fields wrote:
> 
> I agree there's a documentation and marketing problem: it would simplify
> communication with users if "this server supports 4.2" reliably meant
> support for some minimum list of features.
> 

The "marketing" message over NFSv4.2 has been pretty consistent - everything
is optional and a fully compliant server can return not supported for
every new feature. I.e., a NFSv4.2 server is pretty simple if you have
an existing NFSv4.1 server.
