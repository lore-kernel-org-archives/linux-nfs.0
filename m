Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:48535 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862Ab3AaAey convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 19:34:54 -0500
References: <20130130231546.47786.6016.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA91834404D@sacexcmbx05-prd.hq.netapp.com> <5FCBEC10-44F0-4CD8-BB97-2C49FA768373@oracle.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <5FCBEC10-44F0-4CD8-BB97-2C49FA768373@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <87AF875A-A0A1-4A07-8CDF-DD40A61466A9@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 0/9] Dynamically load GSS pseudoflavors by OID
Date: Wed, 30 Jan 2013 19:34:40 -0500
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Sent from my iPhone

On Jan 30, 2013, at 7:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 30, 2013, at 6:51 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>>> Sent: Wednesday, January 30, 2013 6:42 PM
>>> To: linux-nfs@vger.kernel.org
>>> Subject: [PATCH v2 0/9] Dynamically load GSS pseudoflavors by OID
>>> 
>>> Hi-
>>> 
>>> Currently the RPC client is able to dynamically load GSS security flavor
>>> support by name or pseudoflavor number, but not by [OID, qop, service]
>>> tuple.  Such a tuple can be provided by an NFSv4 server in a SECINFO reply,
>>> for example.
>>> 
>>> This means that if an NFSv4 server lists a tuple for, say, krb5p, in a SECINFO
>>> reply, our client will pretend it doesn't support krb5p if the rpc-auth-gss-krb5
>>> module is available on the system but does not happen to be loaded at that
>>> moment.
>>> 
>>> This series implements support for loading the correct GSS pseudoflavor
>>> module before searching by GSS tuple.  This version needs testing, which I'll
>>> get to first thing tomorrow, but I've already tested earlier versions of these
>>> patches with success.
>>> 
>>> Thanks to reviewers of v1.  Changes since v1:
>>> 
>>> 1.  Simplify function and method names
>>> 2.  Add an equivalent server-side interface
>>> 3.  Improve automatic loading of the auth_rpcgss module
>>> 4.  nfs_find_best_sec() also verifies non-GSS flavors against
>>>     RPC client's list of registered flavors
>>> 5.  Search for (qop, svc) pair without adding a new function
>>> 6.  Clean up GSS mech switch
>>> 7.  Remove dprintk() calls
>>> 8.  Improve patch descriptions
>>> 9.  Numerous small improvements and fixes
>>> 
>>> ---
>>> 
>>> Chuck Lever (9):
>>>     SUNRPC: Remove EXPORT_SYMBOL_GPL() from GSS mech switch
>>>     SUNRPC: Make gss_mech_get() static
>>>     SUNRPC: Refactor nfsd4_do_encode_secinfo()
>>>     SUNRPC: Consider qop when looking up pseudoflavors
>>>     SUNRPC: Load GSS kernel module by OID
>>>     SUNRPC: Introduce rpcauth_get_pseudoflavor()
>>>     SUNRPC: Define rpcsec_gss_info structure
>>>     NFS: Remove unneeded forward declaration
>>>     SUNRPC: Missing module alias for auth_rpcgss.ko
>>> 
>>> 
>>> fs/nfs/nfs4namespace.c                |   43 +++++++-----
>>> fs/nfs/nfs4xdr.c                      |   20 +++---
>>> fs/nfsd/nfs4xdr.c                     |   43 ++++++------
>>> include/linux/nfs_xdr.h               |   24 +------
>>> include/linux/sunrpc/auth.h           |    6 ++
>>> include/linux/sunrpc/gss_api.h        |   29 ++++++--
>>> net/sunrpc/Kconfig                    |    1
>>> net/sunrpc/auth.c                     |   68 +++++++++++++++++++
>>> net/sunrpc/auth_gss/auth_gss.c        |    3 +
>>> net/sunrpc/auth_gss/gss_krb5_mech.c   |    6 +-
>>> net/sunrpc/auth_gss/gss_mech_switch.c |  117
>>> +++++++++++++++++++++++++--------
>>> net/sunrpc/auth_gss/svcauth_gss.c |    4 +
>>> 12 files changed, 257 insertions(+), 107 deletions(-)
>> 
>> Looks good! How have you tested it?
> 
> Start with a Solaris 11 NFS server and my client.  The server has a Kerberos-only share called /test/krb5-only.
> 
>  1.  "sudo rmmod auth_rpcgss" on the client (no NFS mounts at this point)
> 
>  2.  "sudo mount server:/ /mnt"
> 
>  3.  The client accesses the pseudo-fs with AUTH_UNIX (observed with wireshark)
> 
>  4.  After I kinit on the client, I cd into /test/krb5-only
> 
>  5.  The client encounters the WRONG_SEC and performs a SECINFO request (observed with wireshark)
> 
>  6.  The correct kernel modules are loaded, and the cd completes successfully.

Note if I blacklist the Kerberos module or neglect to kinit, the krb5-only directory is unreadable, as expected.

> 
>  7.  I "cd ~" and unmount /mnt.  The module refcounts go to zero.
> 
> I've run this with debugging enabled and extra dprintk's, and it looks like the client is doing all the right things.
> 
> I'd like to extend the testing a bit with a Linux NFS server, now that there's a server-side change in this series.  And naturally I'll need broad compile-testing with various combinations of CONFIG options.  I'm open to suggestions of other use cases / corner cases.
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
