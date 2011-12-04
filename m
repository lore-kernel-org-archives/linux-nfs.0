Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55608 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab1LDMrV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:47:21 -0500
Received: by eaak14 with SMTP id k14so3580040eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 04:47:20 -0800 (PST)
Message-ID: <4EDB6BD4.1080007@tonian.com>
Date: Sun, 04 Dec 2011 14:47:16 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] demo test for current stateid
References: <1323000111-21355-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323000111-21355-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-04 14:01, Tigran Mkrtchyan wrote:
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/environment.py |   26 ++++++++++++++++++++++++++
>  nfs4.1/server41tests/st_open.py     |   13 +++++++++++++
>  2 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
> index 6e68e83..74fe42f 100644
> --- a/nfs4.1/server41tests/environment.py
> +++ b/nfs4.1/server41tests/environment.py
> @@ -502,6 +502,32 @@ def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>                              verifier, claim_type, want_deleg, deleg_type,
>                              open_create, seqid, clientid)
>  
> +def create_and_close_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
> +                access=OPEN4_SHARE_ACCESS_BOTH,
> +                deny=OPEN4_SHARE_DENY_NONE,
> +                mode=GUARDED4, verifier=None, want_deleg=False,
> +                # Setting the following should induce server errors
> +                seqid=0, clientid=0):
> +
> +    current_stateid = stateid4(1 , "\0" * 12)
> +    # Set defaults
> +    if path is None:
> +        dir = sess.c.homedir
> +        name = owner
> +    else:
> +        dir = path[:-1]
> +        name = path[-1]
> +    if ((mode==EXCLUSIVE4) or (mode==EXCLUSIVE4_1)) and (verifier==None):
> +        verifier = sess.c.verifier
> +    if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:

nit: for clarity, how about using parenthesis around the arithmetic
and boolean expressions?

> +        access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
> +    # Create the file
> +    open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
> +                      openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier,
> +                                               creatverfattr(verifier, attrs))),
> +                      open_claim4(CLAIM_NULL, name))
> +    return sess.compound(use_obj(dir) + [open_op, op.getfh(), op.close(seqid, current_stateid)])
> +
>  def open_file(sess, owner, path=None,
>                access=OPEN4_SHARE_ACCESS_READ,
>                deny=OPEN4_SHARE_DENY_NONE,
> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> index bd995a5..92034a3 100644
> --- a/nfs4.1/server41tests/st_open.py
> +++ b/nfs4.1/server41tests/st_open.py
> @@ -1,6 +1,7 @@
>  from st_create_session import create_session
>  from nfs4_const import *
>  from environment import check, checklist, fail, create_file, open_file
> +from environment import create_and_close_file
>  from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>  from nfs4_type import creatverfattr, fattr4
>  import nfs4_ops as op
> @@ -200,3 +201,15 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
>      res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
>                          verifier = "Justtest")
>      check(res, NFS4ERR_EXIST)
> +
> +
> +def testCurretStateid(t, env):

nit: s/Curret/Current/

Benny

> +    """Test OPEN and CLOSE within same compound
> +
> +    FLAGS: open all
> +    CODE: OPEN7
> +    """
> +    sess1 = env.c1.new_client_session(env.testname(t))
> +
> +    res = create_and_close_file(sess1, env.testname(t), mode=EXCLUSIVE4_1)
> +    check(res, NFS4_OK)
