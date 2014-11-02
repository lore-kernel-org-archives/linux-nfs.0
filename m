Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbaKBQob (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Nov 2014 11:44:31 -0500
Message-ID: <54565F6C.60204@RedHat.com>
Date: Sun, 02 Nov 2014 11:44:28 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: building upstream nfs-utils on EL6 fails
References: <E823B0AB-32D7-45C5-B5C2-69B165A2CEAC@oracle.com> <alpine.LRH.2.11.1410291919090.20279@sh-el6.eng.rdu2.redhat.com> <0953ACF5-C77F-4568-9952-FAF0C126B4AD@oracle.com> <alpine.LRH.2.11.1410301022140.20279@sh-el6.eng.rdu2.redhat.com> <88A2F169-8D62-4F15-BAAE-42732903DE46@oracle.com> <alpine.LRH.2.11.1410301152390.20279@sh-el6.eng.rdu2.redhat.com> <0CF508F8-8222-4555-A3E0-CDA435CF994D@oracle.com> <alpine.LRH.2.11.1410301229380.20279@sh-el6.eng.rdu2.redhat.com> <0ED5691C-39ED-4132-B6C9-5B6FB40D4CF1@oracle.com>
In-Reply-To: <0ED5691C-39ED-4132-B6C9-5B6FB40D4CF1@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/30/2014 01:19 PM, Chuck Lever wrote:
>> Yes, I agree.  It occurs to me that you can also call these through the
>> > syscall keyctl(), and pass the function number - so we can bypass a
>> > non-compatible libkeyutils with something like (the untested):
>> > 
>> > diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
>> > index e0d31e7..99ae07e 100644
>> > --- a/utils/nfsidmap/nfsidmap.c
>> > +++ b/utils/nfsidmap/nfsidmap.c
>> > @@ -209,10 +209,17 @@ static int key_invalidate(char *keystr, int keymask)
>> >                *(strchr(buf, ' ')) = '\0';
>> >                sscanf(buf, "%x", &key);
>> > 
>> > -               if (keyctl_invalidate(key) < 0) {
>> > -                       xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>> > -                       fclose(fp);
>> > -                       return 1;
>> > +/* older libkeyutils compatibility */
>> > +#ifndef KEYCTL_INVALIDATE
>> > +#define KEYCTL_INVALIDATE 21      /* invalidate a key */
>> > +#endif
>> > +               if (keyctl(KEYCTL_INVALIDATE, key) < 0 && errno == EOPNOTSUPP) {
>> > +                       /* older kernel compatibility attempt: */
>> > +                       if (keyctl_revoke(key) < 0) {
>> > +                               xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
>> > +                               fclose(fp);
>> > +                               return 1;
>> > +                       }
>> >                }
>> > 
>> >                keymask &= ~mask;
>> > 
>> > This should try to do the keyctl_invalidate if the kernel has it instead
>> > of relying on the stub in libkeyutils.
> I tested this with upstream 3.17, 2.6.39-400.209.1.el6uek.x86_64 (UEK2),
> and 2.6.32-504.el6.x86_64. I think this approach can work.
> 
> Upstream 3.17 worked as expected.
Can we add this to the upcoming RH bz.... 

> 
> UEK2 seems to use only the rpc.idmapd interface, no keys were created,
> and the test workload ran normally.
> 
> 2.6.32-504.el6.x86_64 almost worked. 
> 
> Oct 30 13:01:58 dali nfsidmap_new[2321]: key: 0x249ea9d9 type: uid value: cel@oracle.com timeout 600
> Oct 30 13:01:58 dali nfsidmap_new[2321]: nfs4_name_to_uid: calling nsswitch->name_to_uid
> Oct 30 13:01:58 dali nfsidmap_new[2321]: nss_getpwnam: name 'cel@oracle.com' domain 'oracle.com': resulting localname 'cel'
> Oct 30 13:01:58 dali nfsidmap_new[2321]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
> Oct 30 13:01:58 dali nfsidmap_new[2321]: nfs4_name_to_uid: final return value is 0
> Oct 30 13:01:58 dali nfsidmap_new[2323]: key: 0x2944b451 type: gid value: users@oracle.com timeout 600
> Oct 30 13:01:58 dali nfsidmap_new[2323]: nfs4_name_to_gid: calling nsswitch->name_to_gid
> Oct 30 13:01:58 dali nfsidmap_new[2323]: nfs4_name_to_gid: nsswitch->name_to_gid returned 0
> Oct 30 13:01:58 dali nfsidmap_new[2323]: nfs4_name_to_gid: final return value is 0
> 
> Golden. But nfsidmap_new was not able to set the key timeouts:
> 
> [root@dali ~]# cat /proc/keys
> 020d3315 I--Q--     3 perm 1f3f0000     0    -1 keyring   _uid.0: empty
> 0bf90e2d I--Q--     5 perm 1f3f0000     0     0 keyring   _ses: 1/4
> 1a94e9ce I--Q--     1 perm 1f3f0000     0    -1 keyring   _uid_ses.0: 1/4
> 1f77c0ad I--Q--     1 perm 3f050000     0     0 id_resolv gid:root@oracle.com: 2
> 249ea9d9 I--Q--     1 perm 3f050000     0     0 id_resolv uid:cel@oracle.com: 5
> 2944b451 I--Q--     1 perm 3f050000     0     0 id_resolv gid:users@oracle.com: 4
> 3641d485 I-----     1 perm 1f030000     0     0 keyring   .id_resolver: 4/4
> 3b10283e I--Q--     1 perm 3f050000     0     0 id_resolv uid:root@oracle.com: 2
> 
> I’m not sure if that’s normal for EL6 kernels, since I haven’t
> used one of the stock EL6 kernels in a while.
> 
> An unrelated problem: upstream nfs-utils still doesn’t build
> properly on EL6: nfsdcltrack can’t find the exact sqlite3 calls
> it needs, and the build bails (fortunately after building
> nfsidmap). More autoconf goo is needed to fix that.
Sounds like another RH bz to me... ;-)

steved.
