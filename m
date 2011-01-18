Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51972 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050Ab1ARW7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 17:59:19 -0500
Date: Tue, 18 Jan 2011 17:59:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: Fred Isaman <iisaman@netapp.com>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd4: implement secinfo_no_name
Message-ID: <20110118225913.GG10903@fieldses.org>
References: <4D183265.70608@cn.fujitsu.com>
 <20101229185609.GA12218@fieldses.org>
 <4D1C06E7.5060009@cn.fujitsu.com>
 <20110105010507.GC14744@fieldses.org>
 <AANLkTimHAzLWE2ZC+QGtSw3ff6fpQsejDV8M7x8m34dp@mail.gmail.com>
 <20110105153713.GA13000@fieldses.org>
 <20110105172916.GD13000@fieldses.org>
 <4D253CDA.30605@cn.fujitsu.com>
 <20110111233229.GE28537@fieldses.org>
 <4D2E6F70.2090501@cn.fujitsu.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4D2E6F70.2090501@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 13, 2011 at 11:20:16AM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields 写道:
> > Could I ask for a few changes?:
> > 	- The second half of testSupported2 should go into a separate
> > 	  test in a separate st_secinfo file.  (It will be a very small
> > 	  file for now!  But we can port some of the 4.0 tests to it
> > 	  some day.)
> > 	- That test should create a file in the same way that e.g. the
> > 	  st_open tests do instead of assuming a file named "/tree"
> > 	  exists.
> 
>   Is the following one OK?

Yes, applied.

Thanks again for the pynfs help, getting these new features tested is
important.

--b.

> 
> thanks,
> Mi Jinlong
> 
> >From 480d5d5272dd6d3c7bd15adafd62a4a9d2431db2 Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Sun, 2 Jan 2011 17:59:20 +0800
> Subject: [PATCH] CLNT: Add some simple secinfo_no_name and secinfo tests
> 
> Add two simple secinfo_no_name tests as Bruce said:
>   - send PUTROOTFH+SECINFO_NO_NAME, check that you get back a
>     legal result.
>   - send PUTROOTFH+SECINFO+GETFH, and/or
>     PUTROOTFH+SECINFO_NO_NAME+GETFH, check that the GETFH returns
>     NOFILEHANDLE.
> 
> also add two simple secinfo tests case.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/__init__.py           |    2 +
>  nfs4.1/server41tests/st_secinfo.py         |   57 ++++++++++++++++++++++++++++
>  nfs4.1/server41tests/st_secinfo_no_name.py |   35 +++++++++++++++++
>  3 files changed, 94 insertions(+), 0 deletions(-)
>  create mode 100644 nfs4.1/server41tests/st_secinfo.py
>  create mode 100644 nfs4.1/server41tests/st_secinfo_no_name.py
> 
> diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
> index 22cd664..3b4411a 100644
> --- a/nfs4.1/server41tests/__init__.py
> +++ b/nfs4.1/server41tests/__init__.py
> @@ -2,6 +2,8 @@ __all__ = ["st_exchange_id.py", # draft 21
>             "st_compound.py",
>             "st_create_session.py",
>             "st_destroy_session.py",
> +           "st_secinfo_no_name.py",
> +           "st_secinfo.py",
>             "st_sequence.py",
>  	   "st_trunking.py",
>             "st_open.py",
> diff --git a/nfs4.1/server41tests/st_secinfo.py b/nfs4.1/server41tests/st_secinfo.py
> new file mode 100644
> index 0000000..c0e5b71
> --- /dev/null
> +++ b/nfs4.1/server41tests/st_secinfo.py
> @@ -0,0 +1,57 @@
> +from st_create_session import create_session
> +from nfs4_const import *
> +from environment import check, fail, use_obj, bad_sessionid, create_file
> +from nfs4_type import channel_attrs4
> +import nfs4_ops as op
> +import nfs4lib
> +
> +def testSupported(t, env):
> +    """Do a simple SECINFO
> +
> +    FLAGS: all
> +    CODE: SEC1
> +    """
> +    name = env.testname(t)
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    # Create a tmpfile for testing
> +    owner = "owner_%s" % name
> +    path = sess.c.homedir + [name]
> +    res = create_file(sess, owner, path, access=OPEN4_SHARE_ACCESS_WRITE)
> +    check(res)
> +
> +    # Get the filehandle of the tmpfile's parent dir
> +    res = sess.compound(use_obj(sess.c.homedir) + [op.getfh()])
> +    check(res)
> +    fh = res.resarray[-1].object
> +
> +    # Just do a simple SECINFO
> +    res = sess.compound([op.putfh(fh), op.secinfo(name)])
> +    check(res)
> +
> +def testSupported2(t, env):
> +    """GETFH after do a SECINFO_NO_NAME or SECINFO
> +       result in a NOFILEHANDLE error, See rfc 5661 section 2.6.3.1.1.8
> +
> +    FLAGS: all
> +    CODE: SEC2
> +    """
> +    name = env.testname(t)
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    # Create a tmpfile for testing
> +    owner = "owner_%s" % name
> +    path = sess.c.homedir + [name]
> +    res = create_file(sess, owner, path, access=OPEN4_SHARE_ACCESS_WRITE)
> +    check(res)
> +
> +    # Get the filehandle of the tmpfile's parent dir
> +    res = sess.compound(use_obj(sess.c.homedir) + [op.getfh()])
> +    check(res)
> +    fh = res.resarray[-1].object
> +
> +    # GETFH after do a SECINFO should get error NFS4ERR_NOFILEHANDLE
> +    res = sess.compound([op.putfh(fh), op.secinfo(name), op.getfh()])
> +    check(res, NFS4ERR_NOFILEHANDLE)
> diff --git a/nfs4.1/server41tests/st_secinfo_no_name.py b/nfs4.1/server41tests/st_secinfo_no_name.py
> new file mode 100644
> index 0000000..14bc410
> --- /dev/null
> +++ b/nfs4.1/server41tests/st_secinfo_no_name.py
> @@ -0,0 +1,35 @@
> +from st_create_session import create_session
> +from nfs4_const import *
> +from environment import check, fail, bad_sessionid, create_file
> +from nfs4_type import channel_attrs4
> +import nfs4_ops as op
> +import nfs4lib
> +
> +def testSupported(t, env):
> +    """Do a simple SECINFO_NO_NAME
> +       send PUTROOTFH+SECINFO_NO_NAME, check is result legal
> +
> +    FLAGS: all
> +    CODE: SECNN1
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    # Do a simple SECINFO_NO_NAME
> +    res = sess.compound([op.putrootfh(), op.secinfo_no_name(0)])
> +    check(res)
> +
> +def testSupported2(t, env):
> +    """GETFH after do a SECINFO_NO_NAME or SECINFO
> +       result in a NOFILEHANDLE error, See rfc 5661 section 2.6.3.1.1.8
> +
> +    FLAGS: all
> +    CODE: SECNN2
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    sess = c.create_session()
> +
> +    # GETFH after do a SECINFO_NO_NAME should get error NFS4ERR_NOFILEHANDLE
> +    res = sess.compound([op.putrootfh(), op.secinfo_no_name(0), op.getfh()])
> +    print res
> +    check(res, NFS4ERR_NOFILEHANDLE)
> -- 
> 1.7.3.4
> 
> 
> 
