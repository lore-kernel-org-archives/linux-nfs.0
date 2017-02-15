Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751890AbdBOPLW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Feb 2017 10:11:22 -0500
Subject: Re: [PATCH 0/2] RFC: Libtirpc changes for RPCSEC_GSS version 3
To: andros@netapp.com
References: <1482509367-22381-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <9495725a-8ca0-5173-15e4-cd6a6dc27e40@RedHat.com>
Date: Wed, 15 Feb 2017 10:11:22 -0500
MIME-Version: 1.0
In-Reply-To: <1482509367-22381-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Andy

Where are we with these... Is there any kernel support needed?
If not are they ready to go?

Note: in Patch 2 there is an uncovered fprintf in clnt_vc_control
which is probably not needed... No need to repost just for that ;-)

steved.

On 12/23/2016 11:09 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
>
> This is a Request for Comment patch set for the GSSv3 prototype.
>
> Requires:
>
> - kernel patches: "RFC: RPCSEC_GSS Version 3 prototype: Full MOde MAC
> - gssd patches: "RFC: GSSD changes for RPCSEC_GSS version 3"
>
>
> Andy Adamson (2):
>   Use RPCSEC_GSS version 3
>   RPCSEC_GSSv3 new reply verifier
>
>  autogen.sh           |   0
>  src/auth_gss.c       | 195 +++++++++++++++++++++++++++++++++++++++++++++++++--
>  src/clnt_vc.c        |   1 +
>  src/debug.c          |   2 +-
>  tirpc/rpc/auth_gss.h |  10 ++-
>  5 files changed, 198 insertions(+), 10 deletions(-)
>  mode change 100644 => 100755 autogen.sh
>

