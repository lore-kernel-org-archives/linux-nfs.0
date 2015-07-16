Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35334 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbbGPXyf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2015 19:54:35 -0400
Received: by pactm7 with SMTP id tm7so50899393pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2015 16:54:35 -0700 (PDT)
Message-ID: <55A84431.3000603@gmail.com>
Date: Fri, 17 Jul 2015 07:54:25 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de, bfields@fieldses.org
CC: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: Re: [PATCH] pynfs: reduce code duplication
References: <1437064828-15387-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1437064828-15387-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/17/2015 00:40, tigran.mkrtchyan@desy.de wrote:
> From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> 
> the test suite has two methods: check and checklist to
> validate status codes of a compound operation. The both
> methods are identical, except one of them accept a single
> status code and other accepts a list.
> 
> Modify 'check' to accept a list as well to reduce code
> duplication.
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/environment.py        | 40 ++++++++++++------------------
>  nfs4.1/server41tests/st_current_stateid.py |  6 ++---
>  nfs4.1/server41tests/st_delegation.py      |  6 ++---
>  nfs4.1/server41tests/st_destroy_session.py |  2 +-
>  nfs4.1/server41tests/st_exchange_id.py     |  4 +--
>  nfs4.1/server41tests/st_lookup.py          | 10 ++++----
>  nfs4.1/server41tests/st_open.py            |  2 +-
>  nfs4.1/server41tests/st_reboot.py          |  2 +-
>  nfs4.1/server41tests/st_rename.py          | 14 +++++------
>  nfs4.1/server41tests/st_verify.py          |  4 +--
>  10 files changed, 41 insertions(+), 49 deletions(-)
> 

Make sense.
I think clean all "checklist" is better.

"checklist" also exist in, 
nfs4.1/client41tests/environment.py
nfs4.0/servertests/environment.py

Anyway this one is nice for nfs4.1 server.

thanks,
Kinglong Mee
