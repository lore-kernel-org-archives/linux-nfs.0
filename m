Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab3JVMXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 08:23:21 -0400
Subject: Re: Strange cred expiry behavior
From: Simo Sorce <simo@redhat.com>
To: Weston Andros Adamson <dros@netapp.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs list <linux-nfs@vger.kernel.org>
In-Reply-To: <4BDA1624-63A7-4325-BB4B-4988C1D37127@netapp.com>
References: <85F2BCBA-9565-497F-BFF4-FEB29301D655@netapp.com>
	 <DCD436E3-9464-4BFB-8C1A-19912522824D@netapp.com>
	 <20131021222339.2f1978d8@corrin.poochiereds.net>
	 <1F9EA3CE-081B-4E9D-B83D-E6B33AE6FE1D@netapp.com>
	 <4BDA1624-63A7-4325-BB4B-4988C1D37127@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Oct 2013 12:23:15 +0000
Message-ID: <1382444595.9794.20.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-22 at 02:38 +0000, Weston Andros Adamson wrote:
> On Oct 21, 2013, at 10:31 PM, Weston Andros Adamson <dros@netapp.com>
>  wrote:
> 
> > 
> > On Oct 21, 2013, at 10:23 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> > 
> >> On Mon, 21 Oct 2013 23:53:16 +0000
> >> Weston Andros Adamson <dros@netapp.com> wrote:
> >> 
> >>> I traced this behavior back to:
> >>> 
> >>> commit 302de786930a2c533068f9d8909a817b40f07c32
> >>> Author: Simo Sorce <simo@redhat.com>
> >>> Date:   Fri Apr 19 13:02:36 2013 -0400
> >>> 
> >>>   gssd: Allow GSSAPI to try to acquire credentials first.
> >>> 
> >>> 
> >>> And in particular:
> >>> 
> >>> -               for (dirname = ccachesearch; *dirname != NULL; dirname++) {
> >>> +               /* Try first to acquire credentials directly via GSSAPI */
> >>> +               err = gssd_acquire_user_cred(uid, &gss_cred);
> >>> +               if (!err)
> >>> +                       create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> >>> +                                                            AUTHTYPE_KRB5, gss_cred);
> >>> +               /* if create_auth_rplc_client fails try the traditional method of
> >>> +                * trolling for credentials */
> >>> +               for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
> >>> 
> >> 
> >> 
> >>> A couple of things:
> >>> 
> >>> - If I get rid of the "Try first to acquire credentials directly via GSSAPI" part, expiry works as before.
> >>> 
> >> 
> >> 
> >> Steve just merged a couple of patches from me that change this code
> >> some. It's probably worth testing with those before you make any
> >> changes.
> >> 
> > 
> > Thanks, I'll check it out.
> 
> Bisecting brought me to 302de786930a2c533068f9d8909a817b40f07c32 and
> I've confirmed that the problem is still in steved's master branch as
> of today. Are you sure the patches you're thinking of have been
> merged?

TBH I do not expect those patches to make any difference in this case.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

