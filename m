From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:20:57 -0400
Message-ID: <D3C30154-16FA-4BC5-B250-BA0FBF60CCA2@oracle.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182027.GD21043@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>,
	Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:32508 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932685AbZHUVE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 17:04:56 -0400
In-Reply-To: <20090821182027.GD21043@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 21, 2009, at 2:20 PM, J. Bruce Fields wrote:

> On Fri, Aug 21, 2009 at 02:16:08PM -0400, Chuck Lever wrote:
>> I want to understand the server bug a little more.  I glanced over  
>> RFC
>> 2623 and didn't see anything specific.
>>
>> Is it the case that only Linux NFSD does this, or do other servers do
>> it?  In other words, is this a typical server response, and if so, is
>> there a specific semantic attached to it?
>>
>> If no list is provided, should the client assume that only  
>> AUTH_NONE and
>> AUTH_SYS are supported, or instead, perhaps that the client can try  
>> to
>> use any flavor?  In other words, if no list is provided, let the  
>> mount
>> proceed no matter what was specified by sec= ?
>
> I've sent the following to Steve to fix the server bug.
>
> --b.
>
> commit ceb3c96d68f47cf6a0c38ccd88b98c59c886e9fb
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Tue Jul 21 19:30:04 2009 -0400
>
>    Don't give client an empty flavor list
>
>    In the absence of an explicit sec= option on an export,  
> rpc.mountd is
>    returning a zero-length flavor list to clients in the MOUNT  
> results.
>
>    The linux client doesn't seem to mind, but the Solaris client
>    (reasonably enough) is giving up; the symptom is a "security mode  
> does
>    not match" error on mount.
>
>    We could modify the export-parsing code to ensure the secinfo  
> array is
>    nonzero.  But I think it's slightly simpler to handle this  
> default case
>    in the implementation of the MOUNT call.  This is more-or-less  
> the same
>    thing the kernel does when mountd passes it an export without any
>    security flavors specified.
>
>    Thanks to Tom Haynes for bug report and diagnosis.
>
>    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index b59f939..888fd8c 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -359,6 +359,11 @@ static void set_authflavors(struct mountres3_ok  
> *ok, nfs_export *exp)
> 		flavors[i] = s->flav->fnum;
> 		i++;
> 	}
> +	if (i == 0) {
> +		/* default when there is no sec= option: */
> +		i = 1;
> +		flavors[0] = AUTH_UNIX;
> +	}

Does the Linux server also support AUTH_NONE if sec= isn't specified?

> 	ok->auth_flavors.auth_flavors_val = flavors;
> 	ok->auth_flavors.auth_flavors_len = i;
> }

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



