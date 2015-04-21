Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34267 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932784AbbDURTU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 13:19:20 -0400
Received: by iedfl3 with SMTP id fl3so21270722ied.1
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 10:19:19 -0700 (PDT)
Message-ID: <1429636756.1309.2.camel@kepstin.ca>
Subject: Re: [PATCH] nfs-utils: Run rpcgen using the cpp found by configure.
From: Calvin Walton <calvin.walton@kepstin.ca>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>
Date: Tue, 21 Apr 2015 13:19:16 -0400
In-Reply-To: <1428991229-19835-1-git-send-email-calvin.walton@kepstin.ca>
References: <1428991229-19835-1-git-send-email-calvin.walton@kepstin.ca>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-04-14 at 02:00 -0400, Calvin Walton wrote:
> rpcgen normally runs with a hardcoded cpp path of e.g. /lib/cpp,
> but not all Linux distributions install a cpp there.
> 
> Grab a trick from glibc, and run rpcgen with a cpp-path pointing at
> a script; the script then runs the cpp specified in the CPP
> environment variable - which was set by the configure script to
> something reasonable.

I've discovered that I've made a mistake here; this patch doesn't work 
unless you happen to have $CPP set in your environment.

I'm going to roll a revised version that fixes the issue, probably by 
copying exactly what glibc does: setting CPP='$(CC) -E -x c-header' 
when running rpcgen.

-- 
Calvin Walton <calvin.walton@kepstin.ca>
