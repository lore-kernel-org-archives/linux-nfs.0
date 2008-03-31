From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Version check in aclocal/kerberos.m5
Date: Mon, 31 Mar 2008 09:15:37 -0400
Message-ID: <4d569c330803310615n1eb6e911o1e09c3df2ee5a7e2@mail.gmail.com>
References: <20080330103159.GA4003@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:1499 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbYCaNPw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Mar 2008 09:15:52 -0400
Received: by ik-out-1112.google.com with SMTP id c28so216115ika.5
        for <linux-nfs@vger.kernel.org>; Mon, 31 Mar 2008 06:15:38 -0700 (PDT)
In-Reply-To: <20080330103159.GA4003-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 30, 2008 at 6:31 AM, Steinar H. Gunderson <sesse@debian.org> wrote:
> Hi,
>
>  Does anyone know where the version check in aclocal/kerberos.m5 come from? I
>  need to patch it (Debian's krb5-config --version gives a version like
>  "1.6.3-beta1-debian", and it doesn't manage to strip away the -beta part),
>  but it's not clear to me who upstream really is. (At least I've seen the code
>  in several other projects.)
>
>  Any ideas?

Hello Steinar,
I'm not clear what you are looking to patch?

It should be possible to improve the parsing in aclocal/kerberos5.m4
to handle this situation.  Is that what you are looking for?

In hindsight, it probably makes more sense to use the version number
in aclocal/kerberos5.m4 to set feature-specific definitions rather
than continue to pass along the parsed version number.  (The version
number is currently used to determine which method to use to tell the
Kerberos library where to find the credentials.)

K.C.
