Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:28440 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbaKEUdn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 15:33:43 -0500
From: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] [nfs4-acl-tools] handle DENY ace for DELETE,
 WRITE_OWNER, and NAMED_ATTRS
Date: Wed, 5 Nov 2014 20:33:41 +0000
Message-ID: <68EDE605-2D23-4DFC-BC2A-69D293B9842F@netapp.com>
References: <1415044011-35671-1-git-send-email-kolga@netapp.com>
 <20141105202809.GC20769@pad.redhat.com>
In-Reply-To: <20141105202809.GC20769@pad.redhat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 5, 2014, at 3:28 PM, J. Bruce Fields <bfields@redhat.com> wrote:

> On Mon, Nov 03, 2014 at 02:46:51PM -0500, Olga Kornievskaia wrote:
>> Don't ignore setting or viewing DENY ace for DELETE, WRITE_OWNER, and
>> NAMED_ATTRS.
> 
> Agreed, it's trying to enforce some sort of policy when it should just
> be leaving the ACL untouched and letting the server sort it out.
> 
> Looks like we may as well remove MASK_EQUAL too, though, I can't see any
> user.
> 
> Applying as follows.

Thank you, Bruce.

> 
> --b.
> 
> commit 47f4fae9b746
> Author: Olga Kornievskaia <kolga@netapp.com>
> Date:   Mon Nov 3 14:46:51 2014 -0500
> 
>    handle DENY ace for DELETE, WRITE_OWNER, and NAMED_ATTRS
> 
>    Don't ignore setting or viewing DENY ace for DELETE, WRITE_OWNER, and
>    NAMED_ATTRS.
> 
>    Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/include/libacl_nfs4.h b/include/libacl_nfs4.h
> index 2f7cc2898678..47ca3c458110 100644
> --- a/include/libacl_nfs4.h
> +++ b/include/libacl_nfs4.h
> @@ -95,16 +95,6 @@
> #define NFS4_INHERITANCE_FLAGS (NFS4_ACE_FILE_INHERIT_ACE \
> 		| NFS4_ACE_DIRECTORY_INHERIT_ACE | NFS4_ACE_INHERIT_ONLY_ACE)
> 
> -#define NFS4_ACE_MASK_IGNORE (NFS4_ACE_DELETE | NFS4_ACE_WRITE_OWNER \
> -		| NFS4_ACE_READ_NAMED_ATTRS | NFS4_ACE_WRITE_NAMED_ATTRS)
> -/* XXX not sure about the following.  Note that e.g. DELETE_CHILD is wrong in
> - * general (should only be ignored on files). */
> -#define MASK_EQUAL(mask1, mask2) \
> -	(((mask1) & NFS4_ACE_MASK_ALL & ~NFS4_ACE_MASK_IGNORE & \
> -	  					~NFS4_ACE_DELETE_CHILD) \
> -	 == ((mask2) & NFS4_ACE_MASK_ALL & ~NFS4_ACE_MASK_IGNORE & \
> -		 				~NFS4_ACE_DELETE_CHILD))
> -
> /*
>  * NFS4_MAX_ACESIZE -- the number of bytes in the string representation we
>  * read in (not the same as on-the-wire, which is also not the same as how
> diff --git a/libnfs4acl/nfs4_new_ace.c b/libnfs4acl/nfs4_new_ace.c
> index a93f74a3c7b2..0c875b1d9ebd 100644
> --- a/libnfs4acl/nfs4_new_ace.c
> +++ b/libnfs4acl/nfs4_new_ace.c
> @@ -51,9 +51,6 @@ struct nfs4_ace * nfs4_new_ace(int is_directory, u32 type, u32 flag, u32 access_
> 	ace->type = type;
> 	ace->flag = flag;
> 
> -	if( type == NFS4_ACE_ACCESS_DENIED_ACE_TYPE )
> -		access_mask = access_mask & ~(NFS4_ACE_MASK_IGNORE);
> -
> 	/* Castrate delete_child if we aren't a directory */
> 	if (!is_directory)
> 		access_mask &= ~NFS4_ACE_DELETE_CHILD;

