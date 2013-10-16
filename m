Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:11692 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525Ab3JPWHh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 18:07:37 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Add support for multiple sec= mount options
Date: Wed, 16 Oct 2013 22:07:36 +0000
Message-ID: <46CDF537-DB80-458B-B8AC-7141C09E03AB@netapp.com>
References: <1381517062-11267-1-git-send-email-dros@netapp.com>
 <1381955772.17178.33.camel@leira.trondhjem.org>
In-Reply-To: <1381955772.17178.33.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


-dros

On Oct 16, 2013, at 4:36 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-10-11 at 14:44 -0400, Weston Andros Adamson wrote:
>> This patch adds support for multiple security options which can be
>> specified using a colon-delimited list of security flavors (the same
>> syntax as nfsd's exports file).
>> 
>> This is useful, for instance, when NFSv4.x mounts cross SECINFO
>> boundaries. With this patch a user can use "sec=krb5i,krb5p"
>> to mount a remote filesystem using krb5i, but can still cross
>> into krb5p-only exports.
>> 
>> New mounts will try all security options before failing.  NFSv4.x
>> SECINFO results will be compared against the sec= flavors to
>> find the first flavor in both lists or if no match is found will
>> return EPERM.
>> 
>> This patch cleans up some of the auth flavor logic by separating
>> the parsed mount options from the currently selected flavor and
>> sharing more code between the 'no sec= specified' and 'sec= specified'
>> code paths.
>> 
>> Along with this patch I'm posting a patch to nfs-util's nfs.man to
>> reflect these changes.
>> 
>> I wrote a script to verify that I haven't broken anything, it tests
>> all vers= and sec= combinations against a server with the exports:
>> 
>> /export/sys       *(sec=sys,rw,no_root_squash)
>> /export/krb5a     *(sec=krb5,rw,no_root_squash)
>> /export/krb5i     *(sec=krb5i,rw,no_root_squash)
>> /export/krb5p     *(sec=krb5p,rw,no_root_squash)
>> /export/krb5ip    *(sec=krb5i:krb5p,rw,no_root_squash)
>> /export/krb5aip   *(sec=krb5:krb5i:krb5p,rw,no_root_squash)
>> 
>> The script runs these tests against all exports, and the versions NFSv3,
>> v4.0, v4.1:
>> - no sec= options
>> - all single sec= options
>> - all combinations of multiple sec= options
>> - no sec= SECINFO (mount / then ls export dir, v4.x only)
>> - single sec= SECINFO (mount / then ls export dir, v4.x only)
>> - all combinations of multiple sec= SECINFO (mount / then ls export dir,
>>    v4.x only)
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> 
> Can you please split this up? It seems to me that there are at least 3
> patches here:
> 
>     1. Refactor code to introduce struct nfs_auth_info
>     2. Cache struct nfs_auth_info in struct nfs_server
>     3. Extend the mount code to allow multiple auth flavours in the
>        'sec=' mount options

Sounds good.

-dros

> 
> Thanks
>  Trond
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

