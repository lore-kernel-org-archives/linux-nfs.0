Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35242 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbbDNGMg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 02:12:36 -0400
Received: by iejt8 with SMTP id t8so7172170iej.2
        for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2015 23:12:35 -0700 (PDT)
Message-ID: <1428991951.19959.1.camel@kepstin.ca>
Subject: Re: [PATCH] nfs-utils: Run rpcgen using the cpp found by configure.
From: Calvin Walton <calvin.walton@kepstin.ca>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 14 Apr 2015 02:12:31 -0400
In-Reply-To: <1428991229-19835-1-git-send-email-calvin.walton@kepstin.ca>
References: <1428991229-19835-1-git-send-email-calvin.walton@kepstin.ca>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I forgot to include it in my original email, but this patch is

Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>

If you'd prefer I resend with that included, let me know.

On Tue, 2015-04-14 at 02:00 -0400, Calvin Walton wrote:
> rpcgen normally runs with a hardcoded cpp path of e.g. /lib/cpp,
> but not all Linux distributions install a cpp there.
> 
> Grab a trick from glibc, and run rpcgen with a cpp-path pointing at
> a script; the script then runs the cpp specified in the CPP
> environment variable - which was set by the configure script to
> something reasonable.
> ---
>  support/export/Makefile.am   | 13 +++++++------
>  support/nsm/Makefile.am      | 17 +++++++++--------
>  tests/nsm_client/Makefile.am | 17 +++++++++--------
>  tools/rpcgen/cpp             |  6 ++++++
>  utils/statd/Makefile.am      | 17 +++++++++--------
>  5 files changed, 40 insertions(+), 30 deletions(-)
>  create mode 100755 tools/rpcgen/cpp
 

-- 
Calvin Walton <calvin.walton@kepstin.ca>
