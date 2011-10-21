Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhost.anl.gov ([130.202.113.50]:39087 "EHLO mailhost.anl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099Ab1JUWFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Oct 2011 18:05:47 -0400
Message-ID: <4EA1E793.3060407@anl.gov>
Date: Fri, 21 Oct 2011 16:43:47 -0500
From: "Douglas E. Engert" <deengert@anl.gov>
MIME-Version: 1.0
To: Kevin Coffman <kwc@umich.edu>
CC: Arno Schuring <aelschuring@hotmail.com>, linux-nfs@vger.kernel.org
Subject: Re: sec=krb5 mounts never return
References: <20111021012327.612839b5@neminis.loos.site> <CAKnQG+d66Driv-D7fTeyh=MP4iNqpTzjXyFEiLE34E3YV2KG_g@mail.gmail.com> <20111021221001.71628099@neminis.intra.loos.site> <CAKnQG+d6V4sjY8i0-kLvUPGLgY+m8R3+yTqzdMaF3rsfWq2RYQ@mail.gmail.com>
In-Reply-To: <CAKnQG+d6V4sjY8i0-kLvUPGLgY+m8R3+yTqzdMaF3rsfWq2RYQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the enctype=4 and length= 8 that sounds like DES.
You may need to add to the krb5.conf file,

  allow_weak_crypto = yes


On 10/21/2011 3:58 PM, Kevin Coffman wrote:
> On Fri, Oct 21, 2011 at 4:10 PM, Arno Schuring<aelschuring@hotmail.com>  wrote:
>> Hi Kevin,
>>
>> thanks for your reply. Attached is all the information I have been able
>> to gather thus far (kernel and daemon logs).
>>
>> Kevin Coffman (kwc@umich.edu on 2011-10-21 10:33 -0400):
>>> On Thu, Oct 20, 2011 at 7:23 PM, Arno Schuring
>>> <aelschuring@hotmail.com>  wrote:
>>>>
>>>> I've been running a succesful NFS4 setup at home for a year now, but
>>>> incorporating krb5 security has so far proven fruitless. I believe
>>>> the Kerberos side of the equation is no longer causing problems; it
>>>> is used for user authentication too, and nfs security contexts seem
>>>> to work properly. As said above, the mount request for any Kerberos
>>>> mount gets halted somewhere in flight:
>> [..]
>>>> [600472.772226] nfsd: connect from 172.22.21.8, port=46257
>>>> [600472.772300] svc: svc_setup_socket created deda1a00 (inet
>>>> df948900) [600473.431966] svc_recv: found XPT_CLOSE
>>>> [600473.431982] svc: svc_delete_xprt(deda1a00)
>>>> [600473.432114] svc: transport deda1a00 is dead, not enqueued
>>>>
>>>
>>> You should be seeing syslog messages if not, but I'll ask anyway.
>>> You've got rpc.gssd configured and running on the client, and if this
>>> is a linux server, rpc.svcgssd configured and running on the server.
>>> ("Configured" more or less means you've got a keytab.)  If they are
>>> running, what does their output look like?  (Perhaps using "-vvv" to
>>> get detailed output.)
>>
>> In this case I'm trying with a local mount, so client==server. The gssd
>> logs invariably end with the following lines:
>> rpc.gssd[26133]: creating context with server nfs@genie.loos.site
>> rpc.gssd[28189]: DEBUG: serialize_krb5_ctx: lucid version!
>> rpc.gssd[28189]: prepare_krb5_rfc1964_buffer: serializing keys with
>> enctype 4 and length 8
>> rpc.gssd[28189]: doing downcall
>> [ then nothing until I kill the mount process ]
>>
>> In the svcgssd logs, nothing stands out to me. It all appears proper
>> to the untrained eye:
>>
>> rpc.svcgssd[26188]: handling null request
>> rpc.svcgssd[26188]: sname = nfs/genie.loos.site@LOOS.SITE
>> rpc.svcgssd[26188]: libnfsidmap: using (default) domain: loos.site
>> rpc.svcgssd[26188]: DEBUG: serialize_krb5_ctx: lucid version!
>> rpc.svcgssd[26188]: prepare_krb5_rfc1964_buffer: serializing keys with
>> enctype 4 and length 8
>> rpc.svcgssd[26188]: doing downcall
>> rpc.svcgssd[26188]: mech: krb5, hndl len: 4, ctx len 85, timeout:
>> 1319183270 (35999 from now), clnt: nfs@genie.loos.site, uid: -1, gid:
>> -1, num aux grps: 0:
>> rpc.svcgssd[26188]: sending null reply
>> rpc.svcgssd[26188]: finished handling null request
>>
>>
>> Regards,
>> Arno
>
> The userland/daemon stuff all looks fine to me.  I'm not as familiar
> with the kernel logs.  I believe the following kernel messages are
> from the ^C:
>
> Oct 20 23:48:18 genie kernel: [600500.662524] RPC:   437 return -512,
> status -512
> Oct 20 23:48:18 genie kernel: [600500.662539] RPC:   437 release task
> Oct 20 23:48:18 genie kernel: [600500.662558] RPC:       freeing
> buffer of size 3712 at d6915000
> Oct 20 23:48:18 genie kernel: [600500.662578] RPC:   437 release
> request d6911000
> Oct 20 23:48:18 genie kernel: [600500.662594] RPC:
> wake_up_next(c3966234 "xprt_backlog")
> Oct 20 23:48:18 genie kernel: [600500.662613] RPC:   437 releasing
> RPCSEC_GSS cred df1f9300
> Oct 20 23:48:18 genie kernel: [600500.662631] RPC:
> rpc_release_client(de639e00)
> Oct 20 23:48:18 genie kernel: [600500.662648] RPC:   437 freeing task
> Oct 20 23:48:18 genie kernel: [600500.662664] nfs4_get_root: getroot error = 512
>
> I don't see anything obviously wrong.
>
> K.C.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

-- 

  Douglas E. Engert  <DEEngert@anl.gov>
  Argonne National Laboratory
  9700 South Cass Avenue
  Argonne, Illinois  60439
  (630) 252-5444
