From: Steve Dickson <SteveD@redhat.com>
Subject: Re: libtirpc and nis
Date: Wed, 03 Jun 2009 11:14:44 -0400
Message-ID: <4A269364.2080304@RedHat.com>
References: <200906031002.38551.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46747 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579AbZFCPRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 11:17:47 -0400
In-Reply-To: <200906031002.38551.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mike Frysinger wrote:
> the libtirpc package is self described as a "standalone package".  i wonder 
> how far that actually goes.  wrt NIS, it requires the system C library to 
> provide NIS functionality or you get a build failure in a few files.  would be 
> nice if libtirpc were usable without any NIS baggage at all.
NIS used RPC procedures to communicate. As it stands today
NIS is currently using the RPC procedures glibc. In the
future there is a very good chance that NIS will start
using the RPC procedures in libtirpc especially if 
IPV6 support is needed...   

So I'm a bit confused on what you mean by "NIS baggage"
in the libtirpc package. 

steved.

