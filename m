Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:54452 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932595Ab3HGS2P convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 14:28:15 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>
Subject: Fwd: [PATCH 2/4] NFSv4.1 Use clientid management rpc_clnt for
 fs_locations
Date: Wed, 7 Aug 2013 18:28:13 +0000
Message-ID: <D95FC43A-2662-4922-8FF8-0FB063D781B0@netapp.com>
References: <F7CE9E5F-E136-4E5B-98CA-929DA93D1083@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Re-send due to my mailer adding html to the message, and thus being rejected by linux-nfs@vger.kernel.org

-->Andy

Begin forwarded message:

> From: "Adamson, Andy" <William.Adamson@netapp.com>
> Subject: Re: [PATCH 2/4] NFSv4.1 Use clientid management rpc_clnt for fs_locations
> Date: August 7, 2013 2:24:31 PM EDT
> To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> Cc: "Adamson, Andy" <William.Adamson@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> 
> 
> On Aug 7, 2013, at 2:19 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> wrote:
> 
>> On Wed, 2013-08-07 at 14:04 -0400, Trond Myklebust wrote:
>>> On Wed, 2013-08-07 at 18:01 +0000, Adamson, Andy wrote:
>>>> 
>>>> Here is the attack as described in 3530bis Security Considerations
>>>> section:
>>>> 
>>>> 
>>>>  The second operation that should definitely use integrity protection
>>>>  is any GETATTR for the fs_locations attribute.  The attack has two
>>>>  steps.  First the attacker modifies the unprotected results of some
>>>>  operation to return NFS4ERR_MOVED.  Second, when the client follows
>>>>  up with a GETATTR for the fs_locations attribute, the attacker
>>>>  modifies the results to cause the client migrate its traffic to a
>>>>  server controlled by the attacker.
>>> 
>>> You can the exact same thing by changing the READLINK results.
>> 
>> The attack is: change the unprotected LOOKUP results to point to a
>> symlink, then feed '/net/<evil-ip-address>/my/evil/pathname' into
>> READLINK.
>> 
>> My point is that if you're on a network where the above is a potential
>> threat, then you should be using krb5i or, better yet, krb5p for _all_
>> operations. It's not sufficient to single out fs_locations for special
>> treatment.
> 
> In that case, why did you accept commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible" ?
> 
> -->Andy
> 
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
> 

