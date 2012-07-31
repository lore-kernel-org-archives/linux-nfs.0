Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36995 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139Ab2GaU7d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 16:59:33 -0400
Date: Tue, 31 Jul 2012 16:59:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: don't call poll() twice a second
Message-ID: <20120731205931.GA32161@fieldses.org>
References: <20120727210247.GC6388@fieldses.org>
 <20120727230853.GA2707@umich.edu>
 <20120729174839.GK6388@fieldses.org>
 <5015C2AA.9020608@RedHat.com>
 <20120730205949.GA21730@fieldses.org>
 <20120730221039.GB21730@fieldses.org>
 <50180CE2.3040300@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50180CE2.3040300@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 12:50:42PM -0400, Steve Dickson wrote:
> On 07/30/2012 06:10 PM, J. Bruce Fields wrote:
> > Eh, I'm leaning toward just using ppoll.  According to the man page that
> > requires kernel >= 2.6.16, glibc >= 2.4.  Is that OK?
> I would think so.... 

OK.  With ppoll, and split up into little pieces this time.

--b.
