Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:20725 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932194Ab3HGSYd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 14:24:33 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] NFSv4.1 Use clientid management rpc_clnt for
 fs_locations
Date: Wed, 7 Aug 2013 18:24:31 +0000
Message-ID: <F7CE9E5F-E136-4E5B-98CA-929DA93D1083@netapp.com>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
 <1374511328-49579-2-git-send-email-andros@netapp.com>
 <1375894458.7280.2.camel@leira.trondhjem.org>
 <479EB531-9CD2-42E2-AB98-A3CD9B13603D@netapp.com>
 <1375898644.7280.10.camel@leira.trondhjem.org>
 <1375899556.7280.16.camel@leira.trondhjem.org>
In-Reply-To: <1375899556.7280.16.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 7, 2013, at 2:19 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Wed, 2013-08-07 at 14:04 -0400, Trond Myklebust wrote:
>> On Wed, 2013-08-07 at 18:01 +0000, Adamson, Andy wrote:
>>> 
>>> Here is the attack as described in 3530bis Security Considerations
>>> section:
>>> 
>>> 
>>>   The second operation that should definitely use integrity protection
>>>   is any GETATTR for the fs_locations attribute.  The attack has two
>>>   steps.  First the attacker modifies the unprotected results of some
>>>   operation to return NFS4ERR_MOVED.  Second, when the client follows
>>>   up with a GETATTR for the fs_locations attribute, the attacker
>>>   modifies the results to cause the client migrate its traffic to a
>>>   server controlled by the attacker.
>> 
>> You can the exact same thing by changing the READLINK results.
> 
> The attack is: change the unprotected LOOKUP results to point to a
> symlink, then feed '/net/<evil-ip-address>/my/evil/pathname' into
> READLINK.
> 
> My point is that if you're on a network where the above is a potential
> threat, then you should be using krb5i or, better yet, krb5p for _all_
> operations. It's not sufficient to single out fs_locations for special
> treatment.

In that case, why did you accept commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible" ?

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

