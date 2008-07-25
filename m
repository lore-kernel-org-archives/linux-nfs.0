From: Steve Dickson <SteveD@redhat.com>
Subject: Re: showmount issues
Date: Fri, 25 Jul 2008 14:51:01 -0400
Message-ID: <488A2095.7020507@RedHat.com>
References: <556445368AFA1C438794ABDA8901891C09193BE1@USA0300MS03.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, martyleisner@yahoo.com
To: "Leisner, Martin" <Martin.Leisner-Y/v6x+lg+nkAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbYGYSwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jul 2008 14:52:02 -0400
In-Reply-To: <556445368AFA1C438794ABDA8901891C09193BE1-Ji2iP3vdqghrBKYPBwKYhw99oQ+liPgx@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Leisner, Martin wrote:
> I have a system (which is using the legacy SUN derived rpcbind).
> 
> For some reason, showmount wasn't "always" working.   It reported
> nothing when running from the command line, but worked under strace
> (ugh!)
> 
> I was running fedora8 (showmount 1.1.0).
> I built nfs-utils 1.1.2 -- same problems.
> 
> (I just tried a 1.0.6 on a RedHat Enterprise Linux 3 -- it worked fine)
> 
> Running the code under gdb, I found some "interesting" problems...
Committed...

steved.
