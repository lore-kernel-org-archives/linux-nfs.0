Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46473 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754720Ab1FQQwc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2011 12:52:32 -0400
In-Reply-To: <20110617102559.11413.50038.stgit@warthog.procyon.org.uk>
References: <20110617102559.11413.50038.stgit@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 09:39:30 -0700
Message-ID: <BANLkTinJgo_wyQ1rVK-5_Auzg7J1PjVeyQ@mail.gmail.com>
Subject: Re: [PATCH] KEYS/DNS: Fix ____call_usermodehelper() to not lose the
 session keyring [ver #2]
To: David Howells <dhowells@redhat.com>
Cc: akpm@linux-foundation.org, jmorris@namei.org, shirishpargaonkar@gmail.com,
        keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Eric Paris <eparis@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks, this looks much nicer.

Applied.

                     Linus
