Return-Path: <SRS0=2fom=QY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F686C43381
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 23:11:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 040F3218AC
	for <linux-nfs@archiver.kernel.org>; Sun, 17 Feb 2019 23:11:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727030AbfBQXLK convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 17 Feb 2019 18:11:10 -0500
Received: from mout.gmx.net ([212.227.17.22]:56513 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727007AbfBQXLK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 17 Feb 2019 18:11:10 -0500
Received: from onion.lan ([62.178.200.226]) by mail.gmx.com (mrgmx102
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0MW9TR-1gWwTH3MPh-00XKEB; Mon, 18
 Feb 2019 00:11:02 +0100
Date:   Mon, 18 Feb 2019 00:11:53 +0100
From:   Peter Wagner <tripolar@gmx.at>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
Message-ID: <20190218001153.3d21b28c@onion.lan>
In-Reply-To: <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
References: <20190217173901.33296254@onion.lan>
        <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
X-Provags-ID: V03:K1:mC8i+qwQCVE/LE1On0knu4Oh0eQ4ifvCws/DXUcmL0vzSs3Fblo
 /U1Lm8cq/xOvcfmkUDajpiUAIiWH8ldBVvxmdqlYxZWaHy7jm49dVIWLyAPA9UiCR8LQEcN
 +vA5FPNEdPkE1ZePew80Jt1mKoqu5OoXqjePBmFFZGUhZZGkQaT5G0ctDxeOgWIBu5/g4ix
 ZP/bjPY6cb1YwYF/+pJkw==
X-UI-Out-Filterresults: notjunk:1;V03:K0:8t1jKvDdd8o=:FKVDTffQmRClFfE0gEKScn
 nw63YZ1rBnrtjzcxsBViYJdstYP1NANSdaufi7Cy9BhWRK5kd20vS3lONPrvUZL9wxaCr0wpX
 qJdENJeCFWdqZkar4SW5Xd5h3dyA3/iyEl6bWd2XtFdY9NOeM8Bq0R2AcZqcO608Q+14sjFKZ
 Co0lEGxlxWnpwVC8oWU/njrRe15+FJRfq02jmNlw7LwmeSou7jgLWC3ba2Dx10TX5qCYbWpV2
 wkyVFgi9a7asYsuq4aomQLx/h6syF0p304J0KxUAg7JkUwL2YeEyhbW6oIYYOLjR0YZctGA8K
 v3AWvT5zlp1VqmkVwTRBXra6vnLxOaDHR0AyYVvWZ3+FcZHMsSQIb6vmTqysfSc4Li16OrvT0
 SVwVyivHzDPB2t9Cq9cknYoAxRh9TgvtqZ7wlFXVTJl2yu+uf6RfxIZKEoruv5ZkKLk25Z1Fh
 bUF5PQrMTiR9Dt1FIIICstIKu4Frzh/PIR9o/dqX6Rv73xDpELS82sTiDZVGNEtxEq4sfXxcC
 ImbBmA69bgSauePodPHRMsK+YszUPmpGXSaO6M6Ina3ta3arixy6irIVuGSNTW85PzEZdl1ym
 IuImv/2PpsJH//yJ76T6Nu4lWiyKA9xNgzQu0w0EjJqaFQRizgLpKvSIuDr3faUJbANcUEpdB
 vETDwBPiJKh/s6ZbrXDXbIi0XnOc/WHfwb1W/+KrtzYkNvlzbUoXN41MFDPm1BjPqWSWQnrkM
 fYdAbzsAcmq7z+YiQKUXuzAOJrfJoG3FQqFQ7wO4Re1avzd2pgdv8hogwHGQrQ/u4GGTPuH9h
 HXStecDb4eMop/FJIxiBlAoJRKS0DtzHUQxr4xZ8FREmF+Q2HQlEABCxuMWX+u0kz8zN8gjrg
 ITWFRZIUhqbX1/qD4Fc37aD7Ci+ZyVho4tJff7F4KpO8WjT1po7C8ibiuJk0nxZiycukVrgO0
 ccfCRQYDdYA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

> It might be cleaner to define a local version of freeaddrinfo in
> nfs-utils to reduce duplication of code and provide a place
> in the code itself to document this issue with a comment.

But why use a local freeaddrinfo function? The code is checking at
multiple places if an addrinfo* == NULL and if it's NULL it just returns
without freeing it and at some other places it just frees it. For 
censistence reasions i would propose to check if it's != NULL before 
freeing it.

The spec also just defines the != NULL case and we shouldn't depend on
undefined behavior imho.

Regards,
Peter



On Sun, 17 Feb 2019 12:40:10 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Peter-
> 
> > On Feb 17, 2019, at 11:39 AM, Peter Wagner <tripolar@gmx.at> wrote:
> > 
> > Afer the update to musl 1.1.21 freeaddrinfo is broken in some
> > places in the nfs-utils code because glibc seems to ignore when
> > freeaddrinfo is called with a NULL pointer which seems to be not
> > defined in the spec.
> > 
> > See: https://www.openwall.com/lists/musl/2019/02/03/4  
> 
> It might be cleaner to define a local version of freeaddrinfo in
> nfs-utils to reduce duplication of code and provide a place
> in the code itself to document this issue with a comment.
> 
> 
> > The free in support/export/hostname.c is removed too
> > 
> > See: https://www.openwall.com/lists/musl/2019/02/17/2  
> 
> Actually this seems like a separate issue because a distribution
> that uses another C library might decide it is pertinent to apply
> separately from the other changes here.
> 
> Please create a separate patch. It should remove the free(3)
> call instead of commenting it out, and the patch description
> should have its own copy of Rich’s email comments.
> 
> Thanks!
> 
> 
> > From 43e27735553b4c1e75964f32b2f887e84398055f Mon Sep 17 00:00:00
> > 2001 From: Peter Wagner <tripolar@gmx.at>
> > Date: Sun, 17 Feb 2019 17:32:08 +0100
> > Subject: [PATCH] fix addrinfo usage
> > 
> > Signed-off-by: Peter Wagner <tripolar@gmx.at>
> > ---
> > support/export/client.c   |  3 ++-
> > support/export/hostname.c |  2 +-
> > utils/exportfs/exportfs.c | 12 ++++++++----
> > utils/mount/stropts.c     |  3 ++-
> > utils/mountd/cache.c      |  6 ++++--
> > utils/statd/hostname.c    |  6 ++++--
> > 6 files changed, 21 insertions(+), 11 deletions(-)
> > 
> > diff --git a/support/export/client.c b/support/export/client.c
> > index baf59c8..750eb7d 100644
> > --- a/support/export/client.c
> > +++ b/support/export/client.c
> > @@ -309,7 +309,8 @@ client_lookup(char *hname, int canonical)
> >       init_addrlist(clp, ai);
> > 
> > out:
> > -    freeaddrinfo(ai);
> > +    if (ai)
> > +        freeaddrinfo(ai);
> >   return clp;
> > }
> > 
> > diff --git a/support/export/hostname.c b/support/export/hostname.c
> > index 5c4c824..710bf61 100644
> > --- a/support/export/hostname.c
> > +++ b/support/export/hostname.c
> > @@ -354,7 +354,7 @@ host_numeric_addrinfo(const struct sockaddr
> > *sap)
> >    * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
> >    */
> >   if (ai != NULL) {
> > -        free(ai->ai_canonname);        /* just in case */
> > +        //free(ai->ai_canonname);        /* just in case */
> >       ai->ai_canonname = strdup(buf);
> >       if (ai->ai_canonname == NULL) {
> >           freeaddrinfo(ai);
> > diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> > index cd3c979..2f8d59a 100644
> > --- a/utils/exportfs/exportfs.c
> > +++ b/utils/exportfs/exportfs.c
> > @@ -282,7 +282,8 @@ exportfs_parsed(char *hname, char *path, char
> > *options, int verbose) validate_export(exp);
> > 
> > out:
> > -    freeaddrinfo(ai);
> > +    if (ai)
> > +        freeaddrinfo(ai);
> > }
> > 
> > static int exportfs_generic(char *arg, char *options, int verbose)
> > @@ -395,7 +396,8 @@ unexportfs_parsed(char *hname, char *path, int
> > verbose) if (!success)
> >       xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname,
> > path);
> > 
> > -    freeaddrinfo(ai);
> > +    if (ai)
> > +        freeaddrinfo(ai);
> > }
> > 
> > static int unexportfs_generic(char *arg, int verbose)
> > @@ -639,8 +641,10 @@ matchhostname(const char *hostname1, const
> > char *hostname2) }
> > 
> > out:
> > -    freeaddrinfo(results1);
> > -    freeaddrinfo(results2);
> > +    if (results1)
> > +        freeaddrinfo(results1);
> > +    if (results2)
> > +        freeaddrinfo(results2);
> >   return result;
> > }
> > 
> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> > index 0a25b1f..8b7a0a8 100644
> > --- a/utils/mount/stropts.c
> > +++ b/utils/mount/stropts.c
> > @@ -1268,7 +1268,8 @@ int nfsmount_string(const char *spec, const
> > char *node, char *type, } else
> >       nfs_error(_("%s: internal option parsing error"), progname);
> > 
> > -    freeaddrinfo(mi.address);
> > +    if (mi.address)
> > +        freeaddrinfo(mi.address);
> >   free(mi.hostname);
> >   return retval;
> > }
> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> > index 7e8d403..8cee1c8 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -834,7 +834,8 @@ static void nfsd_fh(int f)
> > out:
> >   if (found_path)
> >       free(found_path);
> > -    freeaddrinfo(ai);
> > +    if(ai)
> > +        freeaddrinfo(ai);
> >   free(dom);
> >   xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ?
> > found->e_path : NULL); }
> > @@ -1355,7 +1356,8 @@ static void nfsd_export(int f)
> >   xlog(D_CALL, "nfsd_export: found %p path %s", found, path ?
> > path : NULL); if (dom) free(dom);
> >   if (path) free(path);
> > -    freeaddrinfo(ai);
> > +    if (ai)
> > +        freeaddrinfo(ai);
> > }
> > 
> > 
> > diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
> > index 8cccdb8..6556ab1 100644
> > --- a/utils/statd/hostname.c
> > +++ b/utils/statd/hostname.c
> > @@ -308,8 +308,10 @@ statd_matchhostname(const char *hostname1,
> > const char *hostname2) }
> > 
> > out:
> > -    freeaddrinfo(results2);
> > -    freeaddrinfo(results1);
> > +    if (results2)
> > +        freeaddrinfo(results2);
> > +    if (results1)
> > +        freeaddrinfo(results1);
> > 
> >   xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
> >           hostname1, hostname2,
> > -- 
> > 2.20.1
> >   
> 

