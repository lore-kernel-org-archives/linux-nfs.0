Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbaLRRGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 12:06:55 -0500
Date: Thu, 18 Dec 2014 12:06:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
Message-ID: <20141218170653.GG18179@fieldses.org>
References: <pan.2014.12.16.22.19.18@googlemail.com>
 <20141217212159.GA11517@fieldses.org>
 <5492C710.20104@googlemail.com>
 <20141218144856.GA18179@fieldses.org>
 <alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
 <20141218151914.GB18179@fieldses.org>
 <pan.2014.12.18.15.42.53@googlemail.com>
 <20141218163254.GF18179@fieldses.org>
 <549303FC.9090604@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <549303FC.9090604@googlemail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 18, 2014 at 05:42:36PM +0100, Holger Hoffstätte wrote:
> On 12/18/14 17:32, J. Bruce Fields wrote:
> > So this is two separate tests, both failed, the only difference is that
> > the tcpdump was run on the client in one case and the server in the
> > other?
> 
> Exactly: client first, then I realized you'd want to look at the server-side too.
> That being said..

Whoops, now I see, the server-side trace has the same problem, I just
overlooked it the first time.

> > Right, I suspect there's a bug in the server's encoding of the reply to
> > the READDIR rpc.  Odd that the encoding would look correct from the
> > point of view of tcpdump on the server but not from the point of view of
> > tcpdump on the client.
> 
> ..in order to rule out a mistake on my part with the two separate runs (which prevents correlated analysis) I was just about to boot the server back into 3.18.1 and re-run both client- and server-side traces simultaneously. However I have to head out for a bit first; will post that later today.

So this might still be interesting, but it's not a high priority.

--b.
