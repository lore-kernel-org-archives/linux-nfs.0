Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:47267 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021Ab2BWF6f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 00:58:35 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: linux-image: on nfs4 server: RPC: AUTH_GSS upcall timed out Please check user daemon is running
In-Reply-To: <20111209191057.GA10089@fieldses.org>
References: <8762hrozdl.fsf@fifthhorseman.net> <20111208174501.GA30088@fieldses.org> <4EE253EC.2040609@fifthhorseman.net> <20111209191057.GA10089@fieldses.org>
Date: Thu, 23 Feb 2012 00:58:46 -0500
Message-ID: <87booq3xbd.fsf@pip.fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Dec 2011 14:10:57 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, Dec 09, 2011 at 01:31:08PM -0500, Daniel Kahn Gillmor wrote:
> > Thanks, that's useful.  Do the clients need to run cachefilesd as well
> > to take advantage of delegation?
> 
> No.

Is there a way that i can check to be sure that delegations are actually
happening?  What kind of performance improvement would you expect to see
with delegatons happening on, say, a standard desktop user's homedir
workload?

         --dkg
