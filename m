Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:20651 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab3JQNO0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 09:14:26 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: Different sequence of "exportfs" produce different effects on nfs client mounts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
Date: Thu, 17 Oct 2013 09:14:02 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <CB4DB7B1-5EEA-47D0-9CAD-CC69AF868182@oracle.com>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com> <20131014174540.GA27747@fieldses.org> <3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com> <20131015154918.GA6117@fieldses.org> <3962238FD7EA0F41B1810E7ABEAFBC314CEF9FD9@szxema505-mbs.china.huawei.com> <3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
To: Wangminlan <wangminlan@huawei.com>, Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

281         if (ident[0] == '\0')
282                 return MCL_ANONYMOUS;
283         if (ident[0] == '@') {
284 #ifndef HAVE_INNETGR
285                 xlog(L_WARNING, "netgroup support not compiled in");
286 #endif
287                 return MCL_NETGROUP;
288         }
289         for (sp = ident; *sp; sp++) {
290                 if (*sp == '*' || *sp == '?' || *sp == '[')
291                         return MCL_WILDCARD;
292                 if (*sp == '/')
293                         return MCL_SUBNETWORK;
294                 if (*sp == '\\' && sp[1])
295                         sp++;
296         }

is still in play today.  The "host_pton()" code you posted was added by commit 502edf1d just after this paragraph.  But here is what that commit replaced.

-       /* check for N.N.N.N */
-       sp = ident;
-       if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
-       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_F
-       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_F
-       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '\0') return MCL_
-       /* we lie here a bit. but technically N.N.N.N == N.N.N.N/32 :) */
-       return MCL_SUBNETWORK;
+
+       /*
+        * Treat unadorned IP addresses as MCL_SUBNETWORK.
+        * Everything else is MCL_FQDN.
+        */
+       ai = host_pton(ident);
+       if (ai != NULL) {
+               freeaddrinfo(ai);
+               return MCL_SUBNETWORK;
+       }
+
+       return MCL_FQDN;
 }

The replaced logic also treats IP addresses as MCL_SUBNETWORK.  That's from commit 54669c98 in 2005.  Neil, do you remember why this semantic change was made?



On Oct 17, 2013, at 3:16 AM, Wangminlan <wangminlan@huawei.com> wrote:

