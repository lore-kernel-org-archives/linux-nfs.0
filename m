Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56929 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932248AbeBTAJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 19:09:36 -0500
From: NeilBrown <neilb@suse.com>
To: kernel test robot <fengguang.wu@intel.com>
Date: Tue, 20 Feb 2018 11:09:25 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, lkp@01.org
Subject: Re: [SUNRPC]  e22c8d3cf4: BUG:KASAN:use-after-free_in_r
In-Reply-To: <20180219163912.25h6tn5l2gwcx5nv@inn>
References: <20180219163912.25h6tn5l2gwcx5nv@inn>
Message-ID: <87371wldxm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Feb 20 2018, kernel test robot wrote:

> FYI, we noticed the following commit (built with gcc-7):
>
> commit: e22c8d3cf4cd6307228c9946a670fa548c359611 ("SUNRPC: add side channel to use non-generic cred for rpc call.")
> url: https://github.com/0day-ci/linux/commits/NeilBrown/Remove-generic-rpc-credentials-and-associated-changed-V3/20180219-190836
> base: git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
>
> in testcase: boot
>
> on test machine: qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 1G
>
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
>
>
> +-------------------------------+------------+------------+
> |                               | a79c51c9c3 | e22c8d3cf4 |
> +-------------------------------+------------+------------+
> | boot_successes                | 6          | 4          |
> | boot_failures                 | 0          | 4          |
> | BUG:KASAN:use-after-free_in_r | 0          | 4          |
> +-------------------------------+------------+------------+
>
>
>
> [   66.551598] BUG: KASAN: use-after-free in rpc_free_task+0x5e/0x86
> [   66.552963] Read of size 8 at addr ffff8800093e93a8 by task kworker/0:3/201

Thanks.
The patch had

        rpc_release_calldata(task->tk_ops, task->tk_calldata);
+       put_rpccred(task->tk_op_cred);

It should have had

+       put_rpccred(task->tk_op_cred);
        rpc_release_calldata(task->tk_ops, task->tk_calldata);

as the rpc_release_calldata might free the task.

I'll send a revised patch.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqLZzUACgkQOeye3VZi
gbnqzg/7Bz+fdQ073WHhoF4Jl4eRhcu8M/pzj/UDBpdnZtqoEA82V7AxLI1joOBa
CNvgFfgv9IUmbiGjtOZJcEBW3npD/YD+PLiLc1GgdiShx66NyZBvwVvsEDQ8LPQ3
qkDFwr9fjviMe+5ZgjELeD7d2y1WWHBltfzjjt0PM0Xms3oM6CAN0h34gVuMGMuj
e0itLAgOAlo7LpnbNY8ZpuqVIrZVrXcfQ85D1Z03Bpkp8QKUwKS8lsPVMguipRLf
2cIbuIX+ELTX0R1TF5fHuF9rhQjODypQBw7zG7D9yu9HFjVsQgVEzW4uPvnAHX8x
lGepewTH+gwvt942kIlJFxycmYOJ3seeXuL+6wg1A3PJeY8hTtED55C+q9gO5pbS
N4RYYnoFPDLgS7XA/wEkAPctpcSyxjOy3I2olVHVkMJt/500J/0hPkMncfv0YtSv
h9foNm+Qqo3byeyJ4Ld5C1ofJ1nCX3RtNQBuIrpYWbliv7hc6HeTwYE07YOXuEZ7
3aphzhdWlYIYwXQxfIMRw6YDZgtpQFiUnOxf4rGNvPnTW2fOJF9vmrZbyDLmzaik
JsQzdOoIObTp4n/4/uDDIB+5/KSWSaaW/9+nWEP+C6ENZlN2DLhmS9/HhOmrQ3pA
7h3H9cbYdCCe753ODzaq5y9skU+Ue+678LR7DyjdBwA5C++bOfk=
=AqDy
-----END PGP SIGNATURE-----
--=-=-=--
