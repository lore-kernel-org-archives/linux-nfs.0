From: Kenneth Sumrall <ksumrall@pacbell.net>
Subject: Re: NFSD SGID permission problem
Date: Thu, 31 Mar 2005 19:54:59 -0800
Message-ID: <424CC613.2080606@pacbell.net>
References: <424CA313.8030508@pacbell.net> <16972.44185.735806.933401@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHDFX-0004Zk-Dd
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 19:55:11 -0800
Received: from gateway-1237.mvista.com ([12.44.186.158] helo=av.mvista.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DHDFW-0000KN-Nb
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 19:55:11 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16972.44185.735806.933401@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Neil,

Thanks for the reply.  I'll test your patch tomorrow.

I took a closer look at the 2.6 code, and I see that it
uses common code in notify_change() in fs/attr.c to actually
clear the bit.  So that seems OK.  However, shouldn't the code
in nfsd/vfs.c also make sure it's not a directory before it sets
the ATTR_KILL_SGID flag?  That's what the code in open.c
does, and there doesn't appear to be a check for it
not being a directory in fs/attr.c.  Or am I missing
something?

Also, is it possible to write up a quick little blurb about
why my fix isn't really safe?  It seemed to get handled by
the underlying file system just fine when I tested it.
I'm just trying to learn for the future.  If it's extremely
complicated, you can just say "It's technical." :-)

Thanks.

Ken Sumrall
ksumrall@pacbell.net


Neil Brown wrote:
> On Thursday March 31, ksumrall@pacbell.net wrote:
> 
>>So, I sent the message below on 12/10/04, and got no response.  So, I'm
>>resending it again.  I'd like some feedback on this as I'm not sure my
>>fix doesn't create a security hole.
> 
> 
> Thanks for being persistent.
> You have identified a real issue, but you are right that your fix
> isn't really safe. 
> 
> The following mimics the logic in chown_common() in open.c.  Note that
> it also ignores the setXid bits on directories.
> 
> I would appreciate it if you could double check that this fixes your
> problem.
> 
> This is against 2.4.30-rc1 (and later).  The same problem does not
> exist in 2.6.
> 
> NeilBrown
> 
> 
> ### Diffstat output
>  ./fs/nfsd/vfs.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
> --- ./fs/nfsd/vfs.c~current~	2005-04-01 12:00:29.000000000 +1000
> +++ ./fs/nfsd/vfs.c	2005-04-01 12:04:44.000000000 +1000
> @@ -280,13 +280,17 @@ nfsd_setattr(struct svc_rqst *rqstp, str
>  	}
>  
>  	/* Revoke setuid/setgid bit on chown/chgrp */
> -	if ((iap->ia_valid & ATTR_UID) && (imode & S_ISUID)
> -	 && iap->ia_uid != inode->i_uid) {
> +	if ((iap->ia_valid & ATTR_UID)
> +	    && (imode & S_ISUID)
> +	    && !S_ISDIR(imode)
> +	    && iap->ia_uid != inode->i_uid) {
>  		iap->ia_valid |= ATTR_MODE;
>  		iap->ia_mode = imode &= ~S_ISUID;
>  	}
> -	if ((iap->ia_valid & ATTR_GID) && (imode & S_ISGID)
> -	 && iap->ia_gid != inode->i_gid) {
> +	if ((iap->ia_valid & ATTR_GID)
> +	    && (imode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)
> +	    && !S_ISDIR(imode)
> +	    && iap->ia_gid != inode->i_gid) {
>  		iap->ia_valid |= ATTR_MODE;
>  		iap->ia_mode = imode &= ~S_ISGID;
>  	}
> 



-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