> Hi, 
> 	I went through the code of nfs-utils, check the function client_gettype in support/export/client.c:
> in nfs-utils-1-2-9-rc6, and in nfs-utils-1.2.6, they have this implementation in the final part:
> 770         /*
> 771          * Treat unadorned IP addresses as MCL_SUBNETWORK.
> 772          * Everything else is MCL_FQDN.
> 773          */
> 774         ai = host_pton(ident);
> 775         if (ai != NULL) {
> 776                 freeaddrinfo(ai);
> 777                 return MCL_SUBNETWORK;
> 778         }
> 779 
> 780         return MCL_FQDN;
> 781 }
> 
> while back in days of nfs-utils-1.0.7: client_gettype looks like this:
> 277 client_gettype(char *ident)
> 278 {
> 279         char    *sp;
> 280 
> 281         if (ident[0] == '\0')
> 282                 return MCL_ANONYMOUS;
> 283         if (ident[0] == '@') {
> 284 #ifndef HAVE_INNETGR
> 285                 xlog(L_WARNING, "netgroup support not compiled in");
> 286 #endif
> 287                 return MCL_NETGROUP;
> 288         }
> 289         for (sp = ident; *sp; sp++) {
> 290                 if (*sp == '*' || *sp == '?' || *sp == '[')
> 291                         return MCL_WILDCARD;
> 292                 if (*sp == '/')
> 293                         return MCL_SUBNETWORK;
> 294                 if (*sp == '\\' && sp[1])
> 295                         sp++;
> 296         }
> 297         return MCL_FQDN;
> 298 }
> 
> It's simple, and client like "192.168.0.21" is treated as MCL_FQDN. 
> I tried the same operation in this version, there's no such problem as in nfs-utils-1.2.1 and nfs-utils-1.2.6.
> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org
>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Wangminlan
>> Sent: Wednesday, October 16, 2013 9:23 AM
>> To: J. Bruce Fields
>> Cc: linux-nfs@vger.kernel.org
>> Subject: RE: Different sequence of "exportfs" produce different effects on nfs
>> client mounts
>> 
>> Hi, Bruce,
>> 	The nfs-utils on my box is nfs-utils-1.2.1-2.6.6, which is Suse distributed.
>> 	I tried the same experiment on fedora18, which use nfs-utils-1.2.6, and
>> got the same result.
>> 	I go through the code of support/export/client.c, found that in
>> client_get_type(), when the client is specified as an IP address(which can not
>> be resolved as an FQDN), it actually return the result: MCL_SUBNETWORK.
>> 	I guess that's the reason that the client "192.168.0.21" and
>> "192.168.0.0/16" both are sorted to the same category: MCL_SUBNETWORK,
>> so the order of exports matters here.
>> 	Is this what exportfs and mountd mean to be?
>> B.R
>> Minlan Wang
>> 
>> On Tuesday, October 15, 2013 at 03:49AM +0000, Bruce Fields wrote:
>>> Looking at the mountd code....
>>> 
>>> Looks like utils/mountd/cache.c makes no special effort to prioritize
>>> exports except in the v4root and crossmnt cases, neither an issue in
>>> your case.
>>> 
>>> So yes it depends on ordering. From man exports:
>>> 
>>> 	 If a client matches more than one of the specifications above,
>>> 	 then the first match from the above list order takes precedence
>>> 	 - regardless  of the  order they appear on the export line.
>>> 	 However, if a client matches more than one of the same type of
>>> 	 specification (e.g.  two  netgroups), then  the  first  match
>>> 	 from  the order they appear on the export line takes
>>> 	 precedence.
>>> 
>>> The order given is: single host, IP networks, wildcards, negroups,
>>> anonymous.
>>> 
>>> So the single host exports should have taken precedence.
>>> 
>>> The code here does look like it corectly implements the above ordering.
>>> 
>>> What version of nfs-utils are you using?
>>> 
>>> --b.
>>> 
>>> On Tue, Oct 15, 2013 at 06:39:59AM +0000, Wangminlan wrote:
>>>> On Mon, Oct 14, 2013 at 16:46 +0000, Bruce Fields wrote:
>>>>> On Mon, Oct 14, 2013 at 02:16:58AM +0000, Wangminlan wrote:
>>>>>> 　　Hi,
>>>>>> 　　         I’ve got a problem on the nfs exportfs command. I’m
>>> not
>>>>> sure if this is the right place to ask this, if not, can you please tell me
>>> where?
>>>>>> 
>>>>>> 　　         Here’s what I need:
>>>>>> 　　1. I have a folder named /mnt/fs1 to be exported.
>>>>>> 　　2. All the host in subnetwork 192.168.0.0/16 should be able access
>>> this
>>>>> folder, but their root should be squashed.
>>>>>> 　　3. Some specified host in the same subnetwork can gain the root
>>>>> permission on the folder, for example: 192.168.0.21, 192.168.0.22.
>>>>>> 
>>>>>> 　　I’ve got a SLES11SP1 box as the nfs server, the nfs clients are
>>> SLES11SP1,
>>>>> too, and the protocol used between clients and server are NFSv3.
>>>>>> 　　Here are the commands I used to do the export:
>>>>>> 　　#exportfs –o rw,root_squash 192.168.0.0/16:/mnt/fs1
>>>>>> 　　#exportfs –o rw,no_root_squash 192.168.0.21:/mnt/fs1
>>>>>> 　　#exportfs –o rw,no_root_squash 192.168.0.22:/mnt/fs1
>>>>>> 　　After this, everything works as expected.
>>>> After this, the contents of /proc/net/rpc/auth.unix.ip/content and
>>> /proc/net/rpc/nfsd.export/content are:
>>>> 	NV200_01:/proc/net/rpc # cat auth.unix.ip/content
>>>> 	#class IP domain
>>>> 	nfsd 192.168.0.21 192.168.0.0/16,192.168.0.21
>>>> 	nfsd 0.0.0.0 -test-client-
>>>> 	# nfsd 100.43.189.1 -no-domain-
>>>> 
>>>> 	NV200_01:/proc/net/rpc # cat nfsd.export/content
>>>> 	#path domain(flags)
>>>> 	/mnt/fs1
>>> 	-test-client-(rw,no_root_squash,sync,no_wdelay,fsid=0,anonuid=4294967
>>> 295,anongid=4294967295)
>>>> 	/mnt/fs1
>>> 	192.168.0.0/16,192.168.0.21(rw,no_root_squash,sync,wdelay,no_subtree
>>> _check,uuid=13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
>>>> 	# /mnt/fs1
>>> 	192.168.0.0/16,192.168.0.21(rw,no_root_squash,sync,wdelay,no_subtree
>>> _check,uuid=13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
>>>> Besides, the content of /var/lib/nfs/etab is:
>>>> 	NV200_01:/proc/net/rpc # cat /var/lib/nfs/etab
>>>> 	/mnt/fs1
>>> 	192.168.0.22(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
>>> 
>> _all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=6553
>>> 4)
>>>> 	/mnt/fs1
>>> 	192.168.0.21(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
>>> 
>> _all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=6553
>>> 4)
>>>> 	/mnt/fs1
>>> 	192.168.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_
>>> 
>> all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534
>>> )
>>>>>> 
>>>>>> 　　But, after the following operations:
>>>>>> 　　#exportfs –u 192.168.0.0/16:/mnt/fs1              /* Delete
>>> this
>>>>> export */
>>>>>> 　　# exportfs –o rw,root_squash 192.168.0.0/16:/mnt/fs1
>>> /*
>>>>> And add it again */
>>>>>> 　　Hosts on 192.168.0.21 and 192.168.0.22 doesn’t get root
>>> permission
>>>>> any more. when I tried to write a file, it complains about “Permission
>>> denied”.
>>>>>> 
>>>>>> 　　So, does the order of exportfs command has something to do the
>>> final
>>>>> result? Or am I doing something wrong?
>>>> After this, the contents of /proc/net/rpc/auth.unix.ip/content and
>>> /proc/net/rpc/nfsd.export/content are:
>>>> 	NV200_01:/proc/net/rpc # cat auth.unix.ip/content
>>>> 	#class IP domain
>>>> 	nfsd 192.168.0.21 192.168.0.0/16,192.168.0.21
>>>> 	nfsd 0.0.0.0 -test-client-
>>>> 	# nfsd 100.43.189.1 -no-domain-
>>>> 
>>>> 	NV200_01:/proc/net/rpc # cat nfsd
>>>> 	nfsd         nfsd.export/ nfsd.fh/
>>>> 	NV200_01:/proc/net/rpc # cat nfsd
>>>> 	nfsd         nfsd.export/ nfsd.fh/
>>>> 	NV200_01:/proc/net/rpc # cat nfsd.export/content
>>>> 	#path domain(flags)
>>>> 	/mnt/fs1
>>> 	-test-client-(rw,no_root_squash,sync,no_wdelay,fsid=0,anonuid=4294967
>>> 295,anongid=4294967295)
>>>> 	/mnt/fs1
>>> 	192.168.0.0/16,192.168.0.21(rw,root_squash,sync,wdelay,no_subtree_ch
>>> eck,uuid=13266f0d:1fbd40d5:b0b5c4fe:cfe104eb)
>>>> And the content of /var/lib/nfs/etab is:
>>>> 	NV200_01:/proc/net/rpc # cat /var/lib/nfs/etab
>>>> 	/mnt/fs1
>>> 	192.168.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_
>>> 
>> all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534
>>> )
>>>> 	/mnt/fs1
>>> 	192.168.0.22(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
>>> 
>> _all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=6553
>>> 4)
>>>> 	/mnt/fs1
>>> 	192.168.0.21(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no
>>> 
>> _all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=6553
>>> 4)
>>>>> 
>>>>> That sounds like a bug.  The contents of
>>>>> /proc/net/rpc/auth.unix.ip/content and
>> /proc/net/rpc/nfsd.export/content
>>>>> after getting the above "permission denied" might be interesting.
>> ��칻�&�~�&���+-��ݶ��w��˛���m�b��g~ȧ���ܨ}���Ơz�&j:+v���
>> 
> ����zZ+��+zf���h���~����i���z��w���?����&�)ߢf
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




