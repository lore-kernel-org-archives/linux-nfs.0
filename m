From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Version check in aclocal/kerberos.m5
Date: Mon, 31 Mar 2008 09:38:34 -0400
Message-ID: <4d569c330803310638vec97b65u6d63080bc8df8f55@mail.gmail.com>
References: <20080330103159.GA4003@uio.no>
	 <4d569c330803310615n1eb6e911o1e09c3df2ee5a7e2@mail.gmail.com>
	 <20080331132926.GA10294@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:60679 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbYCaNii (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Mar 2008 09:38:38 -0400
Received: by ti-out-0910.google.com with SMTP id 28so372744tif.23
        for <linux-nfs@vger.kernel.org>; Mon, 31 Mar 2008 06:38:36 -0700 (PDT)
In-Reply-To: <20080331132926.GA10294-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 31, 2008 at 9:29 AM, Steinar H. Gunderson
<sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org> wrote:
> On Mon, Mar 31, 2008 at 09:15:37AM -0400, Kevin Coffman wrote:
>  > Hello Steinar,
>  > I'm not clear what you are looking to patch?
>  >
>  > It should be possible to improve the parsing in aclocal/kerberos5.m4
>  > to handle this situation.  Is that what you are looking for?
>
>  Yes, that was my idea.
>
>  My question was: Does this code actually originate in nfs-utils, or does it
>  come from somewhere else?

AFAIK, I am the only one to blame.  There are other versions of
configure tests for K5, but none that try to use the version number...
