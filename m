Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58943 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030AbaG2VJE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jul 2014 17:09:04 -0400
Date: Tue, 29 Jul 2014 17:09:02 -0400
To: "McEvoy, James" <james.mcevoy@hp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 ACL reference implementation
Message-ID: <20140729210901.GA24471@fieldses.org>
References: <6301806E96421841896741228C6B1A2764A7C51F@G4W3216.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6301806E96421841896741228C6B1A2764A7C51F@G4W3216.americas.hpqcorp.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 07:18:03PM +0000, McEvoy, James wrote:
> Is there a working NFSv4.1 reference implementation available and are there any instructs on how to build/install it? 

I don't recall seeing any, no.

(Most NFSv4.0 ACL implementations should still be perfectly compliant
with the NFSv4.1 spec too as far as I know.  But I don't know of any
implementations of the ACL features that are new to RFC 5661.  Is there
any particular feature that you're interested in?)

--b.
