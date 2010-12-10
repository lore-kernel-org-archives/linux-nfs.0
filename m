Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18359 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab0LJRQN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 12:16:13 -0500
Subject: Re: proposed patch to rpcbind to provide finer-grained security controls than offered by the -i option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101210171014.GA5280@ti93.telemetry-investments.com>
Date: Fri, 10 Dec 2010 12:14:47 -0500
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <0F5A7F8B-AA38-4653-BCDC-B192FF790F51@oracle.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com> <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com> <4D016F44.3020002@RedHat.com> <20101210023847.GB15344@ti93.telemetry-investments.com> <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com> <4D024D70.7040108@RedHat.com> <FD9D05EF-FB57-45FB-BBDC-38E3B92D54AA@oracle.com> <20101210171014.GA5280@ti93.telemetry-investments.com>
To: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 10, 2010, at 12:10 PM, Andrew J. Schorr wrote:

> On Fri, Dec 10, 2010 at 12:01:51PM -0500, Chuck Lever wrote:
>> If we go with just the evidence at hand: Andrew says he can rebuild his application.  Thus, so far there is no specific requirement to expand "-i".  IMO we should wait until there is, in the most noble of Linux traditions.
>> 
> 
> To be fair, this will require porting work on my side.  It is not a completely
> trivial recompile, since some of the data structures have changed a little
> bit.

The libtirpc legacy API should be the same as the glibc RPC API.  If you spot any truly non-ABI compatible changes, or have any other related questions, please let us know.  (we should probably cc libtirpc-devel@sourceforge.net).

> I don't know whether removing from glibc is a great idea because of this
> aspect.  The new TIRPC code is not 100% compatible (for example, struct XDR has
> some differences in the xdr_ops).  I personally think that adding
> '__attribute__ (( __deprecated__ ))' to all the function prototypes in
> /usr/include/rpc/*.h would be a good first step, and also add a comment to the
> header files directing people to port their code to the new tirpc API.

A port to the new API shouldn't be necessary.  libtirpc has all of the legacy API available.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




