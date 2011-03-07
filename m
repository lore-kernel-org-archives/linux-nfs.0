Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:50783 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753340Ab1CGQBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Mar 2011 11:01:06 -0500
Date: Mon, 7 Mar 2011 16:00:42 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-api@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate
 name service errors
Message-ID: <20110307160042.2ddc8e65@lxorguk.ukuu.org.uk>
In-Reply-To: <20110307150218.28218.84916.stgit@warthog.procyon.org.uk>
References: <20110307150208.28218.89348.stgit@warthog.procyon.org.uk>
	<20110307150218.28218.84916.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Define ENONAMESERVICE to indicate "Network name service unavailable".  This can
> be used to indicate, for example, that an attempt was made by dns_query() to
> make a query, but the name server (e.g. a DNS server) it is supposed to contact
> didn't answer or that it couldn't determine the location of a suitable server.

Are these in glibc and are there glibc patches submitted and accepted for
this ?

(I only ask because I know its previously taken years for glibc to catch
up with stuff)
