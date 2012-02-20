Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193Ab2BTXEH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Feb 2012 18:04:07 -0500
Message-ID: <4F42D155.3010206@netapp.com>
Date: Mon, 20 Feb 2012 18:03:49 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Created a function for setting timeouts on keys
References: <1329415593-12270-1-git-send-email-bjschuma@netapp.com> <13987.1329772147@redhat.com>
In-Reply-To: <13987.1329772147@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/20/12 16:09, David Howells wrote:

> bjschuma@netapp.com wrote:
> 
>> David - Is there a better way to set the key rather than creating a new
>> function?  Should I have created the set_key_timeout() function in a
>> different place?
> 
> This is a reasonable way to do it and the right place (it's analogous to other
> stuff) - just can you call it key_set_timeout() instead please?


Sure, changing the name should be fairly easy.  Thanks for looking at this!

- Bryan

> 
> David


