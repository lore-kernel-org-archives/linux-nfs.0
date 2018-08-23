Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33676 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727079AbeHXAd7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 20:33:59 -0400
Date: Thu, 23 Aug 2018 17:02:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: jiyin@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: Re: [PATCH 19/24 v2] pynfs: python3 support plan: fix import fail on
 python3
Message-ID: <20180823210227.GA22443@parsley.fieldses.org>
References: <20180724103315.11618-1-jiyin@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180724103315.11618-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the patches, and apologies for the delay handling them.  I've
applied all 24 (including the v2 version of this patch), and pushed out
to my public git repo.

Does this complete the python3 work, or is there more to do?

--b.

On Tue, Jul 24, 2018 at 06:33:15PM +0800, jiyin@redhat.com wrote:
> From: "Jianhong.Yin" <yin-jianhong@163.com>
> 
> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> ---
>  nfs4.0/servertests/environment.py           | 2 +-
>  nfs4.0/servertests/st_access.py             | 2 +-
>  nfs4.0/servertests/st_acl.py                | 2 +-
>  nfs4.0/servertests/st_close.py              | 2 +-
>  nfs4.0/servertests/st_commit.py             | 2 +-
>  nfs4.0/servertests/st_compound.py           | 5 +++--
>  nfs4.0/servertests/st_create.py             | 2 +-
>  nfs4.0/servertests/st_delegation.py         | 2 +-
>  nfs4.0/servertests/st_fslocations.py        | 2 +-
>  nfs4.0/servertests/st_getattr.py            | 2 +-
>  nfs4.0/servertests/st_getfh.py              | 2 +-
>  nfs4.0/servertests/st_gss.py                | 4 ++--
>  nfs4.0/servertests/st_link.py               | 2 +-
>  nfs4.0/servertests/st_lock.py               | 2 +-
>  nfs4.0/servertests/st_lockt.py              | 2 +-
>  nfs4.0/servertests/st_locku.py              | 2 +-
>  nfs4.0/servertests/st_lookup.py             | 4 ++--
>  nfs4.0/servertests/st_lookupp.py            | 2 +-
>  nfs4.0/servertests/st_nverify.py            | 2 +-
>  nfs4.0/servertests/st_open.py               | 2 +-
>  nfs4.0/servertests/st_openconfirm.py        | 2 +-
>  nfs4.0/servertests/st_opendowngrade.py      | 2 +-
>  nfs4.0/servertests/st_putfh.py              | 2 +-
>  nfs4.0/servertests/st_putpubfh.py           | 2 +-
>  nfs4.0/servertests/st_putrootfh.py          | 2 +-
>  nfs4.0/servertests/st_read.py               | 4 ++--
>  nfs4.0/servertests/st_readdir.py            | 2 +-
>  nfs4.0/servertests/st_readlink.py           | 2 +-
>  nfs4.0/servertests/st_reboot.py             | 2 +-
>  nfs4.0/servertests/st_releaselockowner.py   | 2 +-
>  nfs4.0/servertests/st_remove.py             | 2 +-
>  nfs4.0/servertests/st_rename.py             | 2 +-
>  nfs4.0/servertests/st_renew.py              | 2 +-
>  nfs4.0/servertests/st_replay.py             | 2 +-
>  nfs4.0/servertests/st_restorefh.py          | 2 +-
>  nfs4.0/servertests/st_savefh.py             | 2 +-
>  nfs4.0/servertests/st_secinfo.py            | 2 +-
>  nfs4.0/servertests/st_setattr.py            | 2 +-
>  nfs4.0/servertests/st_setclientid.py        | 2 +-
>  nfs4.0/servertests/st_setclientidconfirm.py | 2 +-
>  nfs4.0/servertests/st_spoof.py              | 2 +-
>  nfs4.0/servertests/st_verify.py             | 2 +-
>  nfs4.0/servertests/st_write.py              | 4 ++--
>  nfs4.0/testserver.py                        | 2 +-
>  nfs4.1/client41tests/ct_reboot.py           | 2 +-
>  nfs4.1/client41tests/environment.py         | 2 +-
>  nfs4.1/dataserver.py                        | 2 +-
>  nfs4.1/nfs3client.py                        | 2 +-
>  nfs4.1/nfs4client.py                        | 2 +-
>  nfs4.1/nfs4lib.py                           | 2 +-
>  nfs4.1/nfs4proxy.py                         | 2 +-
>  nfs4.1/nfs4server.py                        | 2 +-
>  nfs4.1/nfs4state.py                         | 2 +-
>  nfs4.1/server41tests/environment.py         | 2 +-
>  nfs4.1/server41tests/st_block.py            | 2 +-
>  nfs4.1/server41tests/st_compound.py         | 2 +-
>  nfs4.1/server41tests/st_create_session.py   | 2 +-
>  nfs4.1/server41tests/st_current_stateid.py  | 4 ++--
>  nfs4.1/server41tests/st_debug.py            | 2 +-
>  nfs4.1/server41tests/st_delegation.py       | 2 +-
>  nfs4.1/server41tests/st_destroy_clientid.py | 2 +-
>  nfs4.1/server41tests/st_destroy_session.py  | 4 ++--
>  nfs4.1/server41tests/st_exchange_id.py      | 2 +-
>  nfs4.1/server41tests/st_flex.py             | 2 +-
>  nfs4.1/server41tests/st_getdevicelist.py    | 2 +-
>  nfs4.1/server41tests/st_lookup.py           | 4 ++--
>  nfs4.1/server41tests/st_lookupp.py          | 2 +-
>  nfs4.1/server41tests/st_open.py             | 4 ++--
>  nfs4.1/server41tests/st_putfh.py            | 2 +-
>  nfs4.1/server41tests/st_reboot.py           | 2 +-
>  nfs4.1/server41tests/st_reclaim_complete.py | 2 +-
>  nfs4.1/server41tests/st_rename.py           | 2 +-
>  nfs4.1/server41tests/st_secinfo.py          | 2 +-
>  nfs4.1/server41tests/st_secinfo_no_name.py  | 2 +-
>  nfs4.1/server41tests/st_sequence.py         | 2 +-
>  nfs4.1/server41tests/st_sparse.py           | 2 +-
>  nfs4.1/server41tests/st_trunking.py         | 2 +-
>  nfs4.1/server41tests/st_verify.py           | 2 +-
>  nfs4.1/testclient.py                        | 2 +-
>  nfs4.1/testserver.py                        | 2 +-
>  rpc/rpc.py                                  | 3 ++-
>  81 files changed, 92 insertions(+), 90 deletions(-)
> 
> diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
> index a5cfe60..4d85837 100644
> --- a/nfs4.0/servertests/environment.py
> +++ b/nfs4.0/servertests/environment.py
> @@ -14,7 +14,7 @@ from nfs4lib import NFS4Client, get_attrbitnum_dict
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import fsid4, nfsace4, fs_locations4, fs_location4, \
>       specdata4, nfstime4, settime4, stateid4
> -import rpc
> +import rpc.rpc as rpc
>  import sys
>  import os
>  import nfs_ops
> diff --git a/nfs4.0/servertests/st_access.py b/nfs4.0/servertests/st_access.py
> index 58c42bc..0a16986 100644
> --- a/nfs4.0/servertests/st_access.py
> +++ b/nfs4.0/servertests/st_access.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_acl.py b/nfs4.0/servertests/st_acl.py
> index 88667d2..3194ebc 100644
> --- a/nfs4.0/servertests/st_acl.py
> +++ b/nfs4.0/servertests/st_acl.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  from xdrdef.nfs4_type import nfsace4
>  from nfs4lib import list2bitmap
>  
> diff --git a/nfs4.0/servertests/st_close.py b/nfs4.0/servertests/st_close.py
> index 89ccbba..e0166f6 100644
> --- a/nfs4.0/servertests/st_close.py
> +++ b/nfs4.0/servertests/st_close.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, makeStaleId
> +from .environment import check, makeStaleId
>  
>  
>  def testCloseCreate(t, env):
> diff --git a/nfs4.0/servertests/st_commit.py b/nfs4.0/servertests/st_commit.py
> index eecf2c8..9345424 100644
> --- a/nfs4.0/servertests/st_commit.py
> +++ b/nfs4.0/servertests/st_commit.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  
>  _text = "Random data to write"
>  
> diff --git a/nfs4.0/servertests/st_compound.py b/nfs4.0/servertests/st_compound.py
> index 59a279d..5225f61 100644
> --- a/nfs4.0/servertests/st_compound.py
> +++ b/nfs4.0/servertests/st_compound.py
> @@ -1,8 +1,9 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import nfs_argop4
>  from xdrdef.nfs4_pack import NFS4Packer
> -from environment import check, get_invalid_utf8strings
> -from rpc import RPCError
> +from .environment import check, get_invalid_utf8strings
> +from rpc.rpc import RPCError
> +
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
> index c7256e5..a43003b 100644
> --- a/nfs4.0/servertests/st_create.py
> +++ b/nfs4.0/servertests/st_create.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import createtype4, specdata4
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
> index 937d95f..0247151 100644
> --- a/nfs4.0/servertests/st_delegation.py
> +++ b/nfs4.0/servertests/st_delegation.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import nfs_client_id4, clientaddr4, cb_client4
> -from environment import check
> +from .environment import check
>  import os
>  import threading
>  import time
> diff --git a/nfs4.0/servertests/st_fslocations.py b/nfs4.0/servertests/st_fslocations.py
> index 442d5a2..0387843 100644
> --- a/nfs4.0/servertests/st_fslocations.py
> +++ b/nfs4.0/servertests/st_fslocations.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from nfs4lib import list2bitmap
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
> index 65a5701..292fcd2 100644
> --- a/nfs4.0/servertests/st_getattr.py
> +++ b/nfs4.0/servertests/st_getattr.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  from nfs4lib import get_attr_name
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.0/servertests/st_getfh.py b/nfs4.0/servertests/st_getfh.py
> index 6fd22e7..4abe320 100644
> --- a/nfs4.0/servertests/st_getfh.py
> +++ b/nfs4.0/servertests/st_getfh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_gss.py b/nfs4.0/servertests/st_gss.py
> index 414883e..e10e849 100644
> --- a/nfs4.0/servertests/st_gss.py
> +++ b/nfs4.0/servertests/st_gss.py
> @@ -1,7 +1,7 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  from socket import timeout
> -import rpc
> +import rpc.rpc as rpc
>  import rpc.rpcsec.gss_const as gss
>  from rpc.rpcsec.gss_type import rpc_gss_cred_t
>  import nfs_ops
> diff --git a/nfs4.0/servertests/st_link.py b/nfs4.0/servertests/st_link.py
> index feddf1e..0ef5009 100644
> --- a/nfs4.0/servertests/st_link.py
> +++ b/nfs4.0/servertests/st_link.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> +from .environment import check, get_invalid_utf8strings
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_lock.py b/nfs4.0/servertests/st_lock.py
> index 060236a..b815a54 100644
> --- a/nfs4.0/servertests/st_lock.py
> +++ b/nfs4.0/servertests/st_lock.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import stateid4
> -from environment import check, get_invalid_clientid, makeStaleId, makeBadIDganesha
> +from .environment import check, get_invalid_clientid, makeStaleId, makeBadIDganesha
>  import time
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.0/servertests/st_lockt.py b/nfs4.0/servertests/st_lockt.py
> index 7f8c5e1..ee0b825 100644
> --- a/nfs4.0/servertests/st_lockt.py
> +++ b/nfs4.0/servertests/st_lockt.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_clientid
> +from .environment import check, get_invalid_clientid
>  
>  def testUnlockedFile(t, env):
>      """LOCKT on a regular unlocked file
> diff --git a/nfs4.0/servertests/st_locku.py b/nfs4.0/servertests/st_locku.py
> index 74b464a..3524a61 100644
> --- a/nfs4.0/servertests/st_locku.py
> +++ b/nfs4.0/servertests/st_locku.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import stateid4
> -from environment import check, makeStaleId
> +from .environment import check, makeStaleId
>  
>  def testFile(t, env):
>      """LOCKU a regular file
> diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
> index eed7100..9bfaffe 100644
> --- a/nfs4.0/servertests/st_lookup.py
> +++ b/nfs4.0/servertests/st_lookup.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> -import rpc
> +from .environment import check, get_invalid_utf8strings
> +import rpc.rpc as rpc
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_lookupp.py b/nfs4.0/servertests/st_lookupp.py
> index 13c1553..7c38600 100644
> --- a/nfs4.0/servertests/st_lookupp.py
> +++ b/nfs4.0/servertests/st_lookupp.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> +from .environment import check, get_invalid_utf8strings
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_nverify.py b/nfs4.0/servertests/st_nverify.py
> index 4185970..e2a8130 100644
> --- a/nfs4.0/servertests/st_nverify.py
> +++ b/nfs4.0/servertests/st_nverify.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_clientid, makeStaleId
> +from .environment import check, get_invalid_clientid, makeStaleId
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_open.py b/nfs4.0/servertests/st_open.py
> index b4af81c..9f5d1aa 100644
> --- a/nfs4.0/servertests/st_open.py
> +++ b/nfs4.0/servertests/st_open.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, checkdict, get_invalid_utf8strings
> +from .environment import check, checkdict, get_invalid_utf8strings
>  from nfs4lib import get_bitnumattr_dict
>  
>  # Any test that uses create_confirm should depend on this test
> diff --git a/nfs4.0/servertests/st_openconfirm.py b/nfs4.0/servertests/st_openconfirm.py
> index 3b5b98f..631855a 100644
> --- a/nfs4.0/servertests/st_openconfirm.py
> +++ b/nfs4.0/servertests/st_openconfirm.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import stateid4
> -from environment import check, makeStaleId
> +from .environment import check, makeStaleId
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_opendowngrade.py b/nfs4.0/servertests/st_opendowngrade.py
> index 213b2dd..2180223 100644
> --- a/nfs4.0/servertests/st_opendowngrade.py
> +++ b/nfs4.0/servertests/st_opendowngrade.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, makeStaleId
> +from .environment import check, makeStaleId
>  
>  def testRegularOpen(t, env):
>      """OPENDOWNGRADE on regular file
> diff --git a/nfs4.0/servertests/st_putfh.py b/nfs4.0/servertests/st_putfh.py
> index ba9ce27..6560f2e 100644
> --- a/nfs4.0/servertests/st_putfh.py
> +++ b/nfs4.0/servertests/st_putfh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_putpubfh.py b/nfs4.0/servertests/st_putpubfh.py
> index 0149b9d..1514fde 100644
> --- a/nfs4.0/servertests/st_putpubfh.py
> +++ b/nfs4.0/servertests/st_putpubfh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_putrootfh.py b/nfs4.0/servertests/st_putrootfh.py
> index dd47f58..b13c694 100644
> --- a/nfs4.0/servertests/st_putrootfh.py
> +++ b/nfs4.0/servertests/st_putrootfh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_read.py b/nfs4.0/servertests/st_read.py
> index 15f8795..1eb996c 100644
> --- a/nfs4.0/servertests/st_read.py
> +++ b/nfs4.0/servertests/st_read.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, makeBadID, makeBadIDganesha, makeStaleId
> -import rpc
> +from .environment import check, makeBadID, makeBadIDganesha, makeStaleId
> +import rpc.rpc as rpc
>  
>  def _compare(t, res, expect, eof=True):
>      def shorten(str):
> diff --git a/nfs4.0/servertests/st_readdir.py b/nfs4.0/servertests/st_readdir.py
> index 798b2d0..b9a8a4d 100644
> --- a/nfs4.0/servertests/st_readdir.py
> +++ b/nfs4.0/servertests/st_readdir.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from nfs4lib import get_attr_name
> -from environment import check
> +from .environment import check
>  
>  def _compare(t, entries, expect, attrlist=[]):
>      names = [e.name for e in entries]
> diff --git a/nfs4.0/servertests/st_readlink.py b/nfs4.0/servertests/st_readlink.py
> index 8b905d0..d8e3ea1 100644
> --- a/nfs4.0/servertests/st_readlink.py
> +++ b/nfs4.0/servertests/st_readlink.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_reboot.py b/nfs4.0/servertests/st_reboot.py
> index 16cb008..2a03e60 100644
> --- a/nfs4.0/servertests/st_reboot.py
> +++ b/nfs4.0/servertests/st_reboot.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import os
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.0/servertests/st_releaselockowner.py b/nfs4.0/servertests/st_releaselockowner.py
> index 17dfe1a..8021ddf 100644
> --- a/nfs4.0/servertests/st_releaselockowner.py
> +++ b/nfs4.0/servertests/st_releaselockowner.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import lock_owner4
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_remove.py b/nfs4.0/servertests/st_remove.py
> index 5f531f4..a9c397f 100644
> --- a/nfs4.0/servertests/st_remove.py
> +++ b/nfs4.0/servertests/st_remove.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> +from .environment import check, get_invalid_utf8strings
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
> index 8f41763..3a7fa1e 100644
> --- a/nfs4.0/servertests/st_rename.py
> +++ b/nfs4.0/servertests/st_rename.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> +from .environment import check, get_invalid_utf8strings
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_renew.py b/nfs4.0/servertests/st_renew.py
> index 3a9f774..679363c 100644
> --- a/nfs4.0/servertests/st_renew.py
> +++ b/nfs4.0/servertests/st_renew.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
> index 81b8332..3eba563 100644
> --- a/nfs4.0/servertests/st_replay.py
> +++ b/nfs4.0/servertests/st_replay.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  from xdrdef.nfs4_type import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.0/servertests/st_restorefh.py b/nfs4.0/servertests/st_restorefh.py
> index 839079f..e5db09a 100644
> --- a/nfs4.0/servertests/st_restorefh.py
> +++ b/nfs4.0/servertests/st_restorefh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_savefh.py b/nfs4.0/servertests/st_savefh.py
> index eef810c..c574718 100644
> --- a/nfs4.0/servertests/st_savefh.py
> +++ b/nfs4.0/servertests/st_savefh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_secinfo.py b/nfs4.0/servertests/st_secinfo.py
> index eb874b1..6c828bf 100644
> --- a/nfs4.0/servertests/st_secinfo.py
> +++ b/nfs4.0/servertests/st_secinfo.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> +from .environment import check, get_invalid_utf8strings
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
> index aa7123b..edf8caa 100644
> --- a/nfs4.0/servertests/st_setattr.py
> +++ b/nfs4.0/servertests/st_setattr.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_utf8strings
> +from .environment import check, get_invalid_utf8strings
>  from nfs4lib import bitmap2list, dict2fattr
>  from xdrdef.nfs4_type import nfstime4, settime4
>  import nfs_ops
> diff --git a/nfs4.0/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
> index 7f42d2d..6ad91f8 100644
> --- a/nfs4.0/servertests/st_setclientid.py
> +++ b/nfs4.0/servertests/st_setclientid.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import os
>  import struct, time
>  import nfs_ops
> diff --git a/nfs4.0/servertests/st_setclientidconfirm.py b/nfs4.0/servertests/st_setclientidconfirm.py
> index 51f7981..4ecf635 100644
> --- a/nfs4.0/servertests/st_setclientidconfirm.py
> +++ b/nfs4.0/servertests/st_setclientidconfirm.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  import os
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.0/servertests/st_spoof.py b/nfs4.0/servertests/st_spoof.py
> index 777985e..68778d4 100644
> --- a/nfs4.0/servertests/st_spoof.py
> +++ b/nfs4.0/servertests/st_spoof.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check
> +from .environment import check
>  
>  def testSpoofUser(t, env):
>      """SPOOF test, try to spoof user
> diff --git a/nfs4.0/servertests/st_verify.py b/nfs4.0/servertests/st_verify.py
> index 219d0a0..16d7c0c 100644
> --- a/nfs4.0/servertests/st_verify.py
> +++ b/nfs4.0/servertests/st_verify.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, get_invalid_clientid, makeStaleId
> +from .environment import check, get_invalid_clientid, makeStaleId
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
> index 5b48153..70ff49e 100644
> --- a/nfs4.0/servertests/st_write.py
> +++ b/nfs4.0/servertests/st_write.py
> @@ -1,8 +1,8 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
> -from environment import check, compareTimes, makeBadID, makeBadIDganesha, makeStaleId
> +from .environment import check, compareTimes, makeBadID, makeBadIDganesha, makeStaleId
>  import struct
> -import rpc
> +import rpc.rpc as rpc
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.0/testserver.py b/nfs4.0/testserver.py
> index 581dc3e..ebce58d 100755
> --- a/nfs4.0/testserver.py
> +++ b/nfs4.0/testserver.py
> @@ -40,7 +40,7 @@ import testmod
>  from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
>  import servertests.environment as environment
>  import socket
> -import rpc
> +import rpc.rpc as rpc
>  import pickle
>  
>  VERSION="0.2" # How/when update this?
> diff --git a/nfs4.1/client41tests/ct_reboot.py b/nfs4.1/client41tests/ct_reboot.py
> index 3bd241b..efbd74e 100644
> --- a/nfs4.1/client41tests/ct_reboot.py
> +++ b/nfs4.1/client41tests/ct_reboot.py
> @@ -1,5 +1,5 @@
>  import os
> -from environment import fail
> +from .environment import fail
>  
>  def testReboot(t, env):
>      """Test reboot
> diff --git a/nfs4.1/client41tests/environment.py b/nfs4.1/client41tests/environment.py
> index 933264c..09d07c2 100644
> --- a/nfs4.1/client41tests/environment.py
> +++ b/nfs4.1/client41tests/environment.py
> @@ -12,7 +12,7 @@ import time
>  import testmod
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
> -import rpc
> +import rpc.rpc as rpc
>  import nfs4client
>  import os
>  import nfs4lib
> diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
> index af0e35a..f76ca5a 100644
> --- a/nfs4.1/dataserver.py
> +++ b/nfs4.1/dataserver.py
> @@ -1,4 +1,4 @@
> -import rpc
> +import rpc.rpc as rpc
>  import nfs4lib
>  import xdrdef.nfs4_type as type4
>  from xdrdef.nfs4_pack import NFS4Packer
> diff --git a/nfs4.1/nfs3client.py b/nfs4.1/nfs3client.py
> index 176765c..f98f691 100644
> --- a/nfs4.1/nfs3client.py
> +++ b/nfs4.1/nfs3client.py
> @@ -1,5 +1,5 @@
>  import use_local # HACK so don't have to rebuild constantly
> -import rpc
> +import rpc.rpc as rpc
>  import nfs4lib
>  #from nfs4lib import NFS4Error, NFS4Replay, inc_u32
>  from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
> diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
> index 0588d7b..e8c649b 100644
> --- a/nfs4.1/nfs4client.py
> +++ b/nfs4.1/nfs4client.py
> @@ -1,5 +1,5 @@
>  import use_local # HACK so don't have to rebuild constantly
> -import rpc
> +import rpc.rpc as rpc
>  import nfs4lib
>  from nfs4lib import NFS4Error, NFS4Replay, inc_u32
>  from xdrdef.nfs4_type import *
> diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
> index 20eae0f..d46706a 100644
> --- a/nfs4.1/nfs4lib.py
> +++ b/nfs4.1/nfs4lib.py
> @@ -1,5 +1,5 @@
>  from __future__ import with_statement
> -import rpc
> +import rpc.rpc as rpc
>  import xdrdef.nfs4_const
>  from xdrdef.nfs4_pack import NFS4Packer, NFS4Unpacker
>  import xdrdef.nfs4_type
> diff --git a/nfs4.1/nfs4proxy.py b/nfs4.1/nfs4proxy.py
> index efb6744..dc8fdd4 100755
> --- a/nfs4.1/nfs4proxy.py
> +++ b/nfs4.1/nfs4proxy.py
> @@ -3,7 +3,7 @@ from __future__ import with_statement
>  import use_local # HACK so don't have to rebuild constantly
>  import nfs4lib
>  from nfs4lib import inc_u32, NFS4Error, NFS4Replay
> -import rpc
> +import rpc.rpc as rpc
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
>  from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
> diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
> index cd78082..767319d 100755
> --- a/nfs4.1/nfs4server.py
> +++ b/nfs4.1/nfs4server.py
> @@ -3,7 +3,7 @@ from __future__ import with_statement
>  import use_local # HACK so don't have to rebuild constantly
>  import nfs4lib
>  from nfs4lib import inc_u32, NFS4Error, NFS4Replay
> -import rpc
> +import rpc.rpc as rpc
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
>  from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
> diff --git a/nfs4.1/nfs4state.py b/nfs4.1/nfs4state.py
> index 95f84df..f2cad04 100644
> --- a/nfs4.1/nfs4state.py
> +++ b/nfs4.1/nfs4state.py
> @@ -9,7 +9,7 @@ from nfs4lib import NFS4Error
>  from xdrdef.nfs4_type import *
>  from xdrdef.nfs4_const import *
>  import nfs_ops
> -import rpc
> +import rpc.rpc as rpc
>  import logging
>  
>  log = logging.getLogger("nfs.server.state")
> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
> index 360089e..9e1201f 100644
> --- a/nfs4.1/server41tests/environment.py
> +++ b/nfs4.1/server41tests/environment.py
> @@ -12,7 +12,7 @@ import time
>  import testmod
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
> -import rpc
> +import rpc.rpc as rpc
>  import nfs4client
>  import sys
>  import os
> diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
> index 2041de3..3cfc1c6 100644
> --- a/nfs4.1/server41tests/st_block.py
> +++ b/nfs4.1/server41tests/st_block.py
> @@ -2,7 +2,7 @@ from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> -from environment import check, fail, create_file
> +from .environment import check, fail, create_file
>  from block import Packer as BlockPacker, Unpacker as BlockUnpacker, \
>      PNFS_BLOCK_READWRITE_DATA, pnfs_block_layoutupdate4, \
>      pnfs_block_extent4
> diff --git a/nfs4.1/server41tests/st_compound.py b/nfs4.1/server41tests/st_compound.py
> index 3915dd8..ded5465 100644
> --- a/nfs4.1/server41tests/st_compound.py
> +++ b/nfs4.1/server41tests/st_compound.py
> @@ -1,7 +1,7 @@
>  from xdrdef.nfs4_const import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> -from environment import check, fail, get_invalid_utf8strings
> +from .environment import check, fail, get_invalid_utf8strings
>  from xdrdef.nfs4_type import *
>  from rpc import RPCAcceptError, GARBAGE_ARGS, RPCTimeout
>  from nfs4lib import NFS4Error, hash_oids, encrypt_oids, FancyNFS4Packer
> diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
> index 5018ec6..a638990 100644
> --- a/nfs4.1/server41tests/st_create_session.py
> +++ b/nfs4.1/server41tests/st_create_session.py
> @@ -1,7 +1,7 @@
>  from xdrdef.nfs4_const import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> -from environment import check, fail, create_file, open_file
> +from .environment import check, fail, create_file, open_file
>  from xdrdef.nfs4_type import *
>  import random
>  import nfs4lib
> diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
> index 819dfb1..58f6e9b 100644
> --- a/nfs4.1/server41tests/st_current_stateid.py
> +++ b/nfs4.1/server41tests/st_current_stateid.py
> @@ -1,8 +1,8 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
>  
> -from environment import check, fail, create_file, open_file, close_file
> -from environment import open_create_file_op, use_obj
> +from .environment import check, fail, create_file, open_file, close_file
> +from .environment import open_create_file_op, use_obj
>  from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>  from xdrdef.nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
>  from xdrdef.nfs4_type import open_to_lock_owner4
> diff --git a/nfs4.1/server41tests/st_debug.py b/nfs4.1/server41tests/st_debug.py
> index 345fc77..3e3087d 100644
> --- a/nfs4.1/server41tests/st_debug.py
> +++ b/nfs4.1/server41tests/st_debug.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, create_file, close_file
> +from .environment import check, fail, create_file, close_file
>  from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
> index cbabb85..4f05bf1 100644
> --- a/nfs4.1/server41tests/st_delegation.py
> +++ b/nfs4.1/server41tests/st_delegation.py
> @@ -2,7 +2,7 @@ from st_create_session import create_session
>  from st_open import open_claim4
>  from xdrdef.nfs4_const import *
>  
> -from environment import check, fail, create_file, open_file, close_file
> +from .environment import check, fail, create_file, open_file, close_file
>  from xdrdef.nfs4_type import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.1/server41tests/st_destroy_clientid.py b/nfs4.1/server41tests/st_destroy_clientid.py
> index 25cc12a..50081b1 100644
> --- a/nfs4.1/server41tests/st_destroy_clientid.py
> +++ b/nfs4.1/server41tests/st_destroy_clientid.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail
> +from .environment import check, fail
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  import nfs4lib
> diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
> index c776617..c80c845 100644
> --- a/nfs4.1/server41tests/st_destroy_session.py
> +++ b/nfs4.1/server41tests/st_destroy_session.py
> @@ -1,11 +1,11 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, create_file, open_file
> +from .environment import check, fail, create_file, open_file
>  from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  import threading
> -import rpc
> +import rpc.rpc as rpc
>  
>  def testDestroy(t, env):
>      """
> diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
> index 9becec6..5a29634 100644
> --- a/nfs4.1/server41tests/st_exchange_id.py
> +++ b/nfs4.1/server41tests/st_exchange_id.py
> @@ -2,7 +2,7 @@ from xdrdef.nfs4_const import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  import time
> -from environment import check, fail
> +from .environment import check, fail
>  from xdrdef.nfs4_type import *
>  from rpc import RPCAcceptError, GARBAGE_ARGS, RPCTimeout
>  from nfs4lib import NFS4Error, hash_oids, encrypt_oids
> diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex.py
> index 35be489..335b2c8 100644
> --- a/nfs4.1/server41tests/st_flex.py
> +++ b/nfs4.1/server41tests/st_flex.py
> @@ -3,7 +3,7 @@ from xdrdef.nfs4_type import *
>  from xdrdef.nfs4_pack import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> -from environment import check, fail, create_file, close_file, open_create_file_op
> +from .environment import check, fail, create_file, close_file, open_create_file_op
>  from xdrdef.nfs4_pack import NFS4Packer as FlexPacker, \
>  	NFS4Unpacker as FlexUnpacker
>  from nfs4lib import FancyNFS4Packer, get_nfstime
> diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
> index edf5fe4..aff510e 100644
> --- a/nfs4.1/server41tests/st_getdevicelist.py
> +++ b/nfs4.1/server41tests/st_getdevicelist.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
> -from environment import check, fail, use_obj, open_file, create_file, get_blocksize
> +from .environment import check, fail, use_obj, open_file, create_file, get_blocksize
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  from block import Packer as BlockPacker, Unpacker as BlockUnpacker, \
> diff --git a/nfs4.1/server41tests/st_lookup.py b/nfs4.1/server41tests/st_lookup.py
> index 3899425..c46e7d2 100644
> --- a/nfs4.1/server41tests/st_lookup.py
> +++ b/nfs4.1/server41tests/st_lookup.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, fail
> +from .environment import check, fail
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> @@ -64,7 +64,7 @@ def testLongName(t, env):
>  
>  ##############################################################
>  if 0:
> -    from environment import check, get_invalid_utf8strings
> +    from .environment import check, get_invalid_utf8strings
>  
>      def testDir(t, env):
>          """LOOKUP testtree dir
> diff --git a/nfs4.1/server41tests/st_lookupp.py b/nfs4.1/server41tests/st_lookupp.py
> index 4c863a4..c91e39e 100644
> --- a/nfs4.1/server41tests/st_lookupp.py
> +++ b/nfs4.1/server41tests/st_lookupp.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, use_obj
> +from .environment import check, fail, use_obj
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> index 473732d..ceca656 100644
> --- a/nfs4.1/server41tests/st_open.py
> +++ b/nfs4.1/server41tests/st_open.py
> @@ -1,8 +1,8 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
>  
> -from environment import check, fail, create_file, open_file, close_file
> -from environment import open_create_file_op
> +from .environment import check, fail, create_file, open_file, close_file
> +from .environment import open_create_file_op
>  from xdrdef.nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>  from xdrdef.nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
>  from xdrdef.nfs4_type import open_to_lock_owner4
> diff --git a/nfs4.1/server41tests/st_putfh.py b/nfs4.1/server41tests/st_putfh.py
> index e1d6320..f8bfa71 100644
> --- a/nfs4.1/server41tests/st_putfh.py
> +++ b/nfs4.1/server41tests/st_putfh.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, use_obj, create_confirm, close_file
> +from .environment import check, fail, use_obj, create_confirm, close_file
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
> diff --git a/nfs4.1/server41tests/st_reboot.py b/nfs4.1/server41tests/st_reboot.py
> index b19c343..b852ded 100644
> --- a/nfs4.1/server41tests/st_reboot.py
> +++ b/nfs4.1/server41tests/st_reboot.py
> @@ -1,6 +1,6 @@
>  from xdrdef.nfs4_const import *
>  from xdrdef.nfs4_type import *
> -from environment import check, fail, create_file, open_file, create_confirm
> +from .environment import check, fail, create_file, open_file, create_confirm
>  import sys
>  import os
>  import nfs4lib
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index 642ada2..ee51843 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, open_file, create_file, create_confirm
> +from .environment import check, fail, open_file, create_file, create_confirm
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  import nfs4lib
> diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
> index c7c2c20..3042909 100644
> --- a/nfs4.1/server41tests/st_rename.py
> +++ b/nfs4.1/server41tests/st_rename.py
> @@ -1,5 +1,5 @@
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, maketree, rename_obj, get_invalid_utf8strings, create_obj, create_confirm, link, use_obj, create_file
> +from .environment import check, fail, maketree, rename_obj, get_invalid_utf8strings, create_obj, create_confirm, link, use_obj, create_file
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  from xdrdef.nfs4_type import *
> diff --git a/nfs4.1/server41tests/st_secinfo.py b/nfs4.1/server41tests/st_secinfo.py
> index 008dc1e..d7f9557 100644
> --- a/nfs4.1/server41tests/st_secinfo.py
> +++ b/nfs4.1/server41tests/st_secinfo.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, use_obj, bad_sessionid, create_file
> +from .environment import check, fail, use_obj, bad_sessionid, create_file
>  from xdrdef.nfs4_type import channel_attrs4
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.1/server41tests/st_secinfo_no_name.py b/nfs4.1/server41tests/st_secinfo_no_name.py
> index 9cd6bd3..a044940 100644
> --- a/nfs4.1/server41tests/st_secinfo_no_name.py
> +++ b/nfs4.1/server41tests/st_secinfo_no_name.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, bad_sessionid, create_file
> +from .environment import check, fail, bad_sessionid, create_file
>  from xdrdef.nfs4_type import channel_attrs4
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
> index 25e5113..208160f 100644
> --- a/nfs4.1/server41tests/st_sequence.py
> +++ b/nfs4.1/server41tests/st_sequence.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, bad_sessionid, create_file
> +from .environment import check, fail, bad_sessionid, create_file
>  from xdrdef.nfs4_type import channel_attrs4
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> diff --git a/nfs4.1/server41tests/st_sparse.py b/nfs4.1/server41tests/st_sparse.py
> index 6adf3d6..06be19e 100644
> --- a/nfs4.1/server41tests/st_sparse.py
> +++ b/nfs4.1/server41tests/st_sparse.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from xdrdef.nfs4_const import *
> -from environment import check, fail, create_file
> +from .environment import check, fail, create_file
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  import nfs4lib
> diff --git a/nfs4.1/server41tests/st_trunking.py b/nfs4.1/server41tests/st_trunking.py
> index 684423d..72afa1f 100644
> --- a/nfs4.1/server41tests/st_trunking.py
> +++ b/nfs4.1/server41tests/st_trunking.py
> @@ -1,7 +1,7 @@
>  from xdrdef.nfs4_const import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> -from environment import check, fail
> +from .environment import check, fail
>  from xdrdef.nfs4_type import *
>  import random
>  import nfs4lib
> diff --git a/nfs4.1/server41tests/st_verify.py b/nfs4.1/server41tests/st_verify.py
> index 7fb8a47..64d6156 100644
> --- a/nfs4.1/server41tests/st_verify.py
> +++ b/nfs4.1/server41tests/st_verify.py
> @@ -1,7 +1,7 @@
>  from xdrdef.nfs4_const import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> -from environment import check, get_invalid_clientid, makeStaleId, \
> +from .environment import check, get_invalid_clientid, makeStaleId, \
>      do_getattrdict, use_obj
>  
>  def _try_mand(t, env, path):
> diff --git a/nfs4.1/testclient.py b/nfs4.1/testclient.py
> index 3665253..5d21eaa 100755
> --- a/nfs4.1/testclient.py
> +++ b/nfs4.1/testclient.py
> @@ -33,7 +33,7 @@ import testmod
>  from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
>  import client41tests.environment as environment
>  import socket
> -import rpc
> +import rpc.rpc as rpc
>  import pickle
>  
>  def parse_useparams(str):
> diff --git a/nfs4.1/testserver.py b/nfs4.1/testserver.py
> index 7818a5d..2becc13 100755
> --- a/nfs4.1/testserver.py
> +++ b/nfs4.1/testserver.py
> @@ -37,7 +37,7 @@ import testmod
>  from optparse import OptionParser, OptionGroup, IndentedHelpFormatter
>  import server41tests.environment as environment
>  import socket
> -import rpc
> +import rpc.rpc as rpc
>  import pickle
>  
>  VERSION="0.2" # How/when update this?
> diff --git a/rpc/rpc.py b/rpc/rpc.py
> index af2b325..0c4a20a 100644
> --- a/rpc/rpc.py
> +++ b/rpc/rpc.py
> @@ -1,4 +1,5 @@
>  from __future__ import with_statement
> +from __future__ import absolute_import
>  
>  import socket, select
>  import struct
> @@ -7,7 +8,7 @@ import logging
>  from collections import deque as Deque
>  from errno import EINPROGRESS, EWOULDBLOCK
>  
> -import rpc_pack
> +import rpc.rpc_pack as rpc_pack
>  from rpc_const import *
>  from rpc_type import *
>  
> -- 
> 2.17.1
> 
