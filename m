Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754118AbdCHSOm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 13:14:42 -0500
Message-ID: <1488989946.25839.3.camel@redhat.com>
Subject: Re: [gssproxy] migration from svcgssd to gssproxy results in
 regression.
From: Simo Sorce <simo@redhat.com>
To: The GSS-Proxy developers and users mailing list
        <gss-proxy@lists.fedorahosted.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 08 Mar 2017 11:19:06 -0500
In-Reply-To: <87lgsgissm.fsf@notabene.neil.brown.name>
References: <87lgsgissm.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-03-08 at 10:14 +1100, NeilBrown wrote:
> Hi,
>  I recently tried using gssproxy for krb5 authentication with nfsd.
>  This was because customer is using an AD kerberos master which uses
>  certificates which are too big for svcgssd to work with (i.e. larger
>  than one page).
> 
>  Unfortunately it doesn't work.
> 
>  The svcgssd code in nfs-utils calls
>    gss_display_name()
>  to get the name of the principal.  This returns something like
>  "user@domain".
> 
>  getpwnam() works perfectly on this (when nsswitch is set to use
> "winbind")
>  but svcgssd goes further and uses nfs4_gss_princ_to_ids() to perform
>  the lookup.  Presumably this is more general?
> 
>  gssproxy does neither of these.
>  It uses gss_localname() to get the user name, which returns
> something
>  like "user".
>  It then calls getpwnam() on that, which fails ("user@domain" or
>  "domain\user" both succeed).
> 
>  I have modified my copy to use gss_display_name() instead of
>  gss_localname() and it now appears to work perfectly ... for this
>  use-case at least.
> 
>  What is the right way forward here?
>  Is nfs4_gss_princ_to_ids() really necessary?
>  Should gssproxy use it, at least for requests from the NFS server?
>  Is there are good reason not to use gss_display_name() uniformly?
>  Maybe use gss_local_name(), and it that fails, or getpwnam fails,
>  use gss_display_name()??

No, you should configure krb5.conf to map to a fully qualified name if
that is what you normally want.

The default rule allows mapping only for the default realm and does so
by truncating away the realm name, but you can configure your own.

see auth_to_local_names directive in krb5.conf

Simo.
