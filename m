From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Tue, 09 Dec 2008 15:31:48 -0500
Message-ID: <1228854708.30231.20.camel@heimdal.trondhjem.org>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net>
	 <493D253C.2040809@RedHat.com>
	 <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com>
	 <493DA5EC.5090805@RedHat.com> <20081208232816.GA18856@uio.no>
	 <493EC42C.2080901@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39811 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202AbYLIUcB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2008 15:32:01 -0500
In-Reply-To: <493EC42C.2080901-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-12-09 at 14:17 -0500, Steve Dickson wrote:
> 
> Steinar H. Gunderson wrote:
> > On Mon, Dec 08, 2008 at 05:55:40PM -0500, Steve Dickson wrote:
> >> Yes... one does pass pointers of struct sockaddr to the majority 
> >> of the network system call such as bind().. but conventionally 
> >> I've seen a lot of declare struct sockaddr as memory then typecasting 
> >> that memory into a struct sockaddr_in pointer...
> > 
> > That's just wrong. Don't do that :-) (Where have you seen this, by the way?)
> I believe all over the RPC code in the glibc... for one place...
> I have not looked at that code for a while so maybe I have
> it backwards... 

No. That sounds correct. struct sockaddr as defined both in the kernel
and in glibc deliberately contains 14 bytes of padding. The struct
sockaddr_in is padded so that it is exactly the same size as struct
sockaddr.

They are not, however, large enough to contain a struct sockaddr_in6.

Cheers
  Trond

