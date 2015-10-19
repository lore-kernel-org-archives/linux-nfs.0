Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:52469 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752912AbbJSWBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Oct 2015 18:01:11 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
References: <012101d10853$7cae4ac0$760ae040$@mindspring.com> <20151019214801.GA16551@fieldses.org>
In-Reply-To: <20151019214801.GA16551@fieldses.org>
Subject: RE: Pull request for pynfs
Date: Mon, 19 Oct 2015 15:00:56 -0700
Message-ID: <01e401d10ab9$a2691c00$e73b5400$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Fri, Oct 16, 2015 at 01:44:42PM -0700, Frank Filz wrote:
> > Bruce,
> >
> > Please pull the top patch from:
> >
> > https://github.com/ffilz/pynfs/commits/master
> >
> > It fixes CID2 to allow NFS4_OK when SETCLIENTID with a different
> > principal replaces a clientid that has no state, and adds CID2a which
> > expects NFS4ERR_CLID_INUSE since it does have state.
> 
> Thanks!
> 
> This leave us with two test functions both named "testInUse".
> 
> I applied the following to get both tests working.

Oops, sorry...

Frank

> diff --git a/nfs4.0/servertests/st_setclientid.py
> b/nfs4.0/servertests/st_setclientid.py
> index 0fb59cd7f542..fbeab22e5026 100644
> --- a/nfs4.0/servertests/st_setclientid.py
> +++ b/nfs4.0/servertests/st_setclientid.py
> @@ -50,7 +50,7 @@ def testClientUpdateCallback(t, env):
>      res = c.close_file(t.code, fh, stateid)
>      check(res, msg="Close after updating callback info")
> 
> -def testInUse(t, env):
> +def testNotInUse(t, env):
>      """SETCLIENTID with same nfs_client_id.id should return NFS4ERR_OK
>         if there is no active state
> 


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

