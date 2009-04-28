From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils-1.1.6 released.
Date: Tue, 28 Apr 2009 11:29:18 -0400
Message-ID: <20090428152918.GF17891@fieldses.org>
References: <49ECB9E6.4010001@RedHat.com> <49EDFE21.2000007@arx.net> <49EF3A83.50409@RedHat.com> <20090422155427.GA8712@fieldses.org> <49F6E9B3.2090508@arx.net> <20090428150551.GE17891@fieldses.org> <49F71D66.4070204@arx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34379 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932630AbZD1P3U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 11:29:20 -0400
In-Reply-To: <49F71D66.4070204-nz9JlX+3IF8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2009 at 06:14:46PM +0300, Thanos Chatziathanassiou wrote:
> I already did and attached it as nfs.pkt before. Is it missing something ?

Whoops, sorry, wasn't paying attention.

So, yes, if you look at the "Remote Procedure Call"->"Credentials" on
the next-to-last packet (#25), you'll see that it's sending the CREATE
with AUTH_NULL credentials field.

So the create's going to be done with nfsnobody credentials, and won't
succeed unless it's in a world-writeable directory.

The mount reply (packet #10) is listing the flavors as: AUTH_NULL,
AUTH_UNIX, RPCSEC_GSS_KRB5, RPCSEC_GSS_KRB5I, RPCSEC_GSS_KRB5P in that
order.  The client may just be choosing the first?

I seem to recall a couple bugs in this area that were fixed recently,
but can't find those now.

--b.
