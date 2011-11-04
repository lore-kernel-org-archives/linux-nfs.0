Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59159 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752973Ab1KDWfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 18:35:10 -0400
Date: Fri, 4 Nov 2011 18:35:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] CLNT: add some tests for DESTROY_CLIENTID
Message-ID: <20111104223509.GP721@fieldses.org>
References: <4E9FE273.80500@cn.fujitsu.com>
 <20111020094355.GE5444@fieldses.org>
 <4E9FF123.2060704@cn.fujitsu.com>
 <20111020100202.GF5444@fieldses.org>
 <4E9FF46D.5090003@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9FF46D.5090003@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 06:14:05PM +0800, Mi Jinlong wrote:
> Some tests for DESTROY_CLIENTID at pynfs41.

Thanks, applied.

(Nit: you use the same description ("add some tests for
DESTROY_CLIENTID") on both the subject line and in the body of the
email.  It would be better to use the body for additional detail, or
just leave it blank if you don't have any.)

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/__init__.py            |    1 +
>  nfs4.1/server41tests/st_destroy_clientid.py |   98 +++++++++++++++++++++++++++
>  2 files changed, 99 insertions(+), 0 deletions(-)
>  create mode 100644 nfs4.1/server41tests/st_destroy_clientid.py
> 
> diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
> index 1cc2048..eb92538 100644
> --- a/nfs4.1/server41tests/__init__.py
> +++ b/nfs4.1/server41tests/__init__.py
> @@ -2,6 +2,7 @@ __all__ = ["st_exchange_id.py", # draft 21
>             "st_compound.py",
>             "st_create_session.py",
>             "st_destroy_session.py",
> +           "st_destroy_clientid.py",
>             "st_reclaim_complete.py",
>             "st_secinfo_no_name.py",
>             "st_secinfo.py",
> diff --git a/nfs4.1/server41tests/st_destroy_clientid.py b/nfs4.1/server41tests/st_destroy_clientid.py
> new file mode 100644
> index 0000000..1b193cf
> --- /dev/null
> +++ b/nfs4.1/server41tests/st_destroy_clientid.py
> @@ -0,0 +1,98 @@
> +from st_create_session import create_session
> +from nfs4_const import *
> +from environment import check, fail
> +import nfs4_ops as op
> +import nfs4lib
> +
> +def testSupported(t, env):
> +    """ Do a simple DESTROY_CLIENTID
> +        destroy an unconfirmed clientid without session
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID1
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +
> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> +    check(res)
> +
> +def testDestroyCIDWS(t, env):
> +    """ destroy an unconfirmed clientid with session
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID2
> +    """
> +    c1 = env.c1.new_client("%s_1" % env.testname(t))
> +    c2 = env.c1.new_client("%s_2" % env.testname(t))
> +    sess = c1.create_session()
> +
> +    res = sess.compound([op.destroy_clientid(c2.clientid)])
> +    check(res)
> +
> +def testDestroyBadCIDWS(t, env):
> +    """ destroy a nonexistant clientid without session
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID3
> +    """
> +    res = env.c1.compound([op.destroy_clientid(0)])
> +    check(res, NFS4ERR_STALE_CLIENTID)
> +
> +def testDestroyBadCIDIS(t, env):
> +    """ destroy a nonexistant clientid in session
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID4
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    res = sess.compound([op.destroy_clientid(0)])
> +    check(res, NFS4ERR_STALE_CLIENTID)
> +
> +def testDestroyCIDSessionB(t, env):
> +    """ destroy clientid using a session belong to that client
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID5
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    res = sess.compound([op.destroy_clientid(c.clientid)])
> +    check(res, NFS4ERR_CLIENTID_BUSY)
> +
> +def testDestroyCIDCSession(t, env):
> +    """ destroy a clientid which contains session without session
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID6
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> +    check(res, NFS4ERR_CLIENTID_BUSY)
> +
> +def testDestroyCIDNotOnly(t, env):
> +    """ destroy a clientid without session with other compound
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID7
> +    """
> +    res = env.c1.compound([op.destroy_clientid(0), op.reclaim_complete(TRUE)])
> +    check(res, NFS4ERR_NOT_ONLY_OP)
> +
> +def testDestroyCIDTwice(t, env):
> +    """ destroy a clientid twice without session
> +
> +    FLAGS: destroy_clientid all
> +    CODE: DESCID8
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +
> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> +    check(res)
> +
> +    res = env.c1.compound([op.destroy_clientid(c.clientid)])
> +    check(res, NFS4ERR_STALE_CLIENTID)
> -- 
> 1.7.6
> 
> 
