Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934500Ab3E1Pqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 11:46:34 -0400
Message-ID: <51A4D157.7000301@RedHat.com>
Date: Tue, 28 May 2013 11:46:31 -0400
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



On 27/05/13 19:11, NeilBrown wrote:
> Hi Steve,
>  what is the status of this issue in your mind?
>  upstream nfs-utils is still vulnerable to CVE-2013-1923, so probably a few
>  distros think that have addressed it by upgrading, but haven't.
> 
>  Can we get a 1.2.9 that really fixes this issue?
Ok... I did miss your analysis and patch at the bottom of
    http://marc.info/?l=linux-nfs&m=136746443205479&w=2

Sorry about that... I'm on it... 

steved.
