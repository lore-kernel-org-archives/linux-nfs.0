Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33926 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbbJMDrL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2015 23:47:11 -0400
Received: by obbda8 with SMTP id da8so4203625obb.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2015 20:47:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
References: <CAN-5tyHxP276Re_Zm4mV9F+EY1Czq5SfbPJ1Os_CQd0hfhFzdA@mail.gmail.com>
Date: Mon, 12 Oct 2015 23:47:10 -0400
Message-ID: <CAHQdGtSg5E0jrEhK-aLht6WdmMTFFBUuG8tUX7sHJDUj+67-4Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 5:55 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> It'll be nice to know when we return delegations synchronously or not.

Why? This patch forces us to carry an otherwise completely unnecessary
parameter, so at the very minimum we should have a discussion of what
the real use cases are.
