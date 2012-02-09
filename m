Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:55546 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754350Ab2BINoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2012 08:44:39 -0500
Date: Thu, 9 Feb 2012 08:44:29 -0500
From: Jim Rees <rees@umich.edu>
To: David Howells <dhowells@redhat.com>
Cc: jmorris@namei.org, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate
 name service errors
Message-ID: <20120209134429.GC6663@umich.edu>
References: <20120208141552.GA3273@umich.edu>
 <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
 <20120208122917.8902.78395.stgit@warthog.procyon.org.uk>
 <17614.1328781889@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <17614.1328781889@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells wrote:

  Jim Rees <rees@umich.edu> wrote:
  
  >   Define ENAMEUNKNOWN to indicate "Network name unknown".  This can be used to
  >   indicate, for example, that an attempt was made by dns_query() to make a query,
  >   but the name server (e.g. a DNS server) replied indicating that it had no
  >   matching records.
  > 
  > Would this be the same as NXDOMAIN?  That is, does it mean the name server
  > couldn't find a record, or does it mean that the record doesn't exist?
  
  Is there a way to tell the difference?  Can you store a negative record in the
  DNS?  Or is it that the DNS has records for the name, just not records of the
  type you're looking for (eg. NO_ADDRESS/NO_DATA from gethostbyname())?

It's an important distinction to the resolver if you want to avoid dns
hijacking.  See rfc2308.  There doesn't seem to be a way to tell the
difference from the gethostbyname call, which was designed before this was a
problem.  The on-the-wire dns query protocol does make the distinction.

I suspect kernel dns clients won't need to know the difference, but I think
it's useful if we decide on and document the meaning of the error codes.
Maybe the answer is that ENAMEUNKNOWN means the same as a HOST_NOT_FOUND
from gethostbyname().
