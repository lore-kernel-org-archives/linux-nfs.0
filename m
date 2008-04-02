From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: RE: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Wed, 2 Apr 2008 12:28:35 -0700
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C59D3A6C@exchange.ZeugmaSystems.local>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local> <20080401210627.GD21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3777@exchange.ZeugmaSystems.local> <20080401221327.GH21343@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "J. Bruce Fields" <bfields@fieldses.org>,
	<linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:18180 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756376AbYDBT3L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2008 15:29:11 -0400
In-Reply-To: <20080401221327.GH21343@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



>-----Original Message-----
>From: J. Bruce Fields [mailto:bfields@fieldses.org]
>Sent: Tuesday, April 01, 2008 3:13 PM
>
>> >which is called from fs/nfsd/nfssvc.c:nfsd_svc() as:
>> >
>> >	error = nfsd_racache_init(2*nrservs);
>> >
>> >where nrservs is the number of server threads.  How many server
>threads
>> >are you
>> >trying to start, and how much memory do you have?
>>
>>
>> Yea, I have seen that codebase. The configuration file
/etc/init.d/nfs
>creates 8 nfs threads:
>>
>> root:Zeugma:/etc/init.d# ps -A |grep nfs
>>  2202 ?        00:00:00 nfsd
>>  2203 ?        00:00:00 nfsd
>>  2204 ?        00:00:00 nfsd
>>  2205 ?        00:00:00 nfsd
>>  2206 ?        00:00:00 nfsd
>>  2207 ?        00:00:00 nfsd
>>  2208 ?        00:00:00 nfsd
>>  2209 ?        00:00:00 nfsd
>> root:Zeugma:/etc/init.d# free
>>              total       used       free     shared    buffers
>cached
>> Mem:        255372      34352     221020          0       2564
>18720
>> -/+ buffers/cache:      13068     242304
>> Swap:            0          0          0
>>
>>
>> The funny thing is that the moment I enable nfsd filesystem, the
>problem
>> seems to go away.
>
>OK, so write_svc() (hence sys_nfsservctl()) is getting garbage.  Hm.


Yea, indeed. So I did some digging with printks and found that the
#server threads are indeed not getting correctly passed on to the
kernel. This I attributed, as you have suggested, to some memory
corruption.



>The structure that's passed in to the kernel is:
>
>	struct nfsctl_svc {
>		unsigned short svc_port;
>		int svc_nthreads;
>	};
>
>Is it at all possible that userspace and the kernel could disagree
about
>the layout of that structure?


I looked at the userspace definition of nfsctl_arg in
support/include/nfs/nfs.h:

struct nfsctl_arg {
        int                     ca_version;     /* safeguard */
        union {
                struct nfsctl_svc       u_svc;
                struct nfsctl_client    u_client;
                struct nfsctl_export    u_export;
                struct nfsctl_uidmap    u_umap;
                struct nfsctl_fhparm    u_getfh;
                struct nfsctl_fdparm    u_getfd;
                struct nfsctl_fsparm    u_getfs;
                void *u_ptr;
        } u;
#define ca_svc          u.u_svc
#define ca_client       u.u_client
#define ca_export       u.u_export
#define ca_umap         u.u_umap
#define ca_getfh        u.u_getfh
#define ca_getfd        u.u_getfd
#define ca_getfs        u.u_getfs
#define ca_authd        u.u_authd
};

As you can see, we have an extra u_ptr member in the union (which is the
same as in the kernel: include/linux/nfsd/syscall.h).

For experiment, I removed this member, recompiled nfs-utils and wala!
The kernel now gets the correct value of the server thread #.

I am a bit puzzled by this since u_umap member already has a char* and I
think adding a void* does not change the alignment of the union. In the
kernel, its presence is important since it does not have a u_umap member
in its nfsctl_arg declaration:

struct nfsctl_arg {
        int                     ca_version;     /* safeguard */
        union {
                struct nfsctl_svc       u_svc;
                struct nfsctl_client    u_client;
                struct nfsctl_export    u_export;
                struct nfsctl_fdparm    u_getfd;
                struct nfsctl_fsparm    u_getfs;
                /*
                 * The following dummy member is needed to preserve
binary compatibility
                 * on platforms where alignof(void*)>alignof(int).  It's
needed because
                 * this union used to contain a member (u_umap) which
contained a
                 * pointer.
                 */
                void *u_ptr;
        } u;
#define ca_svc          u.u_svc
#define ca_client       u.u_client
#define ca_export       u.u_export
#define ca_getfd        u.u_getfd
#define ca_getfs        u.u_getfs
};

Ani


