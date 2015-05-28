Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:33191 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219AbbE1VPa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 17:15:30 -0400
MIME-Version: 1.0
In-Reply-To: <20150528203332.GD31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
Date: Thu, 28 May 2015 23:15:29 +0200
Message-ID: <CAHpGcMLJ0R5fKMnrFV5HsJ5Pi7evc057uN2RBuNMcYO+szwWeA@mail.gmail.com>
Subject: Re: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-28 22:33 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Fri, Apr 24, 2015 at 01:04:33PM +0200, Andreas Gruenbacher wrote:
>> The client fails to detect when unexpected attributes are sent after the last
>> expected attribute in each word in the bitmap.
>
> Is it important that the client catch that?

Yes if there are more attributes in the next word that the client cares about;
probably no otherwise.

>> Fix this by checking the entire bitmap for unexpected attributes first.  The
>> server can still send attributes which the client understands but which it
>> didn't request; this doesn't cause any harm.
>
> I don't understand that last sentence.  On a skim it looks like after
> this patch we *will* still error out if a server does that, right?  (As
> we should, that would be a server bug.)

We don't actually verify the request bitmap against the reply bitmap;
we don't keep
the request bitmap around long enough. Some decode functions understand a set
of attributes. Currently, we happily accept any of the attributes the
decode function
in question accepts, even ones that were not requested. That could be fixed by
checking the request bitmap against the reply bitmap as well of course.

Andreas
