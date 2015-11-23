Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361AbbKWTtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2015 14:49:05 -0500
Date: Mon, 23 Nov 2015 14:49:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4.0 tests: discover max supported file size
Message-ID: <20151123194902.GE12032@fieldses.org>
References: <1448267222-20720-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1448267222-20720-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2015 at 09:27:02AM +0100, Tigran Mkrtchyan wrote:
> current implementation amuses, that all servers
> support 64-bit file sizes. This is not always true.
> Use FATTR4_MAXFILESIZE attribute to discover supported
> maximum. Update LOCK6 test to use it.

The language at http://tools.ietf.org/html/rfc7530#section-16.10.4 isn't
as clear as it could be, but I think INVAL at least is unambiguously
wrong in the case you're testing (it should be BAD_RANGE or OK).

My interpretation is actually that we should return:

	- INVAL for 64-bit overflow, otherwise
	- BAD_RANGE for 32-bit overflow on 32-bit server, otherwise
	- OK for ranges that extend past FATTR4_MAXFILESIZE.  (You're
	  allowed to lock ranges not in the file.)

So I prefer the test as-is, but might be open to argument about whether
this is the most important case to be testing.

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.0/nfs4lib.py             | 6 ++++++
>  nfs4.0/servertests/st_lock.py | 3 ++-
>  2 files changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/nfs4.0/nfs4lib.py b/nfs4.0/nfs4lib.py
> index 5031feb..41870dc 100644
> --- a/nfs4.0/nfs4lib.py
> +++ b/nfs4.0/nfs4lib.py
> @@ -587,6 +587,12 @@ class NFS4Client(rpc.RPCClient, nfs4_ops.NFS4Operations):
>          d = self.do_getattrdict([], [FATTR4_LEASE_TIME])
>          return d[FATTR4_LEASE_TIME]
>  
> +    def getMaxFileSize(self):
> +        """Get maximum supported file size"""
> +        d = self.do_getattrdict([], [FATTR4_MAXFILESIZE])
> +        return d[FATTR4_MAXFILESIZE]
> +
> +
>      def create_obj(self, path, type=NF4DIR, attrs={FATTR4_MODE:0755},
>                     linkdata="/etc/X11"):
>          if __builtins__['type'](path) is str:
> diff --git a/nfs4.0/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
> index d54614d..80518f4 100644
> --- a/nfs4.0/servertests/st_lock.py
> +++ b/nfs4.0/servertests/st_lock.py
> @@ -189,8 +189,9 @@ def testLenTooLong(t, env):
>      """
>      c = env.c1
>      c.init_connection()
> +    max_size = c.getMaxFileSize();
>      fh, stateid = c.create_confirm(t.code)
> -    res = c.lock_file(t.code, fh, stateid, 100, 0xfffffffffffffffe)
> +    res = c.lock_file(t.code, fh, stateid, 100, max_size)
>      check(res, NFS4ERR_INVAL, "LOCK with offset+len overflow")
>  
>  def testNoFh(t, env):
> -- 
> 2.5.0
