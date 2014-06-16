Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51676 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932066AbaFPWcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2014 18:32:43 -0400
Date: Mon, 16 Jun 2014 18:32:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3 v3] NFS4.0: Cases for SGID/SUID status after writing
Message-ID: <20140616223243.GC12458@fieldses.org>
References: <539AD76F.4000200@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <539AD76F.4000200@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2014 at 06:50:23PM +0800, Kinglong Mee wrote:
> v3, same as v2.
> v2, Adds Environment.c3. 

I'm testing with norootsquash on the latest upstream (which includes
your "NFSD: Don't clear SUID/SGID after root writing data") but still
see these failing.  Exports have no_root_squash set.  Is there something
else I'm missing?

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  nfs4.0/servertests/environment.py |  4 ++
>  nfs4.0/servertests/st_write.py    | 84 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 88 insertions(+)
> 
> diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
> index 9852178..48d4e26 100644
> --- a/nfs4.0/servertests/environment.py
> +++ b/nfs4.0/servertests/environment.py
> @@ -104,12 +104,16 @@ class Environment(testmod.Environment):
>          sec1, sec2 = self._get_security(opts)
>  #        authsys1 = rpc.SecAuthSys(0, opts.machinename, opts.uid, opts.gid, [])
>          authsys2 = rpc.SecAuthSys(0, opts.machinename, opts.uid+1, opts.gid+1, [])
> +        authsys3 = rpc.SecAuthSys(0, opts.machinename, opts.uid+2, opts.gid+2, [])
>          self.c1 = NFS4Client('client1_pid%i' % os.getpid(),
>                               opts.server, opts.port, opts.path,
>                               sec_list=[sec1], opts=opts)
>          self.c2 = NFS4Client('client2_pid%i' % os.getpid(),
>                               opts.server, opts.port, opts.path,
>                               sec_list=[authsys2], opts=opts)
> +        self.c3 = NFS4Client('client3_pid%i' % os.getpid(),
> +                             opts.server, opts.port, opts.path,
> +                             sec_list=[authsys3], opts=opts)
>          self.longname = "a"*512
>          self.uid = 0
>          self.gid = 0
> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
> index c76cf94..3e58cba 100644
> --- a/nfs4.0/servertests/st_write.py
> +++ b/nfs4.0/servertests/st_write.py
> @@ -457,3 +457,87 @@ def testMultipleReadWrites(t,env):
>          if resdata != expect:
>              t.fail("READ %d returned %s, expected %s" %
>                      (i+1, repr(resdata), repr(expect)))
> +
> +def doCheckMode(t, c, fh, mode):
> +    ops = c.use_obj(fh)
> +    ops += [c.getattr([FATTR4_MODE, FATTR4_OWNER, FATTR4_OWNER_GROUP])]
> +    res = c.compound(ops)
> +    check(res)
> +
> +    attrs = res.resarray[-1].obj_attributes
> +    if FATTR4_MODE not in attrs.keys():
> +         t.fail("Attributes not contains FATTR4_MODE")
> +    resmode = attrs[FATTR4_MODE]
> +    if resmode != mode:
> +         t.fail("Mode is %o, not expected %o" % (resmode, mode))
> +
> +def doCheckSGUID(t, env, cc, cw, cmode = 06777):
> +    c = env.c1
> +    path = c.homedir + [t.code]
> +    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
> +    check(res)
> +
> +    cc.init_connection()
> +    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 06777}
> +    path += [t.code]
> +    fh, stateid = cc.create_confirm(t.code, path, attrs=attrs,
> +                                   deny=OPEN4_SHARE_DENY_NONE)
> +    doCheckMode(t, cc, fh, 06777)
> +
> +    cw.init_connection()
> +    ops = cw.use_obj(fh)
> +    ops += [cw.write_op(stateid4(0, ''), 0, UNSTABLE4, 'for test')]
> +    res = cw.compound(ops)
> +    check(res)
> +
> +    doCheckMode(t, cw, fh, cmode)
> +
> +def testSGUIDRootRoot(t, env):
> +    """ root writing data to file (blongs to root)
> +        will not clear the SUID/SGID mode
> +
> +    FLAGS: wrtie file all
> +    DEPEND: MODE MKFILE
> +    CODE: WRT16a
> +    """
> +    doCheckSGUID(t, env, env.c1, env.c1)
> +
> +def testSGUIDRootNoRoot(t, env):
> +    """ root writing data to file (blongs to no-root)
> +        will not clear the SUID/SGID mode
> +
> +    FLAGS: wrtie file all
> +    DEPEND: MODE MKFILE
> +    CODE: WRT16b
> +    """
> +    doCheckSGUID(t, env, env.c2, env.c1)
> +
> +def testSGUIDNoRootSelf(t, env):
> +    """ no-root writing data to file (blongs to self)
> +        will clear the SUID/SGID mode
> +
> +    FLAGS: wrtie file all
> +    DEPEND: MODE MKFILE
> +    CODE: WRT16c
> +    """
> +    doCheckSGUID(t, env, env.c2, env.c2, 0777)
> +
> +def testSGUIDNoRootRoot(t, env):
> +    """ no-root writing data to file (blongs to root)
> +        will clear the SUID/SGID mode
> +
> +    FLAGS: wrtie file all
> +    DEPEND: MODE MKFILE
> +    CODE: WRT16d
> +    """
> +    doCheckSGUID(t, env, env.c1, env.c2, 0777)
> +
> +def testSGUIDNoRootNoRoot(t, env):
> +    """ no-root writing data to file (blongs to no-root)
> +        will clear the SUID/SGID mode
> +
> +    FLAGS: wrtie file all
> +    DEPEND: MODE MKFILE
> +    CODE: WRT16e
> +    """
> +    doCheckSGUID(t, env, env.c2, env.c3, 0777)
> -- 
> 1.9.3
> 
