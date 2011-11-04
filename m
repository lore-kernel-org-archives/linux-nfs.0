Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49053 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752973Ab1KDWck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 18:32:40 -0400
Date: Fri, 4 Nov 2011 18:32:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] 4.1 ENV: Reduce repetitive codes for open_file and
 create_file
Message-ID: <20111104223238.GO721@fieldses.org>
References: <4EAA7D37.9070504@cn.fujitsu.com>
 <4EAA7D84.4000901@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EAA7D84.4000901@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2011 at 06:01:40PM +0800, Mi Jinlong wrote:
> Reduce repetitive codes for open_file and create_file

OK, applied.--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/environment.py |   86 ++++++++++++++++++++++-------------
>  1 files changed, 54 insertions(+), 32 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
> index 43cb12b..6e68e83 100644
> --- a/nfs4.1/server41tests/environment.py
> +++ b/nfs4.1/server41tests/environment.py
> @@ -444,12 +444,15 @@ def create_obj(sess, path, kind=NF4DIR, attrs={FATTR4_MODE:0755}):
>      ops = use_obj(path[:-1]) + [op.create(kind, path[-1], attrs)]
>      return sess.compound(ops)
>  
> -def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
> -                access=OPEN4_SHARE_ACCESS_BOTH,
> -                deny=OPEN4_SHARE_DENY_NONE,
> -                mode=GUARDED4, verifier=None, want_deleg=False,
> -                # Setting the following should induce server errors
> -                seqid=0, clientid=0):
> +def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
> +                     access=OPEN4_SHARE_ACCESS_BOTH,
> +                     deny=OPEN4_SHARE_DENY_NONE,
> +		     mode=GUARDED4, verifier=None,
> +		     claim_type=CLAIM_NULL,
> +		     want_deleg=False,
> +		     deleg_type=None,
> +		     open_create=OPEN4_NOCREATE,
> +		     seqid=0, clientid=0):
>      # Set defaults
>      if path is None:
>          dir = sess.c.homedir
> @@ -457,16 +460,47 @@ def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>      else:
>          dir = path[:-1]
>          name = path[-1]
> +
>      if ((mode==EXCLUSIVE4) or (mode==EXCLUSIVE4_1)) and (verifier==None):
>          verifier = sess.c.verifier
> +
>      if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
>          access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
> -    # Create the file
> +
> +    # Open the file
> +    if claim_type==CLAIM_NULL:
> +        fh_op = use_obj(dir)
> +    elif claim_type==CLAIM_PREVIOUS:
> +        fh_op = [op.putfh(path)]
> +        name = None
> +
> +    if open_create==OPEN4_CREATE:
> +        openflag=openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier,
> +                                          creatverfattr(verifier, attrs)))
> +        openclaim=open_claim4(CLAIM_NULL, name)
> +    else:
> +        openflag=openflag4(OPEN4_NOCREATE)
> +        openclaim=open_claim4(claim_type, name, deleg_type)
> +
>      open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
> -                      openflag4(OPEN4_CREATE, createhow4(mode, attrs, verifier,
> -                                               creatverfattr(verifier, attrs))),
> -                      open_claim4(CLAIM_NULL, name))
> -    return sess.compound(use_obj(dir) + [open_op, op.getfh()])
> +                      openflag, openclaim)
> +
> +    return sess.compound(fh_op + [open_op, op.getfh()])
> +
> +def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
> +                access=OPEN4_SHARE_ACCESS_BOTH,
> +                deny=OPEN4_SHARE_DENY_NONE,
> +                mode=GUARDED4, verifier=None, want_deleg=False,
> +                # Setting the following should induce server errors
> +                seqid=0, clientid=0):
> +
> +    claim_type=CLAIM_NULL
> +    deleg_type=None
> +    open_create=OPEN4_CREATE
> +
> +    return open_create_file(sess, owner, path, attrs, access, deny, mode,
> +                            verifier, claim_type, want_deleg, deleg_type,
> +                            open_create, seqid, clientid)
>  
>  def open_file(sess, owner, path=None,
>                access=OPEN4_SHARE_ACCESS_READ,
> @@ -476,27 +510,15 @@ def open_file(sess, owner, path=None,
>                deleg_type=None,
>                # Setting the following should induce server errors
>                seqid=0, clientid=0):
> -    # Set defaults
> -    if path is None:
> -        dir = sess.c.homedir
> -        name = owner
> -    else:
> -        dir = path[:-1]
> -        name = path[-1]
> -    if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
> -        access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
> -    # Open the file
> -    if claim_type==CLAIM_NULL:
> -        fh_op = use_obj(dir)
> -    elif claim_type==CLAIM_PREVIOUS:
> -        fh_op = [op.putfh(path)]
> -        name = None
> -    if not want_deleg and access & OPEN4_SHARE_ACCESS_WANT_DELEG_MASK == 0:
> -        access |= OPEN4_SHARE_ACCESS_WANT_NO_DELEG
> -    open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
> -                      openflag4(OPEN4_NOCREATE),
> -                      open_claim4(claim_type, name, deleg_type))
> -    return sess.compound(fh_op + [open_op, op.getfh()])
> +
> +    attrs=None
> +    mode=None
> +    verifier=None
> +    open_create=OPEN4_NOCREATE
> +
> +    return open_create_file(sess, owner, path, attrs, access, deny, mode,
> +                            verifier, claim_type, want_deleg, deleg_type,
> +                            open_create, seqid, clientid)
>  
>  def create_confirm(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>                     access=OPEN4_SHARE_ACCESS_BOTH,
> -- 1.7.5.1 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html 
> 
