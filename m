Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59343 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799Ab2BTVJM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Feb 2012 16:09:12 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1329415593-12270-1-git-send-email-bjschuma@netapp.com>
References: <1329415593-12270-1-git-send-email-bjschuma@netapp.com>
To: bjschuma@netapp.com
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Created a function for setting timeouts on keys
Date: Mon, 20 Feb 2012 21:09:07 +0000
Message-ID: <13987.1329772147@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bjschuma@netapp.com wrote:

> David - Is there a better way to set the key rather than creating a new
> function?  Should I have created the set_key_timeout() function in a
> different place?

This is a reasonable way to do it and the right place (it's analogous to other
stuff) - just can you call it key_set_timeout() instead please?

David
