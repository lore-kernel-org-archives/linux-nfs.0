From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: startup instructions on CITI's NFSv4 website, etc.
Date: Thu, 12 Feb 2004 19:49:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040213004903.GA25298@fieldses.org>
References: <OFA29AEF0E.73E73603-ON88256E37.00664627-88256E39.0003317D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4-wg@citi.umich.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArRXW-0005Zx-0v
	for nfs@lists.sourceforge.net; Thu, 12 Feb 2004 16:50:42 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1ArRTc-0004aY-45
	for nfs@lists.sourceforge.net; Thu, 12 Feb 2004 16:46:40 -0800
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: <OFA29AEF0E.73E73603-ON88256E37.00664627-88256E39.0003317D@us.ibm.com>
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

On Thu, Feb 12, 2004 at 04:34:52PM -0800, Bruce Allan wrote:
> Re: http://www.citi.umich.edu/projects/nfsv4/linux
> 
> I believe the proper directory to use for rpc_pipefs should be
> /var/lib/nfs/rpc_pipefs (as in the sample idmapd.conf file), not
> /var/lib/rpc_pipes as documented.  This should be corrected where it
> describes the entry in /etc/fstab as well as the mkdir command.

Yep, fixed, thanks.

> Or, is the documented directory fine to use as long as the sample
> idmapd.conf file is updated to match?

That should be fine too.

> Also, the instructions for starting the daemons on both the server and
> client are not quite correct- mountd, idmapd and nfsd should each be
> prepended by "rpc.", for example, rpc.idmapd.

Yep, thanks for the correction.

> btw, I also discovered that on 2.6.1 with the latest patches from the
> website (i.e. CITI_NFS4_ALL-3) with every kernel parameter mentioned on the
> website compiled directly into the kernel my machine won't boot (last
> message displayed is "NET: Registered protocol family 17"), but with
> CONFIG_RPCSEC_GSS_KRB5=m the machine boots fine.

Yes, it's a known problem.  Either turn off SMP support in your kernel,
or apply the appended patch, or just upgrade to the latest 2.6.2 CITI
patches, which were released today.

> Still having a problem getting rpc.gssd started on the client ("GSSD:
> Decrypt integrity check failed while getting initial ticket" followed by
> "couldn't get krb5 machine ticket"), but that's probably a krb5
> configuration problem on my part.

Hm, could be.  If you'd like to give us more details on your setup
(krb5.conf, output from klist -k, ps output to make sure gssd is running
with the right options, etc), we could try to figure out what's going
on.  nfsv4-wg@citi.umich.edu would probably be the best place to follow
up on that.--b.


diff -puN net/sunrpc/svcauth.c~neil_NfsdCacheImprove net/sunrpc/svcauth.c
--- linux-2.6.1/net/sunrpc/svcauth.c~neil_NfsdCacheImprove	2004-02-08 13:54:41.000000000 -0500
+++ linux-2.6.1-bfields/net/sunrpc/svcauth.c	2004-02-08 14:09:08.000000000 -0500
@@ -150,7 +150,11 @@ DefineCacheLookup(struct auth_domain,
 		  &auth_domain_cache,
 		  auth_domain_hash(item),
 		  auth_domain_match(tmp, item),
-		  kfree(new); if(!set) return NULL;
+		  kfree(new); if(!set) {
+		  if (new) write_unlock(&auth_domain_cache.hash_lock);
+		  else read_unlock(&auth_domain_cache.hash_lock);
+		  return NULL;
+		  }
 		  new=item; atomic_inc(&new->h.refcnt),
 		  /* no update */,
 		  0 /* no inplace updates */

_


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
