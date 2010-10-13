From: Jeff Layton <jlayton@redhat.com>
Subject: Re: whither NFS umount?
Date: Wed, 13 Oct 2010 14:56:01 -0400
Message-ID: <20101013145601.468acc2a@corrin.poochiereds.net>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
	<1286903046.24878.13.camel@heimdal.trondhjem.org>
	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
	<20101012151826.76b75f52@corrin.poochiereds.net>
	<1286912649.1956.19.camel@heimdal.trondhjem.org>
	<4CB5EF15.5030003@RedHat.com>
	<20101013141317.66f23906@corrin.poochiereds.net>
	<4CB5FE65.3090409@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868Ab0JMS4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 14:56:12 -0400
In-Reply-To: <4CB5FE65.3090409-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Oct 2010 14:45:57 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> I would say send the UMNT, since it does not cause any pain to send it
> verses the pain that could be cause by not sending it...
> 
> This is a perfect example of fixing something that is not
> broken... We can put our energy in better place that worrying
> about things like this... IMHO...

But it *is* broken. As Chuck pointed out, the main problem is that mtab
handling is broken on remounts. That's a real problem that needs to be
fixed.

I agree that our time is better spent elsewhere. I just think that we
ought to make that happen by eliminating the unnecessary umount helper.
The less code that we need to maintain, the better...

-- 
Jeff Layton <jlayton@redhat.com>
