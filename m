Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934325Ab3E1OlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 10:41:12 -0400
Message-ID: <51A4C206.7050801@RedHat.com>
Date: Tue, 28 May 2013 10:41:10 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
References: <1366380998-2581-1-git-send-email-steved@redhat.com> <20130502131332.5c0ce2b0@notabene.brown> <20130528091139.36bb362e@notabene.brown>
In-Reply-To: <20130528091139.36bb362e@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Neil,

On 27/05/13 19:11, NeilBrown wrote:
> Hi Steve,
>  what is the status of this issue in your mind?
>  upstream nfs-utils is still vulnerable to CVE-2013-1923, so probably a few
>  distros think that have addressed it by upgrading, but haven't.
Hmmm... I thought commit f9f5450f, which is in 1.2.8, resolved 
that issue... What am I'm missing?

> 
>  Can we get a 1.2.9 that really fixes this issue?
Sure... I'm all for it! 

steved.
