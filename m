Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34368 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753289AbdCHOWT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 09:22:19 -0500
Date: Wed, 8 Mar 2017 09:15:00 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: gss-proxy@lists.fedorahosted.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: migration from svcgssd to gssproxy results in regression.
Message-ID: <20170308141500.3swdz3mpccw3hrid@tonberry.usersys.redhat.com>
References: <87lgsgissm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87lgsgissm.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On Wed, 08 Mar 2017, NeilBrown wrote:

> 
> Hi,
>  I recently tried using gssproxy for krb5 authentication with nfsd.
>  This was because customer is using an AD kerberos master which uses
>  certificates which are too big for svcgssd to work with (i.e. larger
>  than one page).
> 
>  Unfortunately it doesn't work.
> 
>  The svcgssd code in nfs-utils calls
>    gss_display_name()
>  to get the name of the principal.  This returns something like
>  "user@domain".
> 
>  getpwnam() works perfectly on this (when nsswitch is set to use "winbind")
>  but svcgssd goes further and uses nfs4_gss_princ_to_ids() to perform
>  the lookup.  Presumably this is more general?
> 
>  gssproxy does neither of these.
>  It uses gss_localname() to get the user name, which returns something
>  like "user".

Are using SSSD by any chance?  I had a similar issue in RHEL maybe a
year ago.  If you're using SSSD there's a localauth plugin that needs to
be enabled that will cause krb5_aname_to_localname() (which is called by
gss_localname()) to return a fully-qualified username instead of the
short username.

-Scott

>  It then calls getpwnam() on that, which fails ("user@domain" or
>  "domain\user" both succeed).
> 
>  I have modified my copy to use gss_display_name() instead of
>  gss_localname() and it now appears to work perfectly ... for this
>  use-case at least.
> 
>  What is the right way forward here?
>  Is nfs4_gss_princ_to_ids() really necessary?
>  Should gssproxy use it, at least for requests from the NFS server?
>  Is there are good reason not to use gss_display_name() uniformly?
>  Maybe use gss_local_name(), and it that fails, or getpwnam fails,
>  use gss_display_name()??
> 
> Thanks,
> NeilBrown


