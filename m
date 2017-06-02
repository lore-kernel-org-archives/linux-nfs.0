Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6383 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751140AbdFBJFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Jun 2017 05:05:52 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9C112C0587C1
        for <linux-nfs@vger.kernel.org>; Fri,  2 Jun 2017 09:05:46 +0000 (UTC)
Message-ID: <1496394344.4126.36.camel@redhat.com>
Subject: Re: [PATCH 2/3] nfs.conf tidy ups
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 02 Jun 2017 10:05:44 +0100
In-Reply-To: <65cbaa98-164b-e6a5-95f3-e6e07703cbb3@RedHat.com>
References: <1495468204.4169.10.camel@redhat.com>
         <65cbaa98-164b-e6a5-95f3-e6e07703cbb3@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-06-01 at 10:45 -0400, Steve Dickson wrote:
> Hello,
> 
> On 05/22/2017 11:50 AM, Justin Mitchell wrote:
> > Add function to cleanup and free the loaded config
> > 
> > Signed-off-by: Justin Mitchell <jumitche@rehat.com>
> > 
> > ---
> >  support/include/conffile.h |  1 +
> >  support/nfs/conffile.c     | 51 +++++++++++++++++++++++++++++++++++++++-------
> >  2 files changed, 45 insertions(+), 7 deletions(-)
> > 
> > diff --git a/support/include/conffile.h b/support/include/conffile.h
> > index 20b1a32..2d11a52 100644
> > --- a/support/include/conffile.h
> > +++ b/support/include/conffile.h
> > @@ -60,6 +60,7 @@ extern _Bool    conf_get_bool(char *, char *, _Bool);
> >  extern char    *conf_get_str(char *, char *);
> >  extern char    *conf_get_section(char *, char *, char *);
> >  extern void     conf_init(const char *);
> > +extern void     conf_cleanup(void);
> I don't see this being called any where? How is it being used?
> 
> steved.

It is not directly referenced yet, for completeness all of the programs
that use the conf file should call it as part of their shutdown, but of
course thats not vital when your process is exiting anyway.

it will however be more important for a library using the same code, and
for anything that is going to re-load its config or handle multiple
files.  

It also gets used in my memory leak testing.


