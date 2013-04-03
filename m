Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm5.bullet.mail.bf1.yahoo.com ([98.139.212.164]:21664 "HELO
	nm5.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760216Ab3DCGmn convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 02:42:43 -0400
References: <1364317202.2660.132.camel@willson.li.ssimo.org> <loom.20130327T154155-192@post.gmane.org> <515B2E7D.1050005@RedHat.com>
Message-ID: <1364970564.49524.YahooMailNeo@web161304.mail.bf1.yahoo.com>
Date: Tue, 2 Apr 2013 23:29:24 -0700 (PDT)
From: Alex Dubov <oakad@yahoo.com>
Reply-To: Alex Dubov <oakad@yahoo.com>
Subject: Re: Allow building nfs-utils directly against GSSAPI
To: Steve Dickson <SteveD@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <515B2E7D.1050005@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

>> 

>>  I can augment my patch to make use of your changes. Would you be willing to
>>  consider it?
> I when ahead and took Simo's patches but I would like to continue to work
> with on get your Heimdal build working again... What exactly broke?
> 


I thought you were CCed of follow up messages as well.

Basically, Simo's patches fix most of the problems with building on Heimdal
(these problems came from libgssglue direction). Only 3 problems remained, which
I addressed in the follow-up patch:

> 1. On some systems, only libroken.so is available (small fix to kerberos5.m4)
> 
> 2. krb5_util.c:check_for_target - Heimdal variant constructs a "pattern"
>    principal and uses krb5_cc_retrieve_cred to get a matching credential.
>    This should work on mit-krb5, so old method of iterating over every
>    credential in cache may possibly be dropped outright and "#$if" guard
>    omitted.
>    For the sake of the above I reformatted the old approach to make it a bit
>    more clear what's going on there.
> 
> 3. krb5_util.c:gssd_k5_err_msg - krb5_get_err_text is marked as deprecated,
>    at least on Heimdal. If krb5_get_error_message is available, it should not
>    be reached at all, thus "#elif" guard.


Per issue 2, Simo told me he's going to look at it himself, with a view to remove
"#if" branching altogether (present code at that location is mit-krb5 implementation
specific).

Issue 3 is somewhat not clear to me: should krb5_get_err_text stay at all?
It's deprecated on Heimdal and apparently is not supported on mit-krb5 at all.

Which other kerberos libraries may need to be supported by the code?

