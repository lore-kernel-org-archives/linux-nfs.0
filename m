Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37775 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755977Ab1DRRAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Apr 2011 13:00:24 -0400
In-Reply-To: <87zknnv7id.fsf@devron.myhome.or.jp>
References: <20110412143559.186613198@clark.kroah.org> <87pqokx6lr.fsf@devron.myhome.or.jp>
 <BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com> <20110418153236.GC20935@pad.home.fieldses.org>
 <87ipubwnj3.fsf@devron.myhome.or.jp> <8762qbwnf1.fsf@devron.myhome.or.jp> <87zknnv7id.fsf@devron.myhome.or.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 18 Apr 2011 09:59:26 -0700
Message-ID: <BANLkTi=HGzJ4LaZpWsWXrUQVWheS=x7CoQ@mail.gmail.com>
Subject: Re: [105/105] nfsd4: fix oops on lock failure
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Greg KH <gregkh@suse.de>,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 18, 2011 at 9:39 AM, OGAWA Hirofumi
<hirofumi@mail.parknet.co.jp> wrote:
>
> For now, I feel this explain filp leak on my system. the leak is
> increased slowly (filp, cred_jar, and no nfs* slabs), and leak is on
> nfs server side.
>
> I'll start test of this patch, and see what happens.

Can somebody ping/remind me when that is verified - preferably about
_both_ patches, even if it turns out that the first one by Ogawa
wasn't the one that caused the problem?

Or can I just assume that the fix will be in Bruce's pull requests some day?

                         Linus
