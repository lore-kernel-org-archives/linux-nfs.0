Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:38116 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455Ab3FYWGG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 18:06:06 -0400
Received: by mail-ie0-f170.google.com with SMTP id e11so30039157iej.29
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 15:06:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABgxfbGOxbLTGNuVFuts367vZru8VLXCYWx6d3m_xeyVgUZwuA@mail.gmail.com>
References: <CABgxfbGOxbLTGNuVFuts367vZru8VLXCYWx6d3m_xeyVgUZwuA@mail.gmail.com>
Date: Tue, 25 Jun 2013 15:06:05 -0700
Message-ID: <CABgxfbEq3sxmLVEgs=ryGq0f+AF0VyDBoCzeEcWKODYnX9JFAw@mail.gmail.com>
Subject: Re: NFS4 Lock Lease
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 25, 2013 at 2:04 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> I have not looked at how NFS4 handles its lock lease yet. Could
> someone pass few pointers ? The specific question I have is the
> perpetuity issue - that is, how does (or will) NFS4 lock lease prevent
> a lock owner from taking the lock for an extended duration (or even
> indefinitely) ?
>

I believe I asked a very dumb question .. "lease" is associated with a
time period - so perpetuity is not an issue at all. I have no idea why
I got confused few minutes ago  :)

-- Wendy
