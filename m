From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] 2.4 client - update d_cache when server
	reports	ENOENT on	an NFS remove
Date: Mon, 31 Jul 2006 07:37:42 -0400
Message-ID: <1154345862.6328.1.camel@dantu.rdu.redhat.com>
References: <1154117879.23316.19.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mtosatti@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7W5r-0006hN-Nr
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 04:37:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7W5q-0004Kn-Vj
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 04:37:56 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6VBbhgn010016
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 07:37:43 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6VBbhJ1015945
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 07:37:43 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <1154117879.23316.19.camel@dantu.rdu.redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2006-07-28 at 16:17 -0400, Jeff Layton wrote:
> Anuwat Phrukphicharn of HP discovered and patched this problem in
> RHEL-3, and asked that I push it upstream.
>
> --- linux-2.4.21/fs/nfs/dir.c.unlink-enoent
> +++ linux-2.4.21/fs/nfs/dir.c
> @@ -1023,7 +1023,10 @@ static int nfs_safe_remove(struct dentry
>  	if (inode)
>  		NFS_CACHEINV(inode);
>  	error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
> -	if (error < 0)
> +
> +	/* if server returned ENOENT, assume that the dentry is already gone
> +	 * and update the cache accordingly */
> +	if (error < 0 && (error != -ENOENT))
>  		goto out;
>  	if (inode)
>  		inode->i_nlink--;
> 

Forgot to add the signoff line. Let me know if I need to resend the
email in its entirety.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
