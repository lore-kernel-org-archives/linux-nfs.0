Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167Ab2BJUCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 15:02:38 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120209134429.GC6663@umich.edu>
References: <20120209134429.GC6663@umich.edu> <20120208141552.GA3273@umich.edu> <20120208122905.8902.65762.stgit@warthog.procyon.org.uk> <20120208122917.8902.78395.stgit@warthog.procyon.org.uk> <17614.1328781889@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: dhowells@redhat.com, jmorris@namei.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate name service errors
Date: Fri, 10 Feb 2012 20:02:05 +0000
Message-ID: <25436.1328904125@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees <rees@umich.edu> wrote:

>   > Would this be the same as NXDOMAIN?  That is, does it mean the name server
>   > couldn't find a record, or does it mean that the record doesn't exist?
>   
>   Is there a way to tell the difference?  Can you store a negative record in
>   the DNS?  Or is it that the DNS has records for the name, just not records
>   of the type you're looking for (eg. NO_ADDRESS/NO_DATA from
>   gethostbyname())?
> 
> It's an important distinction to the resolver if you want to avoid dns
> hijacking.  See rfc2308.  There doesn't seem to be a way to tell the
> difference from the gethostbyname call, which was designed before this was a
> problem.  The on-the-wire dns query protocol does make the distinction.
> 
> I suspect kernel dns clients won't need to know the difference, but I think
> it's useful if we decide on and document the meaning of the error codes.
> Maybe the answer is that ENAMEUNKNOWN means the same as a HOST_NOT_FOUND
> from gethostbyname().

Should I propose an extra error code?  Perhaps giving:

	ENONAMESERVICE	"Network name service unavailable"
	ENAMEUNKNOWN	"Network name not known"
	ENONAMERECORD	"Network name query returned no records"

Note that ENONAMESERVICE covers all of: not having a name service configured,
not being able to contact the configured name server and the configured name
server not being able to chain to the authoritative name server.  However, I
think this is probably okay.

David
