Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470Ab2BIKBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 05:01:42 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <22934.1328745230@turing-police.cc.vt.edu>
References: <22934.1328745230@turing-police.cc.vt.edu> <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
To: Valdis.Kletnieks@vt.edu
Cc: dhowells@redhat.com, jmorris@namei.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 1/2] Define ENOAUTHSERVICE to indicate "Authentication service unavailable"
Date: Thu, 09 Feb 2012 10:01:13 +0000
Message-ID: <17357.1328781673@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Valdis.Kletnieks@vt.edu wrote:

> Was this an intentional overload of 139 (and so on for other archs)?  Just
> checking - I'm sure if it goes in like this, we'll see a patch to "fix" the
> collision for 3.16.0 or so... ;)

Ummm...  Odd...  I'm surprised StGIT managed to reapply my patches with no
warning.  I'll fix the numbering in them.

David
