Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1a.telemetry-investments.com ([64.20.161.180]:46153 "EHLO
	sv1.telemetry-investments.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754667Ab0LJRKZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 12:10:25 -0500
Date: Fri, 10 Dec 2010 12:10:14 -0500
From: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: proposed patch to rpcbind to provide finer-grained security
 controls than offered by the -i option
Message-ID: <20101210171014.GA5280@ti93.telemetry-investments.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com>
 <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com>
 <4D016F44.3020002@RedHat.com>
 <20101210023847.GB15344@ti93.telemetry-investments.com>
 <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com>
 <4D024D70.7040108@RedHat.com>
 <FD9D05EF-FB57-45FB-BBDC-38E3B92D54AA@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <FD9D05EF-FB57-45FB-BBDC-38E3B92D54AA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 10, 2010 at 12:01:51PM -0500, Chuck Lever wrote:
> If we go with just the evidence at hand: Andrew says he can rebuild his application.  Thus, so far there is no specific requirement to expand "-i".  IMO we should wait until there is, in the most noble of Linux traditions.
> 

To be fair, this will require porting work on my side.  It is not a completely
trivial recompile, since some of the data structures have changed a little
bit.

I don't know whether removing from glibc is a great idea because of this
aspect.  The new TIRPC code is not 100% compatible (for example, struct XDR has
some differences in the xdr_ops).  I personally think that adding
'__attribute__ (( __deprecated__ ))' to all the function prototypes in
/usr/include/rpc/*.h would be a good first step, and also add a comment to the
header files directing people to port their code to the new tirpc API.

Anyway, that's my 2 cents.

Regards,
Andy
