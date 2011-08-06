Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.ugent.be ([157.193.49.126]:54415 "EHLO smtp2.UGent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048Ab1HFNKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Aug 2011 09:10:47 -0400
Message-ID: <4E3D3D6B.7050102@debian.org>
Date: Sat, 06 Aug 2011 15:11:07 +0200
From: Luk Claes <luk@debian.org>
To: Jim Rees <rees@umich.edu>
CC: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] start-statd: Use bash as -p is no POSIX
References: <1312624768-2394-1-git-send-email-luk@debian.org> <20110806123858.GA20169@merit.edu>
In-Reply-To: <20110806123858.GA20169@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/06/2011 02:38 PM, Jim Rees wrote:
> Luk Claes wrote:
> 
>   sh -p is not guaranteed to be provided by POSIX shells. dash for instance
>   does not provide this, so use bash explicitly.
> 
> That's pretty funny.  The script requires a posix shell, which bash isn't by
> default, so it provides an undocumented (in my ubuntu man page) option to
> force bash into compliance.  Since the option itself isn't posix, we now
> require the use of this non-posix shell so we can guarantee posix
> compliance.

That would even be worse as the -p option in bash has *nothing* to do
with posix:

set -p's documentation in bash's manual:

Turn  on  privileged  mode.   In this mode, the
$ENV and $BASH_ENV  files  are  not  processed,
shell  functions  are  not  inherited  from the
environment,  and  the   SHELLOPTS,   BASHOPTS,
CDPATH,   and  GLOBIGNORE  variables,  if  they
appear in the environment, are ignored.  If the
shell   is  started  with  the  effective  user
(group) id not equal to the real  user  (group)
id,  and  the  -p option is not supplied, these
actions are taken and the effective user id  is
set  to  the real user id.  If the -p option is
supplied at startup, the effective user  id  is
not  reset.  Turning this option off causes the
effective user and group ids to be set  to  the
real user and group ids.

Cheers

Luk
