Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbbIKKpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 06:45:22 -0400
Date: Fri, 11 Sep 2015 11:45:17 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: nfsd leaks 3 sunrpc module references
Message-ID: <20150911104517.GA4947@stefanha-thinkpad.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm having a little trouble debugging this sunrpc module refcnt leak in
nfsd.  Perhaps a fresh pair of eyes can help.

nfsd leaks 3 references to the sunrpc module here:

  # echo -n "asdf 1234" >/proc/fs/nfsd/portlist
  bash: echo: write error: Protocol not supported

Now stop nfsd and try unloading the kernel modules:

  # systemctl stop nfs-server
  # systemctl stop nfs
  # systemctl stop proc-fs-nfsd.mount
  # systemctl stop var-lib-nfs-rpc_pipefs.mount
  # rmmod nfsd
  # rmmod nfs_acl
  # rmmod lockd
  # rmmod auth_rpcgss
  # rmmod sunrpc
  rmmod: ERROR: Module sunrpc is in use
  # lsmod | grep rpc
  sunrpc                315392  3

I have reproduced this from source with a tree based on Linux 4.2-rc3
and also with Linux 4.1.6-200.fc22.x86_64.

The following unmatched module_get() calls are recorded by perf record
-e module:module_get -e module:module_put.  Perhaps the backtrace is a
little mangled because I don't see xdr_reserve_space() calls in
svc_create_pooled() (even indirectly):

nfsd  4291 [002]    87.914752: module:module_get: sunrpc call_site=0xffffffffa031c86as refcnt=7
                  318d93 try_module_get (vmlinux)
                    98da xs_tcp_setup_socket ([sunrpc])
                    5ca5 xprt_create_transport ([sunrpc])
                    34ad rpc_create ([sunrpc])
                   1892a rpcb_getport_async ([sunrpc])
                   196ea xdr_reserve_space ([sunrpc])
                   128dc svc_create_pooled ([sunrpc])
                     686 nfsd_create_serv ([nfsd])
                    1be9 write_ports ([nfsd])
                    182c nfsctl_transaction_write ([nfsd])
                  410d87 __vfs_write (vmlinux)
                  411706 vfs_write (vmlinux)
                  4123f5 sys_write (vmlinux)
                  95ed95 tracesys_phase2 (vmlinux)
                   f2ff0 __GI___libc_write (/usr/lib64/libc-2.21.so)

nfsd  4291 [002]    87.914775: module:module_get: sunrpc call_site=0xffffffffa03228a5s refcnt=8
                  318d93 try_module_get (vmlinux)
                    f915 rpcauth_cache_do_shrink ([sunrpc])
                    2bbd rpc_new_client ([sunrpc])
                    337a rpc_create_xprt ([sunrpc])
                    34d6 rpc_create ([sunrpc])
                   1892a rpcb_getport_async ([sunrpc])
                   196ea xdr_reserve_space ([sunrpc])
                   128dc svc_create_pooled ([sunrpc])
                     686 nfsd_create_serv ([nfsd])
                    1be9 write_ports ([nfsd])
                    182c nfsctl_transaction_write ([nfsd])
                  410d87 __vfs_write (vmlinux)
                  411706 vfs_write (vmlinux)
                  4123f5 sys_write (vmlinux)
                  95ed95 tracesys_phase2 (vmlinux)
                   f2ff0 __GI___libc_write (/usr/lib64/libc-2.21.so)

nfsd  4291 [002]    87.914936: module:module_get: sunrpc call_site=0xffffffffa03228a5s refcnt=9
                  318d93 try_module_get (vmlinux)
                    f915 rpcauth_cache_do_shrink ([sunrpc])
                    2bbd rpc_new_client ([sunrpc])
                    2ead __rpc_clone_client ([sunrpc])
                    35e7 rpc_bind_new_program ([sunrpc])
                   18949 rpcb_getport_async ([sunrpc])
                   196ea xdr_reserve_space ([sunrpc])
                   128dc svc_create_pooled ([sunrpc])
                     686 nfsd_create_serv ([nfsd])
                    1be9 write_ports ([nfsd])
                    182c nfsctl_transaction_write ([nfsd])
                  410d87 __vfs_write (vmlinux)
                  411706 vfs_write (vmlinux)
                  4123f5 sys_write (vmlinux)
                  95ed95 tracesys_phase2 (vmlinux)
                   f2ff0 __GI___libc_write (/usr/lib64/libc-2.21.so)

In this trace I modified nfs-utils nfsd to write to portlist but you get
the same result with echo from a shell (as shown above).

Any ideas?

Stefan
