From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Massive NFS problems on large cluster with large number of mounts
Date: Fri, 15 Aug 2008 16:34:03 -0400
Message-ID: <76bd70e30808151334i19822280j67a08b92b17582ba@mail.gmail.com>
References: <20080701182250.GB21807@fieldses.org> <487DC43F.8040408@aei.mpg.de>
	 <20080716190658.GF20298@fieldses.org>
	 <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com>
	 <20080717144852.GA11759@fieldses.org>
	 <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com>
	 <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com>
	 <20080730175308.GH12364@fieldses.org>
	 <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f@mail.gmail.com>
	 <76bd70e30807301501p5c0ba3c6i38fee02a1e606e31@mail.gmail.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Carsten Aulbert" <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	"Henning Fehrmann" <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	"Steffen Grunewald" <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:44040 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbYHOUeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2008 16:34:05 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1453716mue.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2008 13:34:03 -0700 (PDT)
In-Reply-To: <76bd70e30807301501p5c0ba3c6i38fee02a1e606e31-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 30, 2008 at 6:01 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> On Wed, Jul 30, 2008 at 3:33 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> On Wed, Jul 30, 2008 at 1:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> On Mon, Jul 28, 2008 at 04:55:50PM -0400, Chuck Lever wrote:
>>>> On Thu, Jul 17, 2008 at 11:11 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> > On Thu, Jul 17, 2008 at 10:48 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> >> On Thu, Jul 17, 2008 at 10:47:25AM -0400, Chuck Lever wrote:
>>>> >>> On Wed, Jul 16, 2008 at 3:06 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> >>> > The immediate problem seems like a kernel bug to me--it seems to me that
>>>> >>> > the calls to local daemons should be ignoring {min_,max}_resvport.  (Or
>>>> >>> > is there some way the daemons can still know that those calls come from
>>>> >>> > the local kernel?)
>>>> >>>
>>>> >>> I tend to agree.  The rpcbind client (at least) does specifically
>>>> >>> require a privileged port, so a large min/max port range would be out
>>>> >>> of the question for those rpc_clients.
>>>> >>
>>>> >> Any chance I could talk you into doing a patch for that?
>>>> >
>>>> > I can look at it when I get back next week.
>>>>
>>>> I've been pondering this.
>>>>
>>>> It seems like the NFS client is a rather unique case for using
>>>> unprivileged ports; most or all of the other RPC clients in the kernel
>>>> want to use privileged ports pretty much all the time, and have
>>>> learned to switch this off as needed and appropriate.  We even have an
>>>> internal API feature for doing this: the RPC_CLNT_CREATE_NONPRIVPORT
>>>> flag to rpc_create().
>>>>
>>>> And instead of allowing a wide source port range, it would be better
>>>> for the NFS client to use either privileged ports, or unprivileged
>>>> ports, but not both, for the same mount point.  Otherwise we could be
>>>> opening ourselves up for non-deterministic behavior: "How come
>>>> sometimes I get EPERM when I try to mount my NFS servers, but other
>>>> times the same mount command works fine?" or "Sometimes after a long
>>>> idle period my NFS mount points stop working, and all the programs
>>>> running on the mount point get EACCES."
>>>>
>>>> It seems like a good solution would be to:
>>>>
>>>> 1.  Make the xprt_minresvport and xprt_maxresvport sysctls mean what
>>>> they say: they are _reserved_ port limits.  Thus xprt_maxresvport
>>>> should never be allowed to be larger than 1023, and xprt_minresvport
>>>> should always be made to be strictly less than xprt_maxresvport; and
>>>
>>> That would break existing setups: so, someone googles for "nfs linux
>>> large numbers of mounts" and comes across:
>>>
>>>        http://marc.info/?l=linux-nfs&m=121509091004851&w=2
>>>
>>> They add
>>>
>>>        echo 2000 >/proc/sys/sunrpc/max_resvport
>>>
>>> to their initscripts, and their problem goes away.  A year later, with
>>> this incident long forgotten, they upgrade their kernel, start getting
>>> failed mounts, and in the worst case end up debugging the whole problem
>>> from scratch again.
>>
>>>> 2.  Introduce a mechanism to specifically enable the NFS client to use
>>>> non-privileged ports.  It could be a new mount option like "insecure"
>>>> (which is what some other O/Ses use) or "unpriv-source-port" for
>>>> example.  I tend to dislike the former because such a feature is
>>>> likely to be quite useful with Kerberos-authenticated NFS, and
>>>> "sec=krb5,insecure" is probably a little funny looking, but
>>>> "sec=krb5,unpriv-source-port" makes it pretty clear what is going on.
>>>
>>> But I can see the argument for the mount option.
>>>
>>> Maybe we could leave the meaning of the sysctls alone, and allowing
>>> noresvport as an alternate way to allow use of nonreserved ports?
>>>
>>> In any case, this all seems a bit orthogonal to the problem of what
>>> ports the rpcbind client uses, right?
>>
>> No, this is exactly the original problem.  The reason xprt_maxresvport
>> is allowed to go larger than 1023 is to permit more NFS mounts.  There
>> really is no other reason for it I can think of.
>>
>> But it's broken (or at least inconsistent) behavior that max_resvport
>> can go past 1023 in the first place.  The name is "max_resvport" --
>> Maximum Reserved Port.  A port value of more than 1024 is not a
>> reserved port.  These sysctls are designed to restrict the range of
>> ports used when a _reserved_ port is requested, not when _any_ source
>> port is requested.  Trond's suggestion is an "off label" use of this
>> facility.
>>
>> And rpcbind isn't the only kernel-level RPC service that requires a
>> reserved port.  The kernel-level NSM code that calls user space, for
>> example, is one such service.  In other words, rpcbind isn't the only
>> service that could potentially hit this issue, so an rpcbind-only fix
>> would be incomplete.
>>
>> We already have an appropriate interface for kernel RPC services to
>> request a non-privileged port.  The NFS client should use that
>> interface.
>>
>> Now, we don't have to change both at the same time.  We can introduce
>> the mount option now; the default reserved port range is still good.
>> And eventually folks using the sysctl will hit the rpcbind bug (or a
>> lock recovery problem), trace it back to this issue, and change their
>> mount options and reset their resvport sysctls.
>
> Unfortunately we are out of NFS_MOUNT_ flags: there are already 16
> defined and this is a legacy kernel ABI, so I'm not sure if we are
> allowed to use the upper 16 bits in the flags word.
>
> Will think about this more.

We had some discussion about this at the pub last night.

Trond, NFS_MOUNT_FLAGMASK is used in nfs_init_server() and
nfs4_init_server() for both legacy binary and text-based mounts.  This
needs to be moved to a legacy-only path if we want to use the
high-order 16 bits in the 'flags' field for text-based mounts.

I reviewed the Solaris mount_nfs(1M) man page (I hope this is the
correct place to look).  There doesn't appear to be a mount option to
make Solaris NFS clients use a reserved port. Not sure if there's some
other UI (like a config file in /etc).

FreeBSD and Mac OS both use "[no]resvport" as Mike pointed out
earlier.  That's my vote for the new Linux mount option.

[ Sidebar: I found this in the Mac OS mount_nfs(8) man page:

     noconn  Do not connect UDP sockets.  For UDP mount points, do not do a
             connect(2).  This must be used for servers that do not reply to
             requests from the standard NFS port number 2049.  It may also be
             required for servers with more than one IP address if replies come
             from an address other than the one specified in the requests.

An interesting consideration if we support connected UDP sockets for
NFS at some point. ]

-- 
"Officer. Ma'am. Squeaker."
  -- Mr. Incredible
