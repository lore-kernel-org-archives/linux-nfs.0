Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:33086 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932111AbcFNWzG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 18:55:06 -0400
Subject: Re: [PATCH v2] nfsd: Always lock state exclusively.
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465944743.12291.4.camel@poochiereds.net>
Date: Tue, 14 Jun 2016 18:54:58 -0400
Cc: "J . Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <F7BC1638-0C44-4ED5-8483-EEF9A673EA4B@linuxhacker.ru>
References: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru> <1465781187-824653-1-git-send-email-green@linuxhacker.ru> <20160614153808.GD25973@fieldses.org> <ED916555-2D4D-4BF5-8850-9A17D0ABFE82@linuxhacker.ru> <20160614185032.GJ25973@fieldses.org> <1465944743.12291.4.camel@poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 14, 2016, at 6:52 PM, Jeff Layton wrote:
> I think I'd still prefer to have it unlock the mutex in the event that
> it's not going to use it after all. While that kind of thing is ok for
> now, it's stuff like that that can turn into a subtle source of bugs
> later.
> 
> Also, I think I'd be more comfortable with this being split into (at
> least) two patches. Do one patch as a straight conversion from rwsem to
> mutex, and then another that changes the code to take the mutex before
> hashing the new stateid.

Ok, I guess that could be arranged too.

And then there's this Bruce's patch to pull more stuff into the init_open_stateid