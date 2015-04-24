Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36197 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754825AbbDXLHn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:07:43 -0400
MIME-Version: 1.0
In-Reply-To: <20150420212810.GB27895@fieldses.org>
References: <cover.1427471526.git.agruenba@redhat.com>
	<75f97eb880b1bbb47b0aa146d3f528e32de06744.1427471526.git.agruenba@redhat.com>
	<20150420212810.GB27895@fieldses.org>
Date: Fri, 24 Apr 2015 13:07:42 +0200
Message-ID: <CAHpGcML1gUTQkYzkyntG1Y89Nh1rVveATpXJgL-GvjRhXOhU0Q@mail.gmail.com>
Subject: Re: [RFC 11/39] richacl: Compute maximum file masks from an acl
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-04-20 23:28 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> Cripes, by the time I got to this point I'd already written one response
> where I complained this was wrong, another where I explained why it was
> right, and gone back and forth a couple more times.
>
> Feel free to add a
>
>         Reviewed-by: J. Bruce Fields <bfields@redhat.com>
>
> but maybe we could use a couple more examples here.  Or a paper.

Thanks, I've tried to explain things a little better in the updated patch queue
just pushed out.

Andreas
