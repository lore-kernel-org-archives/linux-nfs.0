Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab2BIKFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 05:05:12 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120208141552.GA3273@umich.edu>
References: <20120208141552.GA3273@umich.edu> <20120208122905.8902.65762.stgit@warthog.procyon.org.uk> <20120208122917.8902.78395.stgit@warthog.procyon.org.uk>
To: Jim Rees <rees@umich.edu>
Cc: dhowells@redhat.com, jmorris@namei.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate name service errors
Date: Thu, 09 Feb 2012 10:04:49 +0000
Message-ID: <17614.1328781889@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

David
