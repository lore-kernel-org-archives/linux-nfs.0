Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gw1a.telemetry-investments.com ([64.20.161.180]:34865 "EHLO
	sv1.telemetry-investments.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754251Ab0LJPhV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 10:37:21 -0500
Date: Fri, 10 Dec 2010 10:37:16 -0500
From: "Andrew J. Schorr" <ajschorr@alumni.princeton.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: proposed patch to rpcbind to provide finer-grained security
 controls than offered by the -i option
Message-ID: <20101210153716.GA32725@ti93.telemetry-investments.com>
References: <20101209204913.GA30338@ti93.telemetry-investments.com>
 <DFA85276-FD83-47A6-A9CD-B0F0A11D6086@oracle.com>
 <4D016F44.3020002@RedHat.com>
 <20101210023847.GB15344@ti93.telemetry-investments.com>
 <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <77480D58-4224-4713-A515-F1BCC133F44F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 10, 2010 at 10:31:52AM -0500, Chuck Lever wrote:
> 
> Not to put to fine a point on it, but we discourage the use of indirect RPC calls.  It's a well-known security hole.  Also, allowing anyone to set and unset RPC registrations is also insecure, and is discouraged.
> 
> In general we want people to switch to using AF_UNIX for local registrations, as that is secure from remote attack, and allows rpcbind to assign ownership of the registration so that only the user who registered that service may unregister it.
> 
> > So I would argue that the patch is still a good thing, but I agree that
> > I should relink my code with libtirpc.
> 
> IMO we shouldn't add features that encourage people to configure rpcbind insecurely, especially when there are reasonable alternatives.

Well, if the patch won't be accepted, I will not put any more time into it.

But I do have one question: if glibc's RPC routines are deprecated in favor of
libtirpc, why not either remove the RPC code from glibc or at least mark these
functions deprecated so that people get warning messages when they rebuild code
(i.e. use __attribute__ (( __deprecated__ )) for all the functions declared in
/usr/include/rpc/*.h)?  There does not seem to be great documentation about
this change for ignorant users such as myself (who just upgraded Fedora
distros and unknowingly relinked with glibc instead of libtirpc).

Regards,
Andy
