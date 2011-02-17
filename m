Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43833 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753798Ab1BQFzg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Feb 2011 00:55:36 -0500
In-Reply-To: <20110217045125.GI14534@fieldses.org>
References: <20110215185902.GG29420@fieldses.org> <20110217042519.GH14534@fieldses.org>
 <AANLkTikeK77v7y346-OX9dvufJSjbJ7qQSpJc4C3wLrZ@mail.gmail.com> <20110217045125.GI14534@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Feb 2011 21:54:49 -0800
Message-ID: <AANLkTikjJPfUdknRrFJC2-3Pm57ReMxNXXgZb8C0YyfQ@mail.gmail.com>
Subject: Re: 2.6.38 nfsd bugfixes
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 16, 2011 at 8:51 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> I already committed it like that, so would rather just do any cleanup as
> another patch for the next merge window;

That's fine. I just want to point these out as I see them, and ask
that when people fix bugs, they also aim to make the code readable at
the same time.

                                    Linus
