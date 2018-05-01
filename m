Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60908 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754630AbeEAOWk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 May 2018 10:22:40 -0400
Subject: Re: Patches: fix non-standard getaddrinfo usage, minor fixups (fix
 w/musl)
To: Will Dietz <w@wdtz.org>, linux-nfs@vger.kernel.org
References: <CAKGWAO_DsJWLeKCrDytXLGUM-Je+P6T6d9z8P=tV_PCgJAYxzw@mail.gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3c7482ac-9281-0451-261b-93a93efc54f4@RedHat.com>
Date: Tue, 1 May 2018 10:22:39 -0400
MIME-Version: 1.0
In-Reply-To: <CAKGWAO_DsJWLeKCrDytXLGUM-Je+P6T6d9z8P=tV_PCgJAYxzw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/29/2018 07:16 PM, Will Dietz wrote:
> The getaddrinfo problem needs a proper fix and probably a
> consideration of similar patterns elsewhere in the code.
> 
> The others are relatively straightforward and are more suitable for use as-is.
> 
> A fix not included would be to avoid using "-Werror" except when
> developing-- or at least make its use optional.  Without knowledge of
> the compilers used by downstream, this option may cause builds to fail
> for unimportant reasons (and even if it works with all compilers
> today, it might not tomorrow...).   Would be nice to have that in
> before the next tagged release :).  GCC 7.3.0 seems to be unhappy with
> some prototypes for example, I don't have them handy but can send them
> along if that'd be useful.
> 
> Thanks! LMK if you have any questions or concerns, hopefully these are helpful.
Having the patch attached like this makes it very different to review 
and comment on... It much better when patches are posted in a thread. 

Could you please repost these patch in a thread format...
Here is the command I use:

DRYRUN=--dry-run
DIR=/tmp
git send-email $DRYRUN  --suppress-cc=all --suppress-from --no-chain-reply-to \
   --from "My Name <myname@domain.com>" \
   --to "Linux NFS Mailing list <linux-nfs@vger.kernel.org>" \
   --smtp-server smtp.com $DIR/*.patch

tia,

steved
