Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60907 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab1H3SMJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 14:12:09 -0400
Received: by gxk21 with SMTP id 21so5861358gxk.19
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2011 11:12:08 -0700 (PDT)
From: "Matthew M. DeLoera" <mdeloera@exacq.com>
Content-Type: text/plain; charset=windows-1252
Subject: =?windows-1252?Q?GSS_and_gssglue_question=85=2E=2E?=
Date: Tue, 30 Aug 2011 14:12:23 -0400
Message-Id: <5DDA5D42-70BB-4BCB-8F89-04A6A8199451@exacq.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Greetings,

I have a hopefully very simple question, and any suggestions would be greatly appreciated…

In my app, basically doing the following, using gssglue/gssapi with gssapi_krb5. In my app:

OM_uint32 major = gss_import_name();
if (major == GSS_S_COMPLETE)
{
   major = gss_acquire_cred();
   gss_release_name();
}

I'm testing error handling when gssapi_krb5.so is missing (being dynamically loaded by GSS). I find that gss_import_name succeeds (always returns GSS_S_COMPLETE). I happen to be getting GSS_S_BAD_MECH from gss_acquire_cred. Regardless whether gss_acquire_cred succeeds or fails, I always call gss_release_name to avoid memory leakage. In this scenario, gss_release_name segfaults.

FYI, I'm working in Ubuntu 6.06 (libgssapi-dev 0.7-0ubuntu1). Having a little trouble determining the corresponding source version, so I apologize for that.

Basically, what's the recommended usage here? Is there any reason to *not* call gss_release_name? I see a shared object debug message from somewhere within gss_import_name, so I would normally expect it to fail, and use that to know whether to later release or not. Do I only release if gss_acquire_cred succeeds, maybe?

Otherwise, no problems. Just can't figure out the recommended usage here…. Any suggestions would be wonderful!

Regards,
- Matthew

